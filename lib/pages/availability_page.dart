// ignore_for_file: use_build_context_synchronously

import 'package:availalert/theme.dart';
import 'package:availalert/utils/internet_service.dart';
import 'package:availalert/utils/utils.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';

class AvailabilityPage extends StatefulWidget {
  final VoidCallback setCurrIndCallback;
  const AvailabilityPage({Key? key, required this.setCurrIndCallback})
      : super(key: key);

  @override
  State<AvailabilityPage> createState() => AavailabilityPageState();
}

class AavailabilityPageState extends State<AvailabilityPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

  late TimeOfDay selectedTimeAfter;
  late TimeOfDay selectedTimeFor;
  final GetStorage _storage = GetStorage();
  final _firestore = FirebaseFirestore.instance;
  List _waitingList = [];
  late bool isAvailable;
  bool useTempLoc = false;
  late BuildContext pagecontext;

  late final TextEditingController _tempLocController;
  late final TextEditingController _mainLocController;

  @override
  void initState() {
    super.initState();
    selectedTimeAfter = TimeOfDay.now().replacing(
      hour: (TimeOfDay.now().hour + 2) % 24 +
                  ((TimeOfDay.now().minute + 30) % 60) ==
              0
          ? 1
          : 0,
      minute: (TimeOfDay.now().minute + 30) % 60,
    );

    selectedTimeFor = TimeOfDay.now().replacing(
      hour: (TimeOfDay.now().hour + 2) % 24 +
                  ((TimeOfDay.now().minute + 30) % 60) ==
              0
          ? 1
          : 0,
      minute: (TimeOfDay.now().minute + 30) % 60,
    );

    // Get the value of isAvailable from GetStorage
    isAvailable = _storage.read('isAvailable') ?? false;
    _mainLocController = TextEditingController(text: _storage.read("mainLoc"));
    _tempLocController =
        TextEditingController(text: _storage.read("tempLoc") ?? "");
  }

  @override
  Widget build(BuildContext context) {
    pagecontext = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.background,
        surfaceTintColor: MyTheme.background,
        centerTitle: true,
        title: const Text(
          'Availability Status',
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: MyTheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You are ",
                    style: TextStyle(color: MyTheme.textColor, fontSize: 24),
                  ),
                  Text(
                    _storage.read("isAvailable")
                        ? "Available"
                        : "Not Available",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        color: _storage.read("isAvailable")
                            ? Colors.lightGreenAccent[400]
                            : Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: isAvailable
                    ? [
                        customButton(
                          label: "Not Available",
                          isExpanded: true,
                          onTap: () async {
                            // if (!await InternetService.checkInternet(context)) {
                            //   return;
                            // }

                            // EasyLoading.show(status: 'Please Wait ...');
                            // await _firestore
                            //     .collection('users')
                            //     .doc(_storage.read("phone"))
                            //     .set({
                            //   'isAvailable': false,
                            // }, SetOptions(merge: true)).then((value) async {
                            //   setState(() {
                            //     isAvailable = false;
                            //     _storage.write('isAvailable', false);
                            //   });
                            //   await AwesomeNotifications().cancel(10);
                            //   EasyLoading.dismiss();
                            // }).onError((error, stackTrace) {
                            //   EasyLoading.dismiss();
                            //   showSnackBar(context,
                            //       "An error occurred. Please try again.");
                            // });

                            if (!await InternetService.checkInternet(context)) {
                              return;
                            }

                            EasyLoading.show(status: 'Please Wait ...');
                            await _firestore
                                .collection(
                                    'users/${_storage.read('phone')}/waiting')
                                .get()
                                .then((query) async {
                              print(query.docs);
                              if (query.docs.isNotEmpty) {
                                _waitingList = query.docs
                                    .map((e) => e.get('FCMKey'))
                                    .toList();

                                if (await sendNotification(
                                    ids: _waitingList,
                                    description:
                                        "${_storage.read("firstName")} ${_storage.read("lastName")} is now not available. Please wait until availability updates from ${GetStorage().read("firstName")} ${GetStorage().read("lastName")}. Thank you for your patience!")) {
                                  await _firestore
                                      .collection('users')
                                      .doc(_storage.read("phone"))
                                      .set({
                                    'isAvailable': false,
                                    'availableAfter': '',
                                    'availableTill': '',
                                    'availableLoc': '',
                                  }, SetOptions(merge: true)).then(
                                          (value) async {
                                    setState(() {
                                      isAvailable = false;
                                      _storage.write('isAvailable', false);
                                    });
                                    await Workmanager().cancelAll();
                                    await AwesomeNotifications().cancel(10);
                                    EasyLoading.dismiss();
                                    showSnackBar(context,
                                        "Notification Sended Successfully.");
                                  }).onError((error, stackTrace) {
                                    EasyLoading.dismiss();
                                    showSnackBar(context,
                                        "An error occurred. Please try again.");
                                  });
                                } else {
                                  EasyLoading.dismiss();
                                  showSnackBar(context,
                                      "An error occurred. Please try again.");
                                }
                              } else {
                                await _firestore
                                    .collection('users')
                                    .doc(_storage.read("phone"))
                                    .set({
                                  'isAvailable': true,
                                  'availableAfter': '',
                                  'availableTill': '',
                                  'availableLoc': '',
                                }, SetOptions(merge: true)).then((value) async {
                                  setState(() {
                                    isAvailable = true;
                                    _storage.write('isAvailable', true);
                                  });
                                  await Workmanager().cancelAll();

                                  await AwesomeNotifications().cancel(10);
                                  // EasyLoading.dismiss();
                                  EasyLoading.dismiss();
                                });
                                return;
                              }
                            }).onError((error, stackTrace) {
                              EasyLoading.dismiss();
                              showSnackBar(context,
                                  "An error occurred. Please try again.");
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Available for",
                          style:
                              TextStyle(color: MyTheme.textColor, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0, // Adjust the spacing between buttons
                          runSpacing: 8.0, // Adjust the spacing between lines
                          // alignment: WrapAlignment.spaceEvenly,
                          children: [
                            customButton(
                              label: "1 min",
                              onTap: () {
                                onForDurationBtnClick(minutes: 15);
                              },
                            ),
                            customButton(
                              label: "15 min",
                              onTap: () {
                                onForDurationBtnClick(minutes: 15);
                              },
                            ),
                            customButton(
                              label: "30 min",
                              onTap: () {
                                onForDurationBtnClick(minutes: 30);
                              },
                            ),
                            customButton(
                              label: "45 min",
                              onTap: () {
                                onForDurationBtnClick(minutes: 45);
                              },
                            ),
                            customButton(
                              label: "1 hour",
                              onTap: () {
                                onForDurationBtnClick(hours: 1);
                              },
                            ),
                            customButton(
                              label: "1 hour 30 min",
                              onTap: () {
                                onForDurationBtnClick(hours: 1, minutes: 30);
                              },
                            ),
                            customButton(
                              label: "2 hours",
                              onTap: () {
                                onForDurationBtnClick(hours: 2);
                              },
                            ),
                            customButton(
                              label: selectedTimeFor.format(context),
                              onTap: () {
                                DateTime currentTime = DateTime.now();

                                onForDurationBtnClick(
                                    minutes: DateTime(
                                  currentTime.year,
                                  currentTime.month,
                                  currentTime.day,
                                  selectedTimeFor.hour,
                                  selectedTimeFor.minute,
                                ).difference(currentTime).inMinutes);
                              },
                            ),
                            IconButton(
                              onPressed: () {
                                _selectTime(context);
                              },
                              icon: Icon(
                                Icons.more_time,
                                color: MyTheme.textColor,
                              ),
                            )
                          ],
                        ),
                      ]
                    : [
                        customButton(
                          label: "Available Now",
                          isExpanded: true,
                          onTap: () async {
                            if ((!useTempLoc &&
                                    checkMainLocation(pagecontext,
                                        widget.setCurrIndCallback)) ||
                                (useTempLoc &&
                                    _tempLocController.text.isNotEmpty)) {
                              if (!await InternetService.checkInternet(
                                  context)) {
                                return;
                              }

                              EasyLoading.show(status: 'Please Wait ...');
                              await _firestore
                                  .collection(
                                      'users/${_storage.read('phone')}/waiting')
                                  .get()
                                  .then((query) async {
                                print(query.docs);
                                if (query.docs.isNotEmpty) {
                                  _waitingList = query.docs
                                      .map((e) => e.get('FCMKey'))
                                      .toList();

                                  if (await sendNotification(
                                      ids: _waitingList,
                                      description:
                                          "${_storage.read("firstName")} ${_storage.read("lastName")} is now available at ${useTempLoc ? _tempLocController.text : _storage.read("mainLoc")}")) {
                                    await _firestore
                                        .collection('users')
                                        .doc(_storage.read("phone"))
                                        .set({
                                      'isAvailable': true,
                                      'availableLoc': useTempLoc
                                          ? _tempLocController.text
                                          : _storage.read("mainLoc"),
                                      'availableAfter': '',
                                      'availableTill': '',
                                    }, SetOptions(merge: true)).then(
                                            (value) async {
                                      setState(() {
                                        isAvailable = true;
                                        _storage.write('isAvailable', true);
                                      });
                                      await Workmanager().cancelAll();
                                      await AwesomeNotifications().cancel(10);
                                      EasyLoading.dismiss();
                                      showSnackBar(context,
                                          "Notification Sended Successfully.");
                                    }).onError((error, stackTrace) {
                                      EasyLoading.dismiss();
                                      showSnackBar(context,
                                          "An error occurred. Please try again.");
                                    });
                                  } else {
                                    EasyLoading.dismiss();
                                    showSnackBar(context,
                                        "An error occurred. Please try again.");
                                  }
                                } else {
                                  await _firestore
                                      .collection('users')
                                      .doc(_storage.read("phone"))
                                      .set({
                                    'isAvailable': true,
                                    'availableLoc': useTempLoc
                                        ? _tempLocController.text
                                        : _storage.read("mainLoc"),
                                    'availableAfter': '',
                                    'availableTill': '',
                                  }, SetOptions(merge: true)).then(
                                          (value) async {
                                    setState(() {
                                      isAvailable = true;
                                      _storage.write('isAvailable', true);
                                    });
                                    await Workmanager().cancelAll();

                                    await AwesomeNotifications().cancel(10);
                                    // EasyLoading.dismiss();
                                    EasyLoading.dismiss();
                                  });
                                  return;
                                }
                              }).onError((error, stackTrace) {
                                EasyLoading.dismiss();
                                showSnackBar(context,
                                    "An error occurred. Please try again.");
                              });
                            } else if (useTempLoc &&
                                _tempLocController.text.isEmpty) {
                              showSnackBar(context, "Add Temporary Location.");
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Available after",
                          style:
                              TextStyle(color: MyTheme.textColor, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0, // Adjust the spacing between buttons
                          runSpacing: 8.0, // Adjust the spacing between lines
                          // alignment: WrapAlignment.spaceEvenly,
                          children: [
                            customButton(
                              label: "1 min",
                              onTap: () {
                                onAfterDurationBtnClick(minutes: 1);
                              },
                            ),
                            customButton(
                              label: "15 min",
                              onTap: () {
                                onAfterDurationBtnClick(minutes: 15);
                              },
                            ),
                            customButton(
                              label: "30 min",
                              onTap: () {
                                onAfterDurationBtnClick(minutes: 30);
                              },
                            ),
                            customButton(
                              label: "45 min",
                              onTap: () {
                                onAfterDurationBtnClick(minutes: 45);
                              },
                            ),
                            customButton(
                              label: "1 hour",
                              onTap: () {
                                onAfterDurationBtnClick(hours: 1);
                              },
                            ),
                            customButton(
                              label: "1 hour 30 min",
                              onTap: () {
                                onAfterDurationBtnClick(hours: 1, minutes: 30);
                              },
                            ),
                            customButton(
                              label: "2 hours",
                              onTap: () {
                                onAfterDurationBtnClick(hours: 2);
                              },
                            ),
                            customButton(
                              label: selectedTimeAfter.format(context),
                              onTap: () {
                                // QuerySnapshot query = await _firestore
                                //     .collection(
                                //         'users/${_storage.read('phone')}/waiting')
                                //     .get();

                                // if (query.docs.isNotEmpty) {
                                //   _waitingList = query.docs
                                //       .map((e) => e.get('FCMKey'))
                                //       .toList();
                                // }

                                // await sendNotification(
                                //         ids: _waitingList,
                                //         description:
                                //             "${_storage.read("firstName")} ${_storage.read("lastName")} is available after ${selectedTime.format(context)} at ${_tempLocController.text.isNotEmpty ? _tempLocController.text : _storage.read("mainLoc") ?? ''}")
                                //     .then((value) => value
                                //         ? showSnackBar(context,
                                //             "Notification Sended Successfully")
                                //         : showSnackBar(
                                //             context, "Problem Occur, Try Again."));

                                DateTime currentTime = DateTime.now();

                                onAfterDurationBtnClick(
                                    minutes: DateTime(
                                  currentTime.year,
                                  currentTime.month,
                                  currentTime.day,
                                  selectedTimeAfter.hour,
                                  selectedTimeAfter.minute,
                                ).difference(currentTime).inMinutes);

                                // await Workmanager().cancelAll();
                                // await Workmanager().registerOneOffTask(
                                //   "1",
                                //   "sendNotificationOnTimeFinish",
                                //   initialDelay:
                                //       selectedDateTime.difference(currentTime),
                                //   inputData: {
                                //     'location': _tempLocController.text.isNotEmpty
                                //         ? _tempLocController.text
                                //         : _storage.read("mainLoc") ?? ''
                                //   },
                                // );
                              },
                            ),
                            IconButton(
                              onPressed: () {
                                _selectTime(context);
                              },
                              icon: Icon(
                                Icons.more_time,
                                color: MyTheme.textColor,
                              ),
                            )
                          ],
                        ),
                      ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _mainLocController,
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: InputDecoration(
                  labelText: "Main Location",
                  // alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  labelStyle: TextStyle(color: MyTheme.textColor, fontSize: 16),
                ),
                style: TextStyle(color: MyTheme.textColor, fontSize: 16),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tempLocController,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        _storage.write("tempLoc", _tempLocController.text);
                      },
                      decoration: InputDecoration(
                        labelText: "Temporary Location",
                        labelStyle:
                            TextStyle(color: MyTheme.textColor, fontSize: 16),
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        // helperText:
                        //     "Leave it empty if dont want to use temporary location.",
                        // helperStyle: TextStyle(
                        //     color: MyTheme.textColor, fontSize: 12),
                      ),
                      // "Enter temporary location if you want to use instead of main location"),
                      style: TextStyle(color: MyTheme.textColor, fontSize: 16),
                    ),
                  ),
                  Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      value: useTempLoc,
                      side: const BorderSide(
                        width: 0.6,
                        color: Colors.grey,
                      ),
                      onChanged: (val) => setState(() => useTempLoc = val!),
                      activeColor: MyTheme.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTimeAfter,
    );

    if (picked != null && picked != selectedTimeAfter) {
      setState(() {
        selectedTimeAfter = picked;
      });
    }
  }

  // Function to be called when a duration button is pressed
  void onForDurationBtnClick({int hours = 0, int minutes = 0}) async {
    // Implement your logic here based on the selected duration
    // print('Button pressed for $hours hours and $minutes minutes');

    if ((!useTempLoc &&
            checkMainLocation(pagecontext, widget.setCurrIndCallback)) ||
        (useTempLoc && _tempLocController.text.isNotEmpty)) {
      if (!await InternetService.checkInternet(context)) {
        return;
      }

      EasyLoading.show(status: 'Please Wait ...');
      String availableTime = TimeOfDay.now()
          .replacing(
            hour: (TimeOfDay.now().hour + hours) % 24 +
                (TimeOfDay.now().minute + minutes) ~/ 60,
            minute: (TimeOfDay.now().minute + minutes) % 60,
          )
          .format(pagecontext);

      await _firestore
          .collection('users/${_storage.read('phone')}/waiting')
          .get()
          .then((query) async {
        if (query.docs.isNotEmpty) {
          _waitingList = query.docs.map((e) => e.get('FCMKey')).toList();

          await sendNotification(
                  ids: _waitingList,
                  description:
                      "${_storage.read("firstName")} ${_storage.read("lastName")} is probably available till $availableTime at ${_tempLocController.text.isNotEmpty ? _tempLocController.text : _storage.read("mainLoc") ?? ''}")
              .then((value) async {
            if (value) {
              await _firestore
                  .collection('users')
                  .doc(_storage.read("phone"))
                  .set({
                'availableTill': availableTime,
                'availableAfter': '',
              }, SetOptions(merge: true)).then((value) async {
                EasyLoading.dismiss();
                showSnackBar(context, "Notification Sended Successfully");

                await AwesomeNotifications().cancel(10);

                // Schedule the background task
                await Workmanager().cancelAll();
                await Workmanager().registerOneOffTask(
                  "2", "sendNotificationAvailbaleTill",
                  initialDelay: Duration(hours: hours, minutes: minutes),
                  // initialDelay: const Duration(seconds: 2),
                  inputData: {
                    'location': _tempLocController.text.isNotEmpty
                        ? _tempLocController.text
                        : _storage.read("mainLoc") ?? ''
                  },
                );
              });
            } else {
              EasyLoading.dismiss();
              showSnackBar(context, "An error occurred. Please try again.");
            }
          });
        } else {
          EasyLoading.dismiss();
          return;
        }

        // // Calculate the time when the background task should run
        // DateTime scheduledTime =
        //     DateTime.now().add(Duration(hours: hours, minutes: minutes));
      }).onError((error, stackTrace) {
        EasyLoading.dismiss();
        showSnackBar(context, "An error occurred. Please try again.");
      });
    } else if (useTempLoc && _tempLocController.text.isEmpty) {
      showSnackBar(context, "Add Temporary Location.");
    }
  }

  // Function to be called when a duration button is pressed
  void onAfterDurationBtnClick({int hours = 0, int minutes = 0}) async {
    // Implement your logic here based on the selected duration
    // print('Button pressed for $hours hours and $minutes minutes');

    if ((!useTempLoc &&
            checkMainLocation(pagecontext, widget.setCurrIndCallback)) ||
        (useTempLoc && _tempLocController.text.isNotEmpty)) {
      if (!await InternetService.checkInternet(context)) {
        return;
      }

      EasyLoading.show(status: 'Please Wait ...');
      String availableTime = TimeOfDay.now()
          .replacing(
            hour: (TimeOfDay.now().hour + hours) % 24 +
                (TimeOfDay.now().minute + minutes) ~/ 60,
            minute: (TimeOfDay.now().minute + minutes) % 60,
          )
          .format(pagecontext);

      await _firestore
          .collection('users/${_storage.read('phone')}/waiting')
          .get()
          .then((query) async {
        if (query.docs.isNotEmpty) {
          _waitingList = query.docs.map((e) => e.get('FCMKey')).toList();

          await sendNotification(
                  ids: _waitingList,
                  description:
                      "${_storage.read("firstName")} ${_storage.read("lastName")} is probably available after $availableTime at ${_tempLocController.text.isNotEmpty ? _tempLocController.text : _storage.read("mainLoc") ?? ''}")
              .then((value) async {
            if (value) {
              await _firestore
                  .collection('users')
                  .doc(_storage.read("phone"))
                  .set({
                'availableAfter': availableTime,
                'availableTill': '',
              }, SetOptions(merge: true)).then((value) async {
                EasyLoading.dismiss();
                showSnackBar(context, "Notification Sended Successfully");

                await AwesomeNotifications().cancel(10);

                // Schedule the background task
                await Workmanager().cancelAll();
                await Workmanager().registerOneOffTask(
                  "1", "sendNotificationAvailbaleAfter",
                  initialDelay: Duration(hours: hours, minutes: minutes),
                  // initialDelay: const Duration(seconds: 2),
                  inputData: {
                    'location': _tempLocController.text.isNotEmpty
                        ? _tempLocController.text
                        : _storage.read("mainLoc") ?? ''
                  },
                );
              });
            } else {
              EasyLoading.dismiss();
              showSnackBar(context, "An error occurred. Please try again.");
            }
          });
        } else {
          EasyLoading.dismiss();
          return;
        }

        // // Calculate the time when the background task should run
        // DateTime scheduledTime =
        //     DateTime.now().add(Duration(hours: hours, minutes: minutes));
      }).onError((error, stackTrace) {
        EasyLoading.dismiss();
        showSnackBar(context, "An error occurred. Please try again.");
      });
    } else if (useTempLoc && _tempLocController.text.isEmpty) {
      showSnackBar(context, "Add Temporary Location.");
    }
  }
}
