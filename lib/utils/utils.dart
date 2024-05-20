import 'dart:convert';

import 'package:availalert/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

Widget customButton(
    {String label = "", VoidCallback? onTap, bool isExpanded = false}) {
  return Material(
    borderRadius: BorderRadius.circular(8),
    color: MyTheme.cardBackground,
    child: InkWell(
      onTap: onTap,
      splashColor: MyTheme.buttonRippleEffectColor,
      borderRadius: BorderRadius.circular(8),
      child: isExpanded
          ? Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Text(
                label,
                style: MyTheme.buttonTextStyle,
              ),
            ) 
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
              child: Text(
                label,
                style: MyTheme.buttonTextStyle,
              ),
            ),
    ),
  );
}

// Function to show the error dialog with a dynamic message
void showErrorDialog(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

bool checkMainLocation(BuildContext context, VoidCallback setCurrIndCallback) {
  if (GetStorage().read("mainLoc") == null) {
    showAlertDialog(context,
        content: "Add Main Location or Temporary Location.",
        actionsName: [
          "OK"
        ],
        actionsOnClick: [
          () {
            setCurrIndCallback();
          }
        ]);
    return false;
  }

  return true;
}

// Function to show the alert dialog
void showAlertDialog(
  BuildContext context, {
  String title = "",
  String content = "",
  List<String>? actionsName,
  List<VoidCallback>? actionsOnClick,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (actionsName != null && actionsName.isNotEmpty)
            for (int index = 0; index < actionsName.length; index++)
              TextButton(
                onPressed: () {
                  // Invoke the callback function
                  actionsOnClick?[index].call();
                  Navigator.of(context).pop();
                },
                child: Text(actionsName[index]),
              )
          else
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
        ],
      );
    },
  );
}

Future<bool> sendNotification({
  String? to,
  List<dynamic>? ids,
  String title = "AvailAlert",
  String description = "Welcome to AvailAlert",
}) async {
  var data = {
    if (ids == null) 'to': to,
    if (to == null) 'registration_ids': ids,
    'notification': {
      'title': title,
      'body': description,
      // "sound": "jetsons_doorbell.mp3"
    },
    // 'data': {
    //   'type': 'msj',
    //   'id': 'Asif Taj',
    // },
    // 'android': {
    //   'notification': {
    //     'notification_count': 23,
    //   },
    // },
  };

  try {
    var response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'key=AAAAkcXPa3M:APA91bHX10OuYsgouwlLvhI6Gc7i82o8oHk_CaP0Xjlmb6u3hJ-Gqfq7p5HM1rbnBt0gWtN2eqxLcCps-vUvpMEhybhlrKW9-Fb5YVKJUVdJR_6ALQV1utV-otTj-drTxlvqGguKKlYh'
      },
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(response.body.toString());
      }
      return true;
    } else {
      if (kDebugMode) {
        print('HTTP request failed with status: ${response.statusCode}');
      }
      return false;
    }
  } catch (error) {
    if (kDebugMode) {
      print(error);
    }
    return false;
  }
}

class FirstLastNameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove numbers, spaces, dots, and plus sign from the input
    String filteredText = newValue.text.replaceAll(RegExp(r'[0-9\s\.\+]'), '');

    return newValue.copyWith(
        text: filteredText,
        selection: TextSelection.collapsed(offset: filteredText.length));
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove numbers, spaces, dots, and plus sign from the input
    String filteredText = newValue.text.replaceAll(RegExp(r'[\.\+]'), '');

    return newValue.copyWith(
        text: filteredText,
        selection: TextSelection.collapsed(offset: filteredText.length));
  }
}

class UsernameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove numbers, spaces, dots, and plus sign from the input
    String filteredText = newValue.text.replaceAll(RegExp(r'[\.\+]'), '');

    return newValue.copyWith(
        text: filteredText,
        selection: TextSelection.collapsed(offset: filteredText.length));
  }
}
