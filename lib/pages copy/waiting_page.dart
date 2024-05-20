import 'package:availalert/theme.dart';
import 'package:availalert/utils/internet_service.dart';
import 'package:availalert/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
                                                      "${GetStorage().read("firstName")} ${GetStorage().read("lastName")} is now available at ${useTempLoc ? _tempLocController.text : _storage.read("mainLoc")}")
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
                                      onPressed: () async {
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
                                              .doc(_waitingList[index]['phone'])
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
                                      icon: Icon(
                                        Icons.delete,
                                        color: MyTheme.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
