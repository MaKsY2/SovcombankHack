import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sovkombank/Themes/ThemesData.dart';

import '../Models/Person.dart';

class AddAcountListView extends StatelessWidget {
  FlutterSecureStorage storage;
  Future<Accounts>? futureAddCurrency;
  AddAcountListView({Key? key,
    required this.tagName,
    required this.storage,
    required this.tag,
    required this.index,
  }) : super(key: key);

  int index = 0;
  String tag = "Доллар";
  String tagName = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          futureAddCurrency = addNewAccount(tagName, 1, storage);

        },
        child: Container(
          height: 80,
          decoration: BoxDecoration(
              color: Color(0xff1a0061),
              borderRadius: BorderRadius.circular(20.0)
          ),
          child: Column(
            children: [

              Row(
                  children: [
                    //picture
                    //...

                    //Name
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 27.0,
                      ),
                      child: Text(
                        tag,
                        style: ThemeStyles.cardMoney,
                      ),
                    ),
                  ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}

