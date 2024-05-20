import 'dart:convert';

import 'package:availalert/firebase_options.dart';
import 'package:availalert/pages/central_page.dart';
import 'package:availalert/pages/home_page.dart';
import 'package:availalert/pages/login_page.dart';
import 'package:availalert/theme.dart';
import 'package:availalert/utils/internet_service.dart';
import 'package:availalert/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

  Workmanager().executeTask((task, inputData) async {
    // print("$task $inputData");
    // print(GetStorage().read('phone'));
    await GetStorage.init();
    // Your background task logic goes here
    if (task == 'sendNotificationOnTimeFinish') {
      // print(GetStorage().read('phone'));

      await http
          .get(
        Uri.parse(
            'https://firestore.googleapis.com/v1/projects/availalert-22e83/databases/(default)/documents/users/${GetStorage().read('phone')}/waiting'),
        // headers: {
        //   'Authorization': 'Bearer ${jsonDecode(resp.body)["refreshToken"]}'
        // },
      )
          .then((resp) async {
        // print(resp.toString());
        // print(resp.body);
        // print(resp.contentLength);
        // print(resp.bodyBytes);
        if (resp.statusCode == 200) {
          // Successfully fetched data
          final Map<String, dynamic> data = json.decode(resp.body);

          // Process the data as needed
          // print(data);

          if (data.containsKey('documents')) {
            List waitingList = [];
            for (var document in data['documents']) {
              if (document.containsKey('fields') &&
                  document['fields'].containsKey('FCMKey')) {
                waitingList.add(document['fields']['FCMKey']['stringValue']);
              }
            }

            // Now you have all FCMKeys in the fcmKeys list
            // print('FCMKeys: $_waitingList');
            if (waitingList.isNotEmpty) {
              await sendNotification(
                  ids: waitingList,
                  description:
                      "${GetStorage().read("firstName")} ${GetStorage().read("lastName")} is now available at ${inputData!['location']}");
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

      // print(query.docs);

      // if (query.docs.isNotEmpty) {
      //   _waitingList = query.docs.map((e) => e.get('FCMKey')).toList();

      //   if (await sendNotification(
      //       ids: _waitingList,
      //       description:
      //           "${GetStorage().read("firstName")} ${GetStorage().read("lastName")} is now available at MA 159")) {
      //     GetStorage().write('isAvailable', true);
      //   }
      // }

      // print(_waitingList);

      // if (kDebugMode) {
      //   print("Background task finished");
      // }
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
