import 'package:availalert/pages/login_page.dart';
import 'package:availalert/theme.dart';
import 'package:availalert/utils/internet_service.dart';
import 'package:availalert/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

  final _storage = GetStorage();
  late TextEditingController _mainLocController;

  @override
  void initState() {
    super.initState();
    _mainLocController =
        TextEditingController(text: _storage.read("mainLoc") ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.background,
        surfaceTintColor: MyTheme.background,
        centerTitle: true,
        title: const Text(
          "Profile Page",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: MyTheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity),
              Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MyTheme.accent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _storage.read("firstName")[0] + _storage.read("lastName")[0],
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _storage.read("firstName") + " " + _storage.read("lastName"),
                style: TextStyle(color: MyTheme.textColor, fontSize: 24),
              ),
              Text(
                "@${_storage.read("username")!}",
                style: TextStyle(color: MyTheme.textColor, fontSize: 24),
              ),
              const SizedBox(height: 20),
              Text(
                _storage.read("phone")!,
                style: TextStyle(color: MyTheme.textColor, fontSize: 16),
              ),
              Text(
                _storage.read("email")!,
                style: TextStyle(color: MyTheme.textColor, fontSize: 16),
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mainLocController,
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      decoration: InputDecoration(
                        labelText: "Main Location",
                        border: const OutlineInputBorder(),
                        labelStyle:
                            TextStyle(color: MyTheme.textColor, fontSize: 16),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                      style: TextStyle(color: MyTheme.textColor, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if ((_storage.read("mainLoc") ?? "") !=
                              _mainLocController.text &&
                          await InternetService.checkInternet(context)) {
                        print("onTapOutside called");
                        EasyLoading.show(status: 'Please Wait ...');
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_storage.read("phone"))
                            .set({'mainLoc': _mainLocController.text},
                                SetOptions(merge: true)).then((value) {
                          _storage.write("mainLoc", _mainLocController.text);
                          EasyLoading.dismiss();
                          showSnackBar(
                              context, "Main location saved successfully.");
                        }).onError((error, stackTrace) {
                          EasyLoading.dismiss();
                          showSnackBar(
                              context, "An error occurred. Please try again.");
                        });
                      }
                    },
                    icon: Icon(
                      Icons.save_as,
                      size: 34,
                      color: MyTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              customButton(
                  label: "Logout",
                  onTap: () {
                    _storage.erase();
                    _storage.write('isLogedIn', false);
                    Get.offAll(const LoginPage());
                  },
                  isExpanded: true),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
