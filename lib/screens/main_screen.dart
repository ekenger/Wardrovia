import 'package:Wardrovia/screens/home_page.dart';
import 'package:Wardrovia/screens/notifications_page.dart';
import 'package:Wardrovia/screens/orders_page.dart';
import 'package:Wardrovia/screens/profile_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  final List<Widget> pages = [
    HomePage(),
    NotificationsPage(),
    OrdersPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon:
                selectedIndex == 0
                    ? Image.asset(
                      'assets/icons/home_selected.png',
                      height: 40,
                      width: 40,
                    )
                    : Image.asset(
                      'assets/icons/home.png',
                      height: 40,
                      width: 40,
                    ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:
                selectedIndex == 1
                    ? Image.asset(
                      'assets/icons/notifications_selected.png',
                      height: 40,
                      width: 40,
                    )
                    : Image.asset(
                      'assets/icons/notifications.png',
                      height: 40,
                      width: 40,
                    ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:
                selectedIndex == 2
                    ? Image.asset(
                      'assets/icons/orders_selected.png',
                      height: 40,
                      width: 40,
                    )
                    : Image.asset(
                      'assets/icons/orders.png',
                      height: 40,
                      width: 40,
                    ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:
                selectedIndex == 3
                    ? Image.asset(
                      'assets/icons/profile_selected.png',
                      height: 40,
                      width: 40,
                    )
                    : Image.asset(
                      'assets/icons/profile.png',
                      height: 40,
                      width: 40,
                    ),
            label: '',
          ),
        ],
      ),
    );
  }
}
