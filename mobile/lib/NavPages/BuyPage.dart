import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sovkombank/MyWidgets/BuyTicket.dart';

import '../Models/Person.dart';

class BuyPage extends StatefulWidget {
  final FlutterSecureStorage storage;
  const BuyPage({Key? key, required this.storage}) : super(key: key);

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  Future<allShowRate>? futureShowRate;

  void fetchRateAsync() async
  {
    futureShowRate = fetchBuyTickets(widget.storage);
  }

  @override
  void initState() {
    super.initState();
    fetchRateAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<allShowRate>(
          future: futureShowRate,
          builder: (context, AsyncSnapshot<allShowRate> snapshot) {
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
                child: ListView.builder(
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return BuyTicket(tag: snapshot.data!.show![index].tag!, rate: snapshot.data!.show![index].rate!);
                    }),
              );
            }
            else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            else {
              return Center(child: CircularProgressIndicator());
            }
          }
      ),
    );
  }
}
