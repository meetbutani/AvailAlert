import 'package:availalert/pages/home_page.dart';
import 'package:availalert/pages/login_page.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CentralPage extends StatefulWidget {
  const CentralPage({super.key});

  @override
  State<CentralPage> createState() => _CentralPageState();
}

class _CentralPageState extends State<CentralPage> {
  final Connectivity _connectivity = Connectivity();
  late BuildContext pagecontext;

  @override
  void initState() {
    super.initState();
    _checkInternet();
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _checkInternet();
    });
  }

  @override
  Widget build(BuildContext context) {
    pagecontext = context;

    return GetStorage().read("isLogedIn") ?? false
        ? const HomePage()
        : const LoginPage();
  }

  Future<void> _checkInternet() async {
    await _connectivity.checkConnectivity().then((value) async {
      if (value == ConnectivityResult.none) {
        // If no internet, show a dialog and attempt to retry
        await _showInternetDialog();
      } else {
        // Navigator.pop(context);
        Get.back();
      }
    });
  }

  Future<void> _showInternetDialog() async {
    await showDialog(
      context: pagecontext,
      barrierDismissible: false, // Disable tap outside dismiss
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection.'),
          actions: [
            TextButton(
              onPressed: () async {
                // Retry the internet check
                // Navigator.pop(context);
                Get.back();

                await _checkInternet();
                // Get.back();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
