import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFFFF6600),
                  width: 24.0,
                ),
              ),
              child: Center(
                child: Image.asset(
                  "assets/images/mobgenfest_logo.png",
                  height: 150,
                  width: 150,
                ),
              ),
            )),
            SizedBox(
              height: 8,
            ),
            Text(
              'Próximamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 40,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ));
  }
}
