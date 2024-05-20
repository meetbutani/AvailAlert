// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:availalert/pages/home_page.dart';
import 'package:availalert/pages/registration_page.dart';
import 'package:availalert/theme.dart';
import 'package:availalert/utils/internet_service.dart';
import 'package:availalert/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameOrEmailOrPhoneController =
      TextEditingController();
  // TextEditingController(text: "meetbutani");
  final TextEditingController _passwordController = TextEditingController();
  // TextEditingController(text: "Meet@123");

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  String _searchType = 'username'; // Default search type
  bool passVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.background,
        surfaceTintColor: MyTheme.background,
        centerTitle: true,
        title: const Text(
          'User Login',
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
                        style:
                            TextStyle(color: MyTheme.textColor, fontSize: 16),
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
                        style:
                            TextStyle(color: MyTheme.textColor, fontSize: 16),
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
                        style:
                            TextStyle(color: MyTheme.textColor, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              // TextField(
              //   controller: _usernameOrEmailOrPhoneController,
              //   inputFormatters: _searchType == "username"
              //       ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]'))]
              //       : _searchType == "phone"
              //           ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
              //           : [],
              //   decoration: const InputDecoration(labelText: 'Search Text'),
              // ),
              const SizedBox(height: 10),
              _buildTextField(
                _usernameOrEmailOrPhoneController,
                _searchType == "username"
                    ? 'Username'
                    : _searchType == "email"
                        ? 'Email'
                        : 'Phone',
                inputFormatters: _searchType == "username"
                    ? [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9_]'))
                      ]
                    : _searchType == "phone"
                        ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
                        : [],
              ),
              const SizedBox(height: 20),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              const SizedBox(height: 50),
              customButton(
                  label: 'Login',
                  onTap: () => _loginUser(context),
                  isExpanded: true),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: MyTheme.textColor),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const RegistrationPage(),
                          preventDuplicates: true);
                    },
                    style:
                        TextButton.styleFrom(padding: const EdgeInsets.all(5)),
                    child: Text(
                      "Register now",
                      style: TextStyle(color: MyTheme.accent),
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

  Widget _buildTextField(TextEditingController controller, String labelText,
      {List<TextInputFormatter>? inputFormatters, bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          suffixIcon: obscureText
              ? IconButton(
                  onPressed: () => setState(() => passVisible = !passVisible),
                  icon: Icon(passVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                )
              : null,
          labelText: labelText,
          labelStyle: TextStyle(color: MyTheme.textColor),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey))),
      obscureText: obscureText && !passVisible,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      inputFormatters: inputFormatters,
      style: TextStyle(color: MyTheme.textColor),
    );
  }

  Future<void> _loginUser(BuildContext context) async {
    // Check if the username, email, or phone and password match
    String usernameOrEmailOrPhone = _usernameOrEmailOrPhoneController.text;
    String password = _passwordController.text;

    if (usernameOrEmailOrPhone.isEmpty || password.isEmpty) {
      showSnackBar(context, 'Please fill in all fields.');
      return;
    }

    if (_searchType == "username" &&
        !_isUsernameValid(usernameOrEmailOrPhone)) {
      showSnackBar(
        context,
        'Invalid username format. Please use only letters (a-z), numbers, and underscores (_) with a minimum length of 6 characters.',
      );
      return;
    }

    if (_searchType == "email" && !_isEmailValid(usernameOrEmailOrPhone)) {
      showSnackBar(
        context,
        'Invalid email format. Please enter a valid email address.',
      );
      return;
    }

    if (_searchType == "phone" &&
        !_isPhoneNumberValid(usernameOrEmailOrPhone)) {
      showSnackBar(
        context,
        'Invalid phone number format. Please enter a valid phone number.',
      );
      return;
    }

    if (!_isPasswordValid(password)) {
      showSnackBar(
        context,
        'Password does not meet the requirements.\n'
        '1 Lower case char.\n1 Upper case char.\n1 Number.\n'
        '1 Special char.\nMin length 6.\nMax length 16.',
      );
      return;
    }

    if (!await InternetService.checkInternet(context)) {
      return;
    }

    EasyLoading.show(status: 'Please Wait ...');

    // Search for the user by selected search type
    await _firestore
        .collection('users')
        .where(_searchType, isEqualTo: usernameOrEmailOrPhone)
        .get()
        .then((query) {
      if (query.docs.isNotEmpty) {
        // User found, check password
        String storedPassword = query.docs.first['password'];
        String enteredPassword = _hashPassword(_passwordController.text);

        if (storedPassword == enteredPassword) {
          // Passwords match, user is logged in
          _storeLoggedInUserData(query.docs.first.data());
          EasyLoading.dismiss();
          // showSnackBar(context, 'User logged in successfully!');
          Get.offAll(const HomePage());
          // Navigate to the home screen or perform other actions
        } else {
          // Passwords do not match
          EasyLoading.dismiss();
          showSnackBar(context, 'Incorrect password.');
        }
      } else {
        // User not found
        EasyLoading.dismiss();
        showSnackBar(context, 'User not found.');
        // showSnackBar(context, "An error occurred. Please try again.");
      }
    }).onError((error, stackTrace) {
      EasyLoading.dismiss();
      showSnackBar(context, "An error occurred. Please try again.");
    });
  }

  bool _isPasswordValid(String password) {
    // Password validation using a regular expression
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])([A-Za-z\d!@#$%^&*(),.?":{}|<>]){6,16}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
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

  String _hashPassword(String password) {
    // Hash the password using SHA-256 (similar to registration)
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _storeLoggedInUserData(Map<String, dynamic> userData) {
    // Store user details locally using GetStorage
    _storage.write('firstName', userData["firstName"]);
    _storage.write('lastName', userData["lastName"]);
    _storage.write('email', userData["email"]);
    _storage.write('phone', userData["phone"]);
    _storage.write('username', userData["username"]);
    _storage.write('isLogedIn', true);
    _storage.write('isAvailable', userData["isAvailable"]);
    _storage.write('mainLoc', userData["mainLoc"] ?? '');
  }
}
