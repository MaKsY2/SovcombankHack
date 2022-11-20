import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sovkombank/Login/LoginPage.dart';
import 'package:sovkombank/MyWidgets/Account.dart';
import 'package:sovkombank/Themes/ThemesData.dart';
import 'package:sovkombank/Models/Person.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sovkombank/MyWidgets/AddAcountListView.dart';


class AccountsPage extends StatefulWidget {
  final FlutterSecureStorage storage;
  const AccountsPage({Key? key, required this.storage}) : super(key: key);

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  Future<Person>? futurePerson;
  Future<Person>? futureMoneyChange;
  Future<AllAccount>? futureAddAccount;

  late Future<PersonToken> futurePersonToken;

  int getRubbleAccount(List<Accounts> acc)
  {
    int amountRub = 0;
    acc.forEach((Accounts accounts) => (accounts.currency!.tag == 'RUB') ? amountRub = accounts.amount! : amountRub = amountRub);
    return amountRub;
  }

  int getRubbleAccountId(List<Accounts> acc)
  {
    int idRub = 0;
    acc.forEach((Accounts accounts) => (accounts.currency!.tag == 'RUB') ? idRub = accounts.id! : idRub = idRub);
    return idRub;
  }

  void fetchPersonAsync() async
  {
    futurePerson = fetchPerson(widget.storage);
    futureAddAccount = getAllAccounts(widget.storage);
  }

  @override
  void initState() {
    super.initState();
    fetchPersonAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Person> (
        future: futurePerson,
        builder: (context, AsyncSnapshot<Person> snapshot) {
          if (snapshot.hasData) {
            return Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:
                            [
                              Text(
                                'Мои счета',
                                style: TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: (){

                                  showDialog(context: context, builder: (BuildContext) {
                                    return BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 10.0,
                                          sigmaY: 10.0,
                                        ),
                                        child: AlertDialog(
                                          actions: [

                                            FutureBuilder<AllAccount>(
                                              future: futureAddAccount,
                                              builder: (context, /*AsyncSnapshot<AllAccount>*/ snapshot) {
                                                 //return Text('${snapshot.data!.curr![0].name}');
                                                return Container(
                                                  width: 600,
                                                  height: 775,
                                                  color: Colors.black,
                                                  child: ListView.builder(
                                                    //physics: NeverScrollableScrollPhysics(),
                                                    itemCount: 25,
                                                      itemBuilder: (context, index){
                                                        if (snapshot.hasData) {
                                                          return GestureDetector(
                                                            onTap: (){

                                                            },
                                                            child: AddAcountListView(
                                                              storage: widget.storage,
                                                                tagName: snapshot.data!.curr![index].tag!,
                                                                index: index,
                                                                tag: snapshot.data!.curr![index].name!),
                                                          );
                                                        }
                                                        else if (snapshot.hasError) {
                                                          return Text('${snapshot.error}');
                                                        }
                                                        else
                                                        {
                                                          return Center(child: CircularProgressIndicator());
                                                        }
                                                      }
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        ));
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[100],
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 40.0,
                                  ),
                                ),
                              )
                            ]
                        ),
                        SizedBox(height: 20),
                        //Rubles
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                                color: Color(0xff1a0061),
                                borderRadius: BorderRadius.circular(8.0)
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 24.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              'Рубль',
                                              style: ThemeStyles.cardMoney,
                                            ),
                                            Text(
                                              '${ getRubbleAccount(snapshot.data!.accounts!)} ₽',
                                              style: ThemeStyles.cardMoney,

                                            )
                                          ]
                                      ),
                                      SizedBox(height: 45),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              TextEditingController amountController = TextEditingController();
                                              showDialog(context: context, builder: (BuildContext) {
                                                return BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                      sigmaX: 10.0,
                                                      sigmaY: 10.0,
                                                    ),
                                                    child: AlertDialog(
                                                      actions: [
                                                        TextField(
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                          controller: amountController,
                                                          decoration: InputDecoration(
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.white),
                                                              borderRadius: BorderRadius.circular(12.0),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.purple),
                                                              borderRadius: BorderRadius.circular(12.0),
                                                            ),
                                                            hintText: 'Search',
                                                            hintStyle: TextStyle(
                                                              color: Colors.white,
                                                            ),
                                                            fillColor: Color(0xff140149),
                                                            filled: true,
                                                          ),
                                                        ),
                                                        TextButton(
                                                          child: Text('Ok'),
                                                          onPressed: (){
                                                            futureMoneyChange = changeMoney(getRubbleAccountId(snapshot.data!.accounts!), int.parse(amountController.text), widget.storage);
                                                          },
                                                        )
                                                      ],
                                                    ));
                                              });
                                            },
                                            child: Container(
                                              width: 100,
                                              height: 30,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15, vertical: 8),
                                              child: Text(
                                                'Пополнить',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                  color: Color(0xfffec55a),
                                                  borderRadius: BorderRadius
                                                      .circular(12.0)
                                              ),

                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: 100,
                                              height: 30,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30, vertical: 8),
                                              child: Text(
                                                'Снять',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                  color: Color(0xfffec55a),
                                                  borderRadius: BorderRadius
                                                      .circular(12.0)
                                              ),

                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                        //Search

                        SizedBox(
                          height: 55,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0),
                            child: TextField(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.purple),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                fillColor: Color(0xff140149),
                                filled: true,
                              ),
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 10.0),
                              child: Icon(
                                Icons.arrow_downward,
                              ),
                            ),
                          ],
                        ),

                        Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data!.accounts!.length,
                              itemBuilder: (context, index) {
                                return Account(
                                  tag: snapshot.data!.accounts![index].currency!.name!, cntAccount: 2400, index: index, amount: snapshot.data!.accounts![index].amount!,);
                              }),
                        ),
                      ]
                  ),
                ),
              ),
            );
          }
          else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          else
          {
            return Center(child: CircularProgressIndicator());
          }
        }
    ),
    );
  }
}