import 'dart:convert';

import 'package:availalert/firebase_options.dart';
import 'package:availalert/pages/central_page.dart';
import 'package:availalert/pages/home_page.dart';
import 'package:availalert/pages/login_page.dart';
import 'package:availalert/theme.dart';
import 'package:availalert/utils/internet_service.dart';
import 'package:availalert/utils/utils.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  // print("callbackDispatcher called");
  NotificationController.initializeLocalNotifications();
  // NotificationController.startListeningNotificationEvents();

  Workmanager().executeTask((task, inputData) async {
    // print("$task $inputData");
    await GetStorage.init();
    // Your background task logic goes here
    if (task == 'sendNotificationAvailbaleAfter') {
      await NotificationController.createNewNotification(true);
      // await NotificationController.createNewNotification(true, inputData!);

      await http
          .get(Uri.parse(
              'https://firestore.googleapis.com/v1/projects/availalert-22e83/databases/(default)/documents/users/${GetStorage().read('phone')}/waiting'))
          .then((resp) async {
            print(resp.body);
        if (resp.statusCode == 200) {
          // Successfully fetched data
          final Map<String, dynamic> data = json.decode(resp.body);

          if (data.containsKey('documents')) {
            List waitingList = [];
            for (var document in data['documents']) {
              if (document.containsKey('fields') &&
                  document['fields'].containsKey('FCMKey')) {
                waitingList.add(document['fields']['FCMKey']['stringValue']);
              }
            }

            if (waitingList.isNotEmpty) {
              await sendNotification(
                  ids: waitingList,
                  description:
                      "Please wait until availability updates from ${GetStorage().read("firstName")} ${GetStorage().read("lastName")}. Thank you for your patience!");
            }
          } else {
            // Handle errors
            if (kDebugMode) {
              print('Error: ${resp.statusCode}, ${resp.reasonPhrase}');
            }
          }
        }
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print('Exception: $error');
        }
      });
    } else if (task == 'sendNotificationAvailbaleTill') {
      await NotificationController.createNewNotification(false);
      // await NotificationController.createNewNotification(false, inputData!);

      await http
          .get(Uri.parse(
              'https://firestore.googleapis.com/v1/projects/availalert-22e83/databases/(default)/documents/users/${GetStorage().read('phone')}/waiting'))
          .then((resp) async {
            print(resp.body);
        if (resp.statusCode == 200) {
          // Successfully fetched data
          final Map<String, dynamic> data = json.decode(resp.body);

          if (data.containsKey('documents')) {
            List waitingList = [];
            for (var document in data['documents']) {
              if (document.containsKey('fields') &&
                  document['fields'].containsKey('FCMKey')) {
                waitingList.add(document['fields']['FCMKey']['stringValue']);
              }
            }

            if (waitingList.isNotEmpty) {
              await sendNotification(
                  ids: waitingList,
                  description:
                      "Please wait until availability updates from ${GetStorage().read("firstName")} ${GetStorage().read("lastName")}. Thank you for your patience!");
            }
          } else {
            // Handle errors
            if (kDebugMode) {
              print('Error: ${resp.statusCode}, ${resp.reasonPhrase}');
            }
          }
        }
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print('Exception: $error');
        }
      });
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure Firestore settings
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  MyTheme.init();
  InternetService.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Workmanager().initialize(callbackDispatcher);
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..loadingStyle = EasyLoadingStyle.custom
    ..progressColor = MyTheme.accent
    ..backgroundColor = MyTheme.cardBackground
    ..indicatorColor = MyTheme.accent
    ..textColor = MyTheme.accent
    ..maskColor = MyTheme.background.withOpacity(0.9)
    ..maskType = EasyLoadingMaskType.custom
    ..userInteractions = false
    ..dismissOnTap = false;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AvailAlert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: EasyLoading.init(),
      home: GetStorage().read("isLogedIn") ?? false
          ? const HomePage()
          : const LoginPage(),
    );
  }
}

class NotificationController {
  static ReceivedAction? initialAction;

  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        // 'resource://drawable/ic_launcher',
        null,
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: Color(0xFF9D50DD),
              ledColor: Colors.white,
              importance: NotificationImportance.Max,
              channelShowBadge: true,
              locked: true,
              defaultRingtoneType: DefaultRingtoneType.Notification),
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: true);

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  ///  Notifications events are only delivered after call this method
  // static Future<void> startListeningNotificationEvents() async {
  //   AwesomeNotifications()
  //       .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  // }

  // @pragma('vm:entry-point')
  // static Future<void> onActionReceivedMethod(
  //     ReceivedAction receivedAction) async {
  //   // if (receivedAction.actionType == ActionType.SilentAction ||
  //   //     receivedAction.actionType == ActionType.SilentBackgroundAction) {
  //   //   // For background actions, you must hold the execution until the end
  //   //   print(
  //   //       'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
  //   // } else {
  //   //   // Check if the action is triggered by a user interaction
  //   // }

  //   // print(
  //   //     "Notification Clicked: $receivedAction ${receivedAction.buttonKeyPressed}");
  //   print(receivedAction.payload);

  //   await GetStorage.init();

  //   if (receivedAction.buttonKeyPressed == 'AVAILABLE') {
  //     // print('Available clicked');

  //     await http
  //         .patch(
  //       Uri.parse(
  //           'https://firestore.googleapis.com/v1/projects/availalert-22e83/databases/(default)/documents/users/${GetStorage().read('phone')}?updateMask.fieldPaths=isAvailable'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({
  //         'fields': {
  //           "isAvailable": {"booleanValue": true}
  //         },
  //       }),
  //     )
  //         .then((res) {
  //       print('Response body: ${res.body}');
  //       if (res.statusCode == 200) {
  //         print('Data written successfully');
  //       } else {
  //         print('Failed to write data. Status code: ${res.statusCode}');
  //       }
  //     });

  //     // await http
  //     //     .get(
  //     //   Uri.parse(
  //     //       'https://firestore.googleapis.com/v1/projects/availalert-22e83/databases/(default)/documents/users/${GetStorage().read('phone')}/waiting'),
  //     // )
  //     //     .then((resp) async {
  //     //   if (resp.statusCode == 200) {
  //     //     // Successfully fetched data
  //     //     final Map<String, dynamic> data = json.decode(resp.body);

  //     //     if (data.containsKey('documents')) {
  //     //       List waitingList = [];
  //     //       for (var document in data['documents']) {
  //     //         if (document.containsKey('fields') &&
  //     //             document['fields'].containsKey('FCMKey')) {
  //     //           waitingList.add(document['fields']['FCMKey']['stringValue']);
  //     //         }
  //     //       }

  //     //       // Now you have all FCMKeys in the fcmKeys list
  //     //       if (waitingList.isNotEmpty) {
  //     //         await sendNotification(
  //     //                 ids: waitingList,
  //     //                 description:
  //     //                     "${GetStorage().read("firstName")} ${GetStorage().read("lastName")} is now available at ${receivedAction.payload!['location']}")
  //     //             .then((value) async {
  //     //           if (value) {
  //     //             await http
  //     //                 .patch(
  //     //               Uri.parse(
  //     //                   'https://firestore.googleapis.com/v1/projects/availalert-22e83/databases/(default)/documents/users/${GetStorage().read('phone')}'),
  //     //               headers: {
  //     //                 'Content-Type': 'application/json',
  //     //               },
  //     //               body: json.encode({
  //     //                 'fields': {
  //     //                   "isAvailable": {"booleanValue": true}
  //     //                 },
  //     //               }),
  //     //             )
  //     //                 .then((res) {
  //     //               if (res.statusCode == 200) {
  //     //                 print('Data written successfully');
  //     //               } else {
  //     //                 print(
  //     //                     'Failed to write data. Status code: ${res.statusCode}');
  //     //                 print('Response body: ${res.body}');
  //     //               }
  //     //             });
  //     //           } else {
  //     //             print("Please Catch Error");
  //     //           }
  //     //         });
  //     //       }
  //     //     } else {
  //     //       // Handle errors
  //     //       if (kDebugMode) {
  //     //         print('Error: ${resp.statusCode}, ${resp.reasonPhrase}');
  //     //       }
  //     //     }
  //     //   }
  //     // }).onError((error, stackTrace) {
  //     //   if (kDebugMode) {
  //     //     print('Exception: $error');
  //     //   }
  //     // });
  //   } else if (receivedAction.buttonKeyPressed == 'BUSY') {
  //     print('Busy clicked');
  //   } else if (receivedAction.buttonKeyPressed == 'NOTAVAILABLE') {
  //     print('Not Available clicked');
  //   } else if (receivedAction.buttonKeyPressed == 'STILLAVAILABLE') {
  //     print('Still Available clicked');
  //   }
  // }

  static Future<void> createNewNotification(bool type) async {
    // static Future<void> createNewNotification(bool type, Map<String, dynamic> inputData) async {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        autoDismissible: false,
        actionType: ActionType.Default,
        locked: true,
        id: 10,
        channelKey: 'basic_channel',
        title: type ? 'Are you now available?' : 'Are you still available?',
        body: type
            ? "If you are now available, please change your availability status to 'Available'. If not, select how much time you still need to be available."
            : "If you are not available, please change your availability status to 'Not Available'. If you are still available, select for how long you will be available.",
        notificationLayout: NotificationLayout.BigText,
        // payload: {
        //   'location': inputData['location'],
        // },
      ),
      // actionButtons: type
      //     ? [
      //         NotificationActionButton(
      //             key: 'AVAILABLE',
      //             label: 'Available',
      //             actionType: ActionType.SilentBackgroundAction,
      //             autoDismissible: true),
      //         NotificationActionButton(
      //             key: 'BUSY',
      //             label: 'Busy',
      //             actionType: ActionType.SilentBackgroundAction,
      //             autoDismissible: true),
      //       ]
      //     : [
      //         NotificationActionButton(
      //             key: 'NOTAVAILABLE',
      //             label: 'Not Available',
      //             actionType: ActionType.SilentBackgroundAction,
      //             autoDismissible: true),
      //         NotificationActionButton(
      //             key: 'STILLAVAILABLE',
      //             label: 'Still Available',
      //             actionType: ActionType.SilentBackgroundAction,
      //             autoDismissible: true),
      //       ],
    );
  }
}
