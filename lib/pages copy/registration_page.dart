// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:availalert/theme.dart';
import 'package:availalert/utils/internet_service.dart';
import 'package:availalert/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _firstNameController =
      TextEditingController(text: "Vedant");
  final TextEditingController _lastNameController =
      TextEditingController(text: "Bharad");
  final TextEditingController _usernameController =
      TextEditingController(text: "vedantbharad");
  final TextEditingController _emailController =
      TextEditingController(text: "vedant.bharad@gmail.com");
  final TextEditingController _phoneController =
      TextEditingController(text: "8780521033");
  final TextEditingController _passwordController =
      TextEditingController(text: "Vedant@123");

  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.background,
        surfaceTintColor: MyTheme.background,
        centerTitle: true,
        title: const Text(
          'User Registration',
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: MyTheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                _firstNameController,
                'First Name',
                [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _lastNameController,
                'Last Name',
                [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _usernameController,
                'Username',
                [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]'))],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _emailController,
                'Email',
                [],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _phoneController,
                'Phone Number',
                [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                _passwordController,
                'Password',
                [],
                obscureText: true,
                nextFocus: false, // Set nextFocus to null for the last field
              ),
              const SizedBox(height: 40),
              customButton(
                label: 'Register',
                onTap: () async => await _registerUser(context),
                isExpanded: true,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(color: MyTheme.textColor),
                  ),
                  TextButton(
                    onPressed: () {
                      // Get.to(() => const LoginPage());
                      Get.back();
                    },
                    style:
                        TextButton.styleFrom(padding: const EdgeInsets.all(5)),
                    child: Text(
                      "Login now",
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
      List<TextInputFormatter> inputFormatters,
      {TextInputType? keyboardType,
      bool obscureText = false,
      bool nextFocus = true}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: MyTheme.textColor),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey))),
      obscureText: obscureText,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      textInputAction: nextFocus ? TextInputAction.next : TextInputAction.done,
      style: TextStyle(color: MyTheme.textColor),
    );
  }

  Future<void> _registerUser(BuildContext context) async {
    if (!await InternetService.checkInternet(context) ||
        !(await _validateFields())) {
      return;
    }

    EasyLoading.show(status: 'Please Wait ...');

    // Hash the password before storing it in Firestore
    String hashedPassword = _hashPassword(_passwordController.text);

    await _firestore.collection('users').doc(_phoneController.text).set({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'username': _usernameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'isAvailable': false,
      'mainLoc': '',
      'password': hashedPassword,
    }).then((value) {
      EasyLoading.dismiss();
      // Get.to(() => const LoginPage());
      Get.back();
      showSnackBar(context, 'User registered successfully!');
    }).onError((error, stackTrace) {
      EasyLoading.dismiss();
      showSnackBar(context, "An error occurred. Please try again.");
    });
  }

  Future<bool> _validateFields() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      showSnackBar(context, 'Please fill in all fields.');
      return false;
    }

    if (!_isUsernameValid(_usernameController.text)) {
      showSnackBar(
        context,
        'Invalid username format. Please use only letters (a-z), numbers, and underscores (_) with a minimum length of 6 characters.',
      );
      return false;
    }

    if (!_isEmailValid(_emailController.text)) {
      showSnackBar(
        context,
        'Invalid email format. Please enter a valid email address.',
      );
      return false;
    }

    if (!_isPhoneNumberValid(_phoneController.text)) {
      showSnackBar(
        context,
        'Invalid phone number format. Please enter a valid phone number.',
      );
      return false;
    }

    if (!_isPasswordValid(_passwordController.text)) {
      showSnackBar(context,
          'Password does not meet the requirements.\n1 Lower case char.\n1 Upper case char.\n1 Number.\n1 Special char.\nMin length 6.\nMax length 16.');
      return false;
    }

    EasyLoading.show(status: 'Please Wait ...');

    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where(Filter.or(
            Filter("username", isEqualTo: _usernameController.text),
            Filter("email", isEqualTo: _emailController.text),
            Filter("phone", isEqualTo: _phoneController.text),
          ))
          .get();

      EasyLoading.dismiss();

      if (query.docs.isNotEmpty) {
        Map<String, dynamic> res =
            query.docs.first.data() as Map<String, dynamic>;

        if (res['username'] == _usernameController.text) {
          showSnackBar(context,
              'Username is not unique. Please choose a different value.');
          return false;
        }

        if (res['email'] == _emailController.text) {
          showSnackBar(
              context, 'Email is not unique. Please choose a different value.');
          return false;
        }

        if (res['phone'] == _phoneController.text) {
          showSnackBar(context,
              'Phone no is not unique. Please choose a different value.');
          return false;
        }

        return false;
      } else {
        return true;
      }
    } catch (error) {
      EasyLoading.dismiss();

      if (error == "Bad state: No element") {
        return false;
      } else {
        // print("Query catch else: $error");
        showSnackBar(context, "An error occurred. Please try again.");
        return false;
      }
    }

    // bool? isUsernameUnique =
    //     await _checkUniqueField('username', _usernameController.text);

    // if (isUsernameUnique == null) {
    //   return false;
    // } else if (!isUsernameUnique) {
    //   EasyLoading.dismiss();
    //   showSnackBar(
    //     context,
    //     'Username is not unique. Please choose a different value.',
    //   );
    //   return false;
    // }

    // bool? isEmailUnique =
    //     await _checkUniqueField('email', _emailController.text);

    // if (isEmailUnique == null) {
    //   return false;
    // } else if (!isEmailUnique) {
    //   EasyLoading.dismiss();
    //   showSnackBar(
    //     context,
    //     'Email is not unique. Please choose a different value.',
    //   );
    //   return false;
    // }

    // bool? isPhoneUnique =
    //     await _checkUniqueField('phone', _phoneController.text);

    // if (isPhoneUnique == null) {
    //   return false;
    // } else if (!isPhoneUnique) {
    //   EasyLoading.dismiss();
    //   showSnackBar(
    //     context,
    //     'Phone number is not unique. Please choose a different value.',
    //   );
    //   return false;
    // }

    // EasyLoading.dismiss();
    // return true;
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

  // Future<bool?> _checkUniqueField(String field, String value) async {
  //   // Check if the given field has a unique value in the Firestore collection
  //   try {
  //     // QuerySnapshot query = await _firestore
  //     //     .collection('users')
  //     //     .where(field, isEqualTo: value)
  //     //     .get();

  //     QuerySnapshot query = await _firestore
  //         .collection('users')
  //         .where(Filter.or(
  //           Filter("username", isEqualTo: _usernameController.text),
  //           Filter("email", isEqualTo: _emailController.text),
  //           Filter("phone", isEqualTo: _phoneController.text),
  //         ))
  //         .get();

  //     print("Query try $field: ${query.docs}");

  //     // EasyLoading.dismiss();
  //     return query.docs.isEmpty;
  //   } catch (error) {
  //     EasyLoading.dismiss();

  //     if (error == "Bad state: No element") {
  //       return false;
  //     } else {
  //       // Handle other errors
  //       // print("Unexpected Error: $error");
  //       // showSnackBar(context, "An unexpected error occurred. Please try again.");
  //       // print("Query catch else: $error");
  //       showSnackBar(context, "An error occurred. Please try again.");
  //       return null;
  //     }
  //   }
  // }

  bool _isPasswordValid(String password) {
    // Password validation using a regular expression
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])([A-Za-z\d!@#$%^&*(),.?":{}|<>]){6,16}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  String _hashPassword(String password) {
    // Hash the password using SHA-256
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
