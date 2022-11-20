import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'NavPages/AccountsPage.dart';
import 'NavPages/BuyPage.dart';
import 'NavPages/ProfilePage.dart';
import 'NavPages/TransactionPages.dart';

class HomePage extends StatefulWidget {
  final FlutterSecureStorage storage;
  const HomePage({Key? key, required this.storage}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState(this.storage);
}



class _HomePageState extends State<HomePage> {

  static FlutterSecureStorage? storage;

  _HomePageState(FlutterSecureStorage temp_storage) {
    storage = temp_storage;
    _pages = [
      ProfilePage(),
      TransactionPage(storage: storage!),
      BuyPage(storage: storage!),
      AccountsPage(storage: storage!),
    ];
  }

  int _navPageIndex = 0;
  void _navBarChanger(int index) {
    setState(() {
      _navPageIndex = index;
    });

  }

  List<Widget>? _pages;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: GNav(
          backgroundColor: Color(0xff3500d4),
          rippleColor: Colors.grey[800]!,
          tabBorderRadius: 15,
          gap: 8,
          onTabChange: _navBarChanger,
          curve: Curves.easeOutExpo,
          tabActiveBorder: Border.all(color: Colors.black, width: 2),
          tabBackgroundColor: Color(0xff3550d4),
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          tabs:
          [
            GButton(
                icon: Icons.person
            ),
            GButton(
                icon: Icons.compare_arrows
            ),
            GButton(
                icon: Icons.attach_money
            ),
            GButton(
                icon: Icons.add_task_sharp
            ),
          ],

      ),
      backgroundColor: Colors.white,
      body: _pages![_navPageIndex],
    );
  }
}
