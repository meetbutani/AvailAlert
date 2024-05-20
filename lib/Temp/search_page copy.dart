import 'dart:convert';

import 'package:availalert/pages/login_page.dart';
import 'package:availalert/theme.dart';
import 'package:availalert/utils/notification_services.dart';
import 'package:availalert/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> allUsers;
  const SearchPage(this.allUsers, {super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();

  // final List<Map<String, dynamic>> _recentUsers = [];
  List<Map<String, dynamic>> _searchedUsers = [];
  String _searchType = 'username'; // Default search type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.background,
        surfaceTintColor: MyTheme.background,
        centerTitle: true,
        title: const Text(
          'Search User',
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
            Theme(
              data: ThemeData(
                  radioTheme: RadioThemeData(
                      fillColor: MaterialStateProperty.all(MyTheme.accent))),
              child: Row(
                children: [
                  RadioMenuButton<String>(
                    value: 'username',
                    groupValue: _searchType,
                    onChanged: (value) {
                      setState(() {
                        _searchType = value!;
                      });
                    },
                    child: Text(
                      'Username',
                      style: TextStyle(color: MyTheme.textColor, fontSize: 16),
                    ),
                  ),
                  RadioMenuButton<String>(
                    value: 'email',
                    groupValue: _searchType,
                    onChanged: (value) {
                      setState(() {
                        _searchType = value!;
                      });
                    },
                    child: Text(
                      'Email',
                      style: TextStyle(color: MyTheme.textColor, fontSize: 16),
                    ),
                  ),
                  RadioMenuButton<String>(
                    value: 'phone',
                    groupValue: _searchType,
                    onChanged: (value) {
                      setState(() {
                        _searchType = value!;
                      });
                    },
                    child: Text(
                      'Phone',
                      style: TextStyle(color: MyTheme.textColor, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              inputFormatters: _searchType == "username"
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]'))]
                  : _searchType == "phone"
                      ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
                      : [],
              style: TextStyle(color: MyTheme.textColor, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Search Text',
                labelStyle: TextStyle(color: MyTheme.textColor, fontSize: 16),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 10),
            customButton(
              label: "Search",
              onTap: () => _searchUser(context),
              isExpanded: true,
            ),
            // ElevatedButton(
            //   onPressed: () => _searchUser(context),
            //   child: const Text('Search'),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     _storage.write('isLogedIn', false);
            //     Get.offAll(const LoginPage());
            //   },
            //   child: const Text('Logout'),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     // send notification from one device to another
            //     // Search for the user by selected search type
            //     QuerySnapshot query = await _firestore
            //         .collection('users/${_storage.read('phone')}/waiting')
            //         .get();

            //     if (query.docs.isNotEmpty) {
            //       _waitingList =
            //           query.docs.map((e) => e.get('FCMKey')).toList();
            //     }
            //     // notificationServices.getDeviceToken().then((value) async {
            //     var data = {
            //       // 'to': value.toString(),
            //       // 'to':
            //       //     'cq0b8wc20J4M-TPNZTSRR7:APA91bGFPnYFy6LJtiVjn8PJ6mh3QGcaGiZaol1cwVtLL7QMAU_N4g4CP_aBFvhO16j4UVDfDr2_jXJJ8B0ykTHOw4sXlsXpGGGYnCuhwCSUedijr8TwJjQG-T9g99g2gk7SO2fWLE3W',
            //       'registration_ids': _waitingList,
            //       'notification': {
            //         'title': 'Asif',
            //         'body': 'Subscribe to my channel',
            //         "sound": "jetsons_doorbell.mp3"
            //       },
            //       'android': {
            //         'notification': {
            //           'notification_count': 23,
            //         },
            //       },
            //       'data': {'type': 'msj', 'id': 'Asif Taj'}
            //     };

            //     await http.post(
            //         Uri.parse('https://fcm.googleapis.com/fcm/send'),
            //         body: jsonEncode(data),
            //         headers: {
            //           'Content-Type': 'application/json; charset=UTF-8',
            //           'Authorization':
            //               'key=AAAAkcXPa3M:APA91bHX10OuYsgouwlLvhI6Gc7i82o8oHk_CaP0Xjlmb6u3hJ-Gqfq7p5HM1rbnBt0gWtN2eqxLcCps-vUvpMEhybhlrKW9-Fb5YVKJUVdJR_6ALQV1utV-otTj-drTxlvqGguKKlYh'
            //         }).then((value) {
            //       if (kDebugMode) {
            //         print(value.body.toString());
            //       }
            //     }).onError((error, stackTrace) {
            //       if (kDebugMode) {
            //         print(error);
            //       }
            //     });
            //     // });
            //   },
            //   child: const Text('Available'),
            // ),
            const SizedBox(height: 10),
            _searchedUsers.isEmpty
                ? Text(
                    "No user",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: MyTheme.textColor, fontSize: 18),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _searchedUsers.length,
                      itemBuilder: (context, index) => Card(
                        color: MyTheme.cardBackground,
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
                                          fontSize: 14,
                                          color: MyTheme.textColor),
                                    ),
                                    Text(
                                      '${_searchedUsers[index]['username']}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: MyTheme.textColor),
                                    ),
                                    Text(
                                      '${_searchedUsers[index]['email']}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: MyTheme.textColor),
                                    ),
                                    Text(
                                      '${_searchedUsers[index]['phone']}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: MyTheme.textColor),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await _firestore
                                          .collection(
                                              'users/${_searchedUsers[index]['phone']}/waiting')
                                          .doc(_storage.read("phone")!)
                                          .set({
                                        'FCMKey': _storage.read("FCMKey")!,
                                        'firstName':
                                            _storage.read("firstName")!,
                                        'lastName': _storage.read("lastName")!,
                                        'username': _storage.read("username")!,
                                        'email': _storage.read("email")!,
                                        'phone': _storage.read("phone")!,
                                      });

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
                                        'notifyOn': true,
                                      }, SetOptions(merge: true));
                                    },
                                    icon: Icon(
                                      Icons.notification_add,
                                      color: MyTheme.textColor,
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
          ],
        ),
      ),
    );
  }

  Future<void> _searchUser(BuildContext context) async {
    if (_searchController.text.isEmpty) {
      showSnackBar(context, 'Search field is empty.');
      return;
    }

    if (_searchType == "username" &&
        !_isUsernameValid(_searchController.text)) {
      showSnackBar(
        context,
        'Invalid username format. Please use only letters (a-z), numbers, and underscores (_) with a minimum length of 6 characters.',
      );
      return;
    }

    if (_searchType == "email" && !_isEmailValid(_searchController.text)) {
      showSnackBar(
        context,
        'Invalid email format. Please enter a valid email address.',
      );
      return;
    }

    if (_searchType == "phone" &&
        !_isPhoneNumberValid(_searchController.text)) {
      showSnackBar(
        context,
        'Invalid phone number format. Please enter a valid phone number.',
      );
      return;
    }

    // Search for the user by selected search type
    QuerySnapshot query = await _firestore
        .collection('users')
        .where(_searchType, isEqualTo: _searchController.text)
        .get();

    if (query.docs.isNotEmpty) {
      // User found, display user details card
      // Map<String, dynamic> userData =
      //     query.docs.first.data() as Map<String, dynamic>;
      // _storeRecentUser(userData);
      // _showUserDetailsCard(userData);
      setState(() {
        _searchedUsers = query.docs
            .map((e) => {
                  'firstName': e.get('firstName'),
                  'lastName': e.get('lastName'),
                  'phone': e.get('phone'),
                  'email': e.get('email'),
                  'username': e.get('username')
                })
            .toList();
      });
    }
    // else {
    //   // User not found
    //   _showUserNotFound();
    // }
  }

  bool _isUsernameValid(String username) {
    // Username validation using a regular expression
    String pattern = r'^[a-z0-9_]{6,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(username);
  }

  bool _isEmailValid(String email) {
    // Email validation using a regular expression
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  bool _isPhoneNumberValid(String phoneNumber) {
    // Phone number validation using a regular expression
    String pattern = r'^[0-9]{10,10}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(phoneNumber);
  }
}
