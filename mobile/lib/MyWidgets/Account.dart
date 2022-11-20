import 'package:flutter/material.dart';
import 'package:sovkombank/Themes/ThemesData.dart';

class Account extends StatelessWidget {


  int cntAccount = 2400;
  int index = 0;
  String tag = "";
  int amount = 0;


  Account({Key? key,
    required this.tag,
    required this.cntAccount,
    required this.index,
    required this.amount,
  }) : super(key: key);

  final List<String> tagsName = [
    "usa.png",
    "jap.png",
    "uk.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image(
                        image: AssetImage("assets/pepa_1"),
                        width: 50,
                        height: 50,
                      ),
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
                      tag.substring(0, tag.length > 15 ? 15 : tag.length),
                      style: ThemeStyles.cardMoney,
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 25.0),
                    child: Column(
                        children: [
                          Text(
                            '$amount',
                            style: ThemeStyles.cardMoney,
                          ),
                          //SizedBox(height: 10,),
                          Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: Text(
                              '$amount',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ]
                    ),
                  )

                ]
            ),
          ],
        ),
      ),
    );
  }
}