import 'dart:async';

import 'package:availalert/pages/availability_page.dart';
import 'package:availalert/pages/history_page.dart';
import 'package:availalert/pages/profile_page.dart';
import 'package:availalert/pages/search_page.dart';
import 'package:availalert/pages/waiting_page.dart';
import 'package:availalert/theme.dart';
import 'package:availalert/utils/internet_service.dart';
import 'package:availalert/utils/notification_services.dart';
import 'package:availalert/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currInd = 2;

  NotificationServices notificationServices = NotificationServices();

  final PageController controller =
      PageController(initialPage: 2, keepPage: true);

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();

    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token');
        print(value);
      }
      if (GetStorage().read("FCMKey") != value) {
        notificationServices.storeFCMTocken();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const HistoryPage(key: PageStorageKey('historyPage')),
      WaitingPage(
          key: const PageStorageKey('waitingPage'),
          setCurrIndCallback: () => setState(() => currInd = 4)),
      AvailabilityPage(
          key: const PageStorageKey('availabilityPage'),
          setCurrIndCallback: () => setState(() => currInd = 4)),
      const SearchPage(key: PageStorageKey('searchPage')),
      const ProfilePage(key: PageStorageKey('profilePage'))
    ];

    return Scaffold(
      body: PageView(
        /// Wrapping the tabs with PageView
        controller: controller,
        children: pages,
        onPageChanged: (index) {
          setState(() {
            currInd = index;
          });
        },
      ),
      bottomNavigationBar: GNav(
        selectedIndex: currInd,
        backgroundColor: MyTheme.cardBackground,
        // backgroundColor: const Color.fromRGBO(214, 214, 214, 1),
        color: MyTheme.accent,
        activeColor: Colors.black,
        tabBackgroundColor: MyTheme.accent,
        tabMargin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        gap: 10,
        onTabChange: (index) {
          controller.jumpToPage(index);
          setState(() {
            currInd = index;
          });
        },
        tabs: const [
          GButton(
            icon: Icons.history,
            text: "History",
          ),
          GButton(
            icon: Icons.list_alt,
            text: "Waiting",
          ),
          GButton(
            icon: Icons.access_time,
            text: "Status",
          ),
          GButton(
            icon: Icons.search,
            text: "Search",
          ),
          GButton(
            icon: Icons.account_circle_outlined,
            text: "Profile",
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: currInd,
      //   onTap: (value) {
      //     setState(() {
      //       currInd = value;
      //     });
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      //     BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
      //     BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Waiting"),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.account_circle_outlined), label: "Profile"),
      //   ],
      // ),
    );
  }
}
