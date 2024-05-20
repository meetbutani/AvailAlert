import 'dart:async';

import 'package:availalert/theme.dart';
import 'package:availalert/utils/internet_service.dart';
import 'package:availalert/utils/notification_services.dart';
import 'package:availalert/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _searchController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();
  Timer? _debounceTimer;

  List<Map<String, dynamic>> _searchedUsers = [];
  List<Map<String, dynamic>>? _allUsers;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.background,
        surfaceTintColor: MyTheme.background,
        centerTitle: true,
        title: const Text(
          'Find User',
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    style: TextStyle(color: MyTheme.textColor, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Search User by Name/Username/Email/Phone',
                      labelStyle:
                          TextStyle(color: MyTheme.textColor, fontSize: 16),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    onChanged: (val) {
                      if (val.isEmpty || val.length <= 2) {
                        setState(() {});
                        return;
                      }

                      // Cancel previous timer to avoid unnecessary function calls
                      _debounceTimer?.cancel();

                      // Set a new timer with a delay of 800 milliseconds
                      _debounceTimer =
                          Timer(const Duration(milliseconds: 800), () {
                        // Call your function here, for example:
                        _searchUser(context);
                      });
                    },
                    onEditingComplete: () {
                      if (_searchController.text.isEmpty ||
                          _searchController.text.length <= 2) {
                        setState(() {});
                        return;
                      }

                      _searchUser(context);
                    },
                  ),
                ),
                const SizedBox(width: 20),
                // customButton(
                //   label: "Search",
                //   onTap: () => _searchUser(context),
                //   isExpanded: true,
                // ),
                IconButton(
                  onPressed: () {
                    if (_searchController.text.isEmpty ||
                        _searchController.text.length <= 2) {
                      setState(() {});
                      return;
                    }

                    _searchUser(context);
                  },
                  icon: Icon(Icons.search, color: MyTheme.accent),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_searchController.text.isEmpty ||
                _searchController.text.length <= 2)
              Text(
                "Search User",
                textAlign: TextAlign.center,
                style: TextStyle(color: MyTheme.textColor, fontSize: 18),
              )
            else if (_searchController.text.isNotEmpty &&
                _searchedUsers.isEmpty)
              Text(
                "No User Found",
                textAlign: TextAlign.center,
                style: TextStyle(color: MyTheme.textColor, fontSize: 18),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchedUsers.length,
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
                            .doc(_searchedUsers[index]['phone'])
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
                                    '${_searchedUsers[index]['firstName']} ${_searchedUsers[index]['lastName']}',
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
                                        ' ${_searchedUsers[index]['username']}',
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
                                        ' ${_searchedUsers[index]['email']}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: MyTheme.textColor),
                                      ),
                                    ],
                                  ),
                                  if (_searchController.text.length == 10 &&
                                      RegExp(r'^[0-9]+$')
                                          .hasMatch(_searchController.text))
                                    Row(
                                      children: [
                                        const SizedBox(width: 5),
                                        Icon(
                                          Icons.phone,
                                          color: MyTheme.accent,
                                          size: 14,
                                        ),
                                        Text(
                                          ' ${_searchedUsers[index]['phone']}',
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
                                IconButton(
                                  onPressed: () async {
                                    if (!await InternetService.checkInternet(
                                        context)) {
                                      return;
                                    }
                                    
                                    EasyLoading.show(status: 'Please Wait ...');

                                    if (_searchedUsers[index]['isAvailable']) {
                                      NotificationServices()
                                          .getDeviceToken()
                                          .then((value) {
                                        sendNotification(
                                                to: value,
                                                description:
                                                    "${_searchedUsers[index]['firstName']} ${_searchedUsers[index]['lastName']} is now available at ${_searchedUsers[index]['mainLoc']}")
                                            .then((value) {
                                          if (value == false) {
                                            EasyLoading.dismiss();
                                            showSnackBar(context,
                                                "An error occurred. Please try again.");
                                            return;
                                          }
                                        });
                                      });
                                    }

                                    await _firestore
                                        .collection(
                                            'users/${_searchedUsers[index]['phone']}/waiting')
                                        .doc(_storage.read("phone"))
                                        .set({
                                      'FCMKey': _storage.read("FCMKey"),
                                      'firstName': _storage.read("firstName"),
                                      'lastName': _storage.read("lastName"),
                                      'username': _storage.read("username"),
                                      'email': _storage.read("email"),
                                      'phone': _storage.read("phone"),
                                    }, SetOptions(merge: true)).then(
                                            (value) async {
                                      await _firestore
                                          .collection(
                                              'users/${_storage.read("phone")!}/history')
                                          .doc(_searchedUsers[index]['phone'])
                                          .set({
                                        'firstName': _searchedUsers[index]
                                            ['firstName'],
                                        'lastName': _searchedUsers[index]
                                            ['lastName'],
                                        'username': _searchedUsers[index]
                                            ['username'],
                                        'email': _searchedUsers[index]['email'],
                                        'phone': _searchedUsers[index]['phone'],
                                        'showPhone': _searchController
                                                        .text.length ==
                                                    10 &&
                                                RegExp(r'^[0-9]+$').hasMatch(
                                                    _searchController.text)
                                            ? true
                                            : false,
                                        'notifyOn': true,
                                      }, SetOptions(merge: true)).then((value) {
                                        EasyLoading.dismiss();
                                        showSnackBar(context,
                                            "${_searchedUsers[index]['firstName']} ${_searchedUsers[index]['lastName']} successfully added for alerts.");
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
                                    Icons.notification_add,
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

  Future<void> getAllUsers() async {
    // Search for the user by selected search type
    if (!await InternetService.checkInternet(context)) {
      return;
    }

    EasyLoading.show(status: 'Please Wait ...');
    await FirebaseFirestore.instance
        .collection('users')
        .where("username", isNotEqualTo: GetStorage().read("username") ?? '')
        .get()
        .then((query) {
      if (query.docs.isNotEmpty) {
        setState(() {
          _allUsers = query.docs
              .map((e) => {
                    'firstName': e.get('firstName'),
                    'lastName': e.get('lastName'),
                    'phone': e.get('phone'),
                    'email': e.get('email'),
                    'username': e.get('username'),
                    'mainLoc': e.get('mainLoc'),
                    'isAvailable': e.get('isAvailable'),
                  })
              .toList();
        });
        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();
      }
    }).onError((error, stackTrace) {
      showSnackBar(
          context, "An error occurred. Please check internet connection.");
      // Timer(const Duration(milliseconds: 1000), () {
      //   // Call your function here, for example:
      //   getAllUsers();
      // });
      // EasyLoading.dismiss();
    });
  }

  Future<void> _searchUser(BuildContext context) async {
    if (_searchController.text.isEmpty) {
      showSnackBar(context, 'Search field is empty.');
      return;
    }

    if (_allUsers == null) {
      if (!await InternetService.checkInternet(context)) {
        return;
      }
      await getAllUsers();
    }

    setState(() {
      _searchController.text.length == 10 &&
              RegExp(r'^[0-9]+$').hasMatch(_searchController.text)
          ? _searchedUsers = _allUsers!
              .where((element) =>
                  (element['phone'].toString() == _searchController.text))
              .toList()
          : _searchedUsers = _allUsers!
              .where((element) =>
                  ((element['firstName'] + element['lastName'])
                      .toString()
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase())) ||
                  (element['username']
                      .toString()
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase())) ||
                  (element['email']
                      .toString()
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase())))
              .toList();
    });
  }
}
