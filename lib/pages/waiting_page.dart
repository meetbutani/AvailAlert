import 'package:availalert/theme.dart';
import 'package:availalert/utils/internet_service.dart';
import 'package:availalert/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WaitingPage extends StatefulWidget {
  final VoidCallback setCurrIndCallback;
  const WaitingPage({super.key, required this.setCurrIndCallback});

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();
  List<Map<String, dynamic>> _waitingList = [];
  late final TextEditingController _tempLocController;
  bool useTempLoc = false;

  @override
  void initState() {
    super.initState();
    retriveWaiting();
    _tempLocController =
        TextEditingController(text: _storage.read("tempLoc") ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.background,
        surfaceTintColor: MyTheme.background,
        centerTitle: true,
        title: const Text(
          'Waiting',
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: MyTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tempLocController,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
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
            const SizedBox(height: 15),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => retriveWaiting(),
                child: _waitingList.isEmpty
                    ? ListView(
                        children: [
                          Text(
                            "No user",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: MyTheme.textColor, fontSize: 18),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: _waitingList.length,
                        itemBuilder: (context, index) => Card(
                          color: MyTheme.cardBackground,
                          child: InkWell(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: MyTheme.background,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    title: Text(
                                      "Remove from waiting",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: MyTheme.accent,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      _waitingList[index]['firstName'] !=
                                                  null &&
                                              _waitingList[index]['lastName'] !=
                                                  null
                                          ? "Are you sure you want to remove ${_waitingList[index]['firstName']} ${_waitingList[index]['lastName']} from waiting list."
                                          : "Are you sure you want to remove this user from waiting list.",
                                      style:
                                          TextStyle(color: MyTheme.textColor),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: Text(
                                          'Cancel',
                                          style:
                                              TextStyle(color: MyTheme.accent),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Get.back();
                                          if (!await InternetService
                                              .checkInternet(context)) {
                                            return;
                                          }

                                          EasyLoading.show(
                                              status: 'Please Wait ...');
                                          await _firestore
                                              .collection(
                                                  'users/${_waitingList[index]['phone']}/history')
                                              .doc(_storage.read("phone")!)
                                              .set({
                                            'notifyOn': false,
                                          }, SetOptions(merge: true)).then(
                                                  (value) async {
                                            await _firestore
                                                .collection(
                                                    'users/${_storage.read("phone")!}/waiting')
                                                .doc(_waitingList[index]
                                                    ['phone'])
                                                .delete()
                                                .then((value) {
                                              setState(() {
                                                _waitingList.removeAt(index);
                                                EasyLoading.dismiss();
                                              });
                                            }).onError((error, stackTrace) {
                                              EasyLoading.dismiss();
                                              showSnackBar(context,
                                                  "An error occurred. Please try again.");
                                            });
                                          }).onError((error, stackTrace) {
                                            EasyLoading.dismiss();
                                            showSnackBar(context,
                                                "An error occurred. Please try again.");
                                          });
                                        },
                                        child: Text(
                                          'OK',
                                          style:
                                              TextStyle(color: MyTheme.accent),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_waitingList[index]['firstName']} ${_waitingList[index]['lastName']}',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: MyTheme.textColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            const SizedBox(width: 5),
                                            Icon(
                                              Icons.alternate_email,
                                              color: MyTheme.accent,
                                              size: 14,
                                            ),
                                            Text(
                                              ' ${_waitingList[index]['username']}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: MyTheme.textColor),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const SizedBox(width: 5),
                                            Icon(
                                              Icons.email_outlined,
                                              color: MyTheme.accent,
                                              size: 14,
                                            ),
                                            Text(
                                              ' ${_waitingList[index]['email']}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: MyTheme.textColor),
                                            ),
                                          ],
                                        ),
                                        // Row(
                                        //   children: [
                                        //     const SizedBox(width: 5),
                                        //     Icon(
                                        //       Icons.phone,
                                        //       color: MyTheme.accent,
                                        //       size: 14,
                                        //     ),
                                        //     Text(
                                        //       ' ${_waitingList[index]['phone']}',
                                        //       style: TextStyle(
                                        //           fontSize: 14,
                                        //           color: MyTheme.textColor),
                                        //     ),
                                        //   ],
                                        // ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            if (_waitingList[index]
                                                ['isImportant'])
                                              const Text(
                                                ' Important',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: Text(
                                                ' ${_waitingList[index]['reason']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: MyTheme.accent,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          if ((!useTempLoc &&
                                                  checkMainLocation(
                                                      context,
                                                      widget
                                                          .setCurrIndCallback)) ||
                                              (useTempLoc &&
                                                  _tempLocController
                                                      .text.isNotEmpty)) {
                                            if (!await InternetService
                                                .checkInternet(context)) {
                                              return;
                                            }

                                            EasyLoading.show(
                                                status: 'Please Wait ...');
                                            await sendNotification(
                                                    to: _waitingList[index]
                                                        ['FCMKey'],
                                                    description:
                                                        "${GetStorage().read("firstName")} ${GetStorage().read("lastName")} is asking you to come now at ${useTempLoc ? _tempLocController.text : _storage.read("mainLoc")}")
                                                .then((value) {
                                              _storage.write("tempLoc",
                                                  _tempLocController.text);
                                              EasyLoading.dismiss();
                                              value
                                                  ? showSnackBar(context,
                                                      "Notification Sended Successfully.")
                                                  : showSnackBar(context,
                                                      "Problem Occur in sending notification.");
                                            });
                                          } else if (useTempLoc &&
                                              _tempLocController.text.isEmpty) {
                                            showSnackBar(context,
                                                "Add Temporary Location.");
                                          }
                                        },
                                        icon: Icon(
                                          Icons.event_available_outlined,
                                          color: MyTheme.accent,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              String message = '';
                                              return AlertDialog(
                                                backgroundColor:
                                                    MyTheme.background,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                title: Text(
                                                  "Send Message",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: MyTheme.accent,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      onChanged: (value) {
                                                        message = value;
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Message',
                                                        labelStyle: TextStyle(
                                                            color: MyTheme
                                                                .textColor),
                                                        alignLabelWithHint:
                                                            true,
                                                        border:
                                                            OutlineInputBorder(),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey),
                                                        ),
                                                      ),
                                                      style: TextStyle(
                                                          color: MyTheme
                                                              .textColor),
                                                      maxLines: null,
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                          color:
                                                              MyTheme.accent),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Get.back();
                                                      // if (!await InternetService
                                                      //     .checkInternet(
                                                      //         context)) {
                                                      //   return;
                                                      // }

                                                      // EasyLoading.show(
                                                      //     status:
                                                      //         'Please Wait ...');
                                                      // await _firestore
                                                      //     .collection(
                                                      //         'users/${_waitingList[index]['phone']}/history')
                                                      //     .doc(_storage
                                                      //         .read("phone")!)
                                                      //     .set(
                                                      //         {
                                                      //       'message': message,
                                                      //     },
                                                      //         SetOptions(
                                                      //             merge:
                                                      //                 true)).then(
                                                      //         (value) async {
                                                      //   await _firestore
                                                      //       .collection(
                                                      //           'users/${_storage.read("phone")!}/waiting')
                                                      //       .doc(_waitingList[
                                                      //           index]['phone'])
                                                      //       .delete()
                                                      //       .then((value) {
                                                      //     setState(() {
                                                      //       _waitingList
                                                      //           .removeAt(index);
                                                      //       EasyLoading.dismiss();
                                                      //     });
                                                      //   }).onError((error,
                                                      //           stackTrace) {
                                                      //     EasyLoading.dismiss();
                                                      //     showSnackBar(context,
                                                      //         "An error occurred. Please try again.");
                                                      //   });
                                                      // }).onError((error,
                                                      //         stackTrace) {
                                                      //   EasyLoading.dismiss();
                                                      //   showSnackBar(context,
                                                      //       "An error occurred. Please try again.");
                                                      // });
                                                    },
                                                    child: Text(
                                                      'Send',
                                                      style: TextStyle(
                                                          color:
                                                              MyTheme.accent),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(
                                          Icons.send,
                                          color: MyTheme.accent,
                                        ),
                                      ),
                                      // IconButton(
                                      //   onPressed: () async {

                                      //   },
                                      //   icon: Icon(
                                      //     Icons.delete,
                                      //     color: MyTheme.accent,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void retriveWaiting() async {
    if (!await InternetService.checkInternet(context)) {
      return;
    }
    EasyLoading.show(status: 'Please Wait ...');
    await _firestore
        .collection('users/${_storage.read("phone")!}/waiting')
        .get()
        .then((query) {
      if (query.docs.isNotEmpty) {
        setState(() {
          _waitingList = query.docs
              .map((e) => {
                    'FCMKey': e.get('FCMKey'),
                    'firstName': e.get('firstName'),
                    'lastName': e.get('lastName'),
                    'username': e.get('username'),
                    'email': e.get('email'),
                    'phone': e.get('phone'),
                    'isImportant': e.get('isImportant'),
                    'reason': e.get('reason'),
                  })
              .toList();
        });
        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();
        return;
      }
    });
  }
}
