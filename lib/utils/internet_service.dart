import 'dart:io';

import 'package:availalert/theme.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetService {
  static late Connectivity _connectivity;
  static void init() {
    _connectivity = Connectivity();

    // Listen for connectivity changes
    // _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
    //   _checkInternet();
    // });
  }

  static Future<bool> checkInternet(BuildContext context,
      {bool closeOverlays = false}) async {
    return await _connectivity.checkConnectivity().then((value) async {
      if (value == ConnectivityResult.none) {
        // If no internet, show a dialog and attempt to retry
        await _showNoInternetDialog(context, closeOverlays: closeOverlays);
        return false;
      } else {
        // Check for actual internet connectivity
        if (!await _hasInternetConnection()) {
          // If no internet, show a dialog and attempt to retry
          await _showNoInternetDialog(context, closeOverlays: closeOverlays);
          return false;
        } else {
          // Navigator.pop(context);
          // Get.back();
          return true;
        }
      }
    });
  }

  static Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<void> _showNoInternetDialog(BuildContext context,
      {bool closeOverlays = false}) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Disable tap outside dismiss
      builder: (context) => AlertDialog(
        backgroundColor: MyTheme.cardBackground,
        actionsPadding: const EdgeInsets.only(
            left: 24.0, top: 0.0, right: 24.0, bottom: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('No Internet Connection',
            style: TextStyle(
                color: MyTheme.textColor, fontWeight: FontWeight.bold)),
        content: Text('Please check your internet connection.',
            style: TextStyle(color: MyTheme.textColor)),
        actions: [
          TextButton(
            onPressed: () async {
              // Retry the internet check
              // Navigator.pop(context);
              Get.back(closeOverlays: closeOverlays);
              await checkInternet(context);
              // Get.back();
            },
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            )),
            child: Text('Retry',
                style: TextStyle(
                    color: MyTheme.textColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
