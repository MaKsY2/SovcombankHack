import 'package:flutter/material.dart';
import 'package:sovkombank/Models/Person.dart';
import 'package:sovkombank/MyWidgets/TextFieldAuth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _phoneController = TextEditingController();
  final _passportController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _passwordController = TextEditingController();
  Future<Person>? _futurePerson;


  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _passportController.dispose();
    _firstNameController.dispose();
    _secondNameController.dispose();
    _fatherNameController.dispose();
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
                  TextFieldAuth(textController: _passportController, hintText: "Passport"),
                  SizedBox(height: 25),
                  TextFieldAuth(textController: _firstNameController, hintText: "First Name"),
                  SizedBox(height: 25),
                  TextFieldAuth(textController: _secondNameController, hintText: "Second Name"),
                  SizedBox(height: 25),
                  TextFieldAuth(textController: _fatherNameController, hintText: "Fathers Name"),
                  SizedBox(height: 25),
                  TextFieldAuth(textController: _passwordController, hintText: "Password"),
                  SizedBox(height: 25),
                  Padding(
                    padding:  const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                         _futurePerson = createPerson (
                             _phoneController.text,
                           _passportController.text,
                           _firstNameController.text,
                           _secondNameController.text,
                           _fatherNameController.text,
                           _passwordController.text,
                          );
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xA138023B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                              'Register',
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

