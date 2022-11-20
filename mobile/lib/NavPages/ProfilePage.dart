import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
      image: DecorationImage(
      image: AssetImage('assets/back.jpg'),
      fit: BoxFit.cover,
      ),
      ),
    child:Center(
        child: Column(
          children: [
            SizedBox(height: 100,),
            Container(
              //alignment: ,
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
              ),
              child: Image(
                image: AssetImage("assets/pepa_2"),

              ),
            ),
            SizedBox(height: 10),
            Text(
                '@NickName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            )
          ],
        ),
        ),
      ),
    );
  }
}
