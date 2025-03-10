import 'package:flutter/material.dart';

class OrangeSquareText extends StatelessWidget {
  final String text;
  final bool primary;

  const OrangeSquareText({super.key, required this.text, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Container(
          padding: EdgeInsets.fromLTRB(4, 6, 4, 1),
          color: primary ? Color(0xFFFF6600) : Colors.black,
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lab',
              height: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        ));
  }
}
