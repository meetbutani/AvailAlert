import 'package:availalert/theme.dart';
import 'package:availalert/utils/internet_service.dart';
import 'package:availalert/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();
  List<Map<String, dynamic>> _historyList = [];

  @override
  void initState() {
    super.initState();
    retriveHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.background,
        surfaceTintColor: MyTheme.background,
        centerTitle: true,
        title: const Text(
          'History',
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: MyTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: () async => retriveHistory(),
          child: _historyList.isEmpty
              ? ListView(
                  children: [
                    Text(
                      "No user",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MyTheme.textColor, fontSize: 18),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) => Card(
                    color: MyTheme.cardBackground,
                    child: InkWell(
                      onTap: () async {
                        if (!await InternetService.checkInternet(context)) {
                          return;
                        }
                        EasyLoading.show(status: 'Please Wait ...');
                        await _firestore
                            .collection('users')
                            .doc(_historyList[index]['phone'])
                            .get()
                            .then((data) async {
                          EasyLoading.dismiss();
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: MyTheme.cardBackground,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  title: Text(
                                    data.get('isAvailable')
                                        ? "Available"
                                        : "Not Available",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: data.get('isAvailable')
                                            ? Colors.lightGreenAccent[400]
                                            : Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // actions: [
                                  //   TextButton(
                                  //     onPressed: () {
                                  //       Navigator.of(context).pop();
                                  //     },
                                  //     child: const Text('OK'),
                                  //   ),
                                  // ],
                                );
                              });
                        }).onError((error, stackTrace) {
                          EasyLoading.dismiss();
                          showSnackBar(
                              context, "An error occurred. Please try again.");
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_historyList[index]['firstName']} ${_historyList[index]['lastName']}',
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
                                        ' ${_historyList[index]['username']}',
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
                                        ' ${_historyList[index]['email']}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: MyTheme.textColor),
                                      ),
                                    ],
                                  ),
                                  if (_historyList[index]['showPhone'])
                                    Row(
                                      children: [
                                        const SizedBox(width: 5),
                                        Icon(
                                          Icons.phone,
                                          color: MyTheme.accent,
                                          size: 14,
                                        ),
                                        Text(
                                          ' ${_historyList[index]['phone']}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: MyTheme.textColor),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                _historyList[index]['notifyOn']
                                    ? IconButton(
                                        onPressed: () async {
                                          if (!await InternetService
                                              .checkInternet(context)) {
                                            return;
                                          }

                                          EasyLoading.show(
                                              status: 'Please Wait ...');

                                          await _firestore
                                              .collection(
                                                  'users/${_storage.read("phone")!}/history')
                                              .doc(_historyList[index]['phone'])
                                              .set({
                                            'notifyOn': false,
                                          }, SetOptions(merge: true)).then(
                                                  (value) async {
                                            await _firestore
                                                .collection(
                                                    'users/${_historyList[index]['phone']}/waiting')
                                                .doc(_storage.read("phone")!)
                                                .delete()
                                                .then((value) {
                                              setState(() {
                                                _historyList[index]
                                                        ['notifyOn'] =
                                                    !_historyList[index]
                                                        ['notifyOn'];
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
                                          Icons.notifications_off_outlined,
                                          color: MyTheme.accent,
                                        ),
                                      )
                                    : IconButton(
                                        onPressed: () async {
                                          if (!await InternetService
                                              .checkInternet(context)) {
                                            return;
                                          }

                                          EasyLoading.show(
                                              status: 'Please Wait ...');
                                          await _firestore
                                              .collection(
                                                  'users/${_storage.read("phone")!}/history')
                                              .doc(_historyList[index]['phone'])
                                              .set({
                                            'notifyOn': true,
                                          }, SetOptions(merge: true)).then(
                                                  (value) async {
                                            await _firestore
                                                .collection(
                                                    'users/${_historyList[index]['phone']}/waiting')
                                                .doc(_storage.read("phone")!)
                                                .set({
                                              'FCMKey':
                                                  _storage.read("FCMKey")!,
                                              'firstName':
                                                  _storage.read("firstName")!,
                                              'lastName':
                                                  _storage.read("lastName")!,
                                              'username':
                                                  _storage.read("username")!,
                                              'email': _storage.read("email")!,
                                              'phone': _storage.read("phone")!,
                                            }).then((value) {
                                              setState(() {
                                                _historyList[index]
                                                        ['notifyOn'] =
                                                    !_historyList[index]
                                                        ['notifyOn'];
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
                                          Icons.notification_add_outlined,
                                          color: MyTheme.accent,
                                        ),
                                      ),
                                IconButton(
                                  onPressed: () async {
                                    if (!await InternetService.checkInternet(
                                        context)) {
                                      return;
                                    }

                                    EasyLoading.show(status: 'Please Wait ...');

                                    await _firestore
                                        .collection(
                                            'users/${_storage.read("phone")!}/history')
                                        .doc(_historyList[index]['phone'])
                                        .delete()
                                        .then((value) async {
                                      await _firestore
                                          .collection(
                                              'users/${_historyList[index]['phone']}/waiting')
                                          .doc(_storage.read("phone")!)
                                          .delete()
                                          .then((value) {
                                        setState(() {
                                          _historyList.removeAt(index);
                                        });
                                        EasyLoading.dismiss();
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
      ),
    );
  }

  void retriveHistory() async {
    if (!await InternetService.checkInternet(context)) {
      return;
    }

    EasyLoading.show(status: 'Please Wait ...');
    await _firestore
        .collection('users/${_storage.read("phone")!}/history')
        .get()
        .then((query) {
      if (query.docs.isNotEmpty) {
        setState(() {
          _historyList = query.docs
              .map((e) => {
                    'firstName': e.get('firstName'),
                    'lastName': e.get('lastName'),
                    'phone': e.get('phone'),
                    'showPhone': e.get('showPhone'),
                    'email': e.get('email'),
                    'username': e.get('username'),
                    'notifyOn': e.get('notifyOn'),
                  })
              .toList();
        });
        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();
      }
    }).onError((error, stackTrace) {
      EasyLoading.dismiss();
      showSnackBar(context, "An error occurred. Please try again.");
    });
  }

  void addNewCard(obj) {
    setState(() {
      _historyList.insert(0, obj);
    });
  }
}
