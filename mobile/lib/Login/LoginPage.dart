import 'package:flutter/material.dart';
import 'package:sovkombank/HomePage.dart';
import 'package:sovkombank/Models/Person.dart';
import 'package:sovkombank/MyWidgets/TextFieldAuth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  Future<Person>? _futurePerson;
  static Future<PersonToken>? _futurePersonToken;
  final storage = new FlutterSecureStorage();

  void _takeToken(String token) async {
    await storage.write(key: 'jwt', value: token);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF462255),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello, user!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Welcome, please register',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 50),
                  TextFieldAuth(textController: _phoneController, hintText: "Phone"),
                  SizedBox(height: 25),
                  TextFieldAuth(textController: _passwordController, hintText: "Password"),
                  SizedBox(height: 25),
                  Padding(
                    padding:  const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: () async {
                        setState(()  {
                          _futurePersonToken = signInPerson(
                              _phoneController.text,
                              _passwordController.text,
                          );
                        });
                        var value = await _futurePersonToken;
                        await storage.write(key: 'jwt', value: value!.token);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage(storage: storage,)),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xA138023B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                              'Sign in',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}

