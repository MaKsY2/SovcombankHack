import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sovkombank/MyWidgets/Transaction.dart';

class TransactionPage extends StatefulWidget {
  final FlutterSecureStorage storage;
  const TransactionPage({Key? key, required this.storage}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
          padding: const EdgeInsets.only(right: 200),
              child: Text(
                'История',
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ),
              SizedBox(height: 10),
              Container(
                height: 730,
                width: 600,
                child: ListView.builder(
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return Transaction();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}