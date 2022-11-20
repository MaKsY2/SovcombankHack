import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sovkombank/Themes/ThemesData.dart';

class BuyTicket extends StatelessWidget {

  BuyTicket({Key? key, required this.tag, required this.rate});
  String tag = "USD";
  double rate = 0.25;
  final List<String> tagsName = [
    "usa.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          print(Text('data'));

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
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Image(
                        image: AssetImage("assets/pepa_1"),
                        width: 50,
                        height: 50,
                      ),
                    ),
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
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 25.0),
                      child: Column(
                          children: [
                            Text(
                              '$rate',
                              style: ThemeStyles.cardMoney,
                            ),
                          ]
                      ),
                    )

                  ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}

