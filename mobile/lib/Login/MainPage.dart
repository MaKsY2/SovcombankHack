import 'package:flutter/material.dart';
import 'package:sovkombank/Models/Person.dart';
import 'package:sovkombank/HomePage.dart';
import 'RegisterPage.dart';
import 'LoginPage.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginPage();
  }
}
