import 'dart:async';

import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobgenfest/alternate_wrap.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Timer _timer;
  Duration timeLeft = _calculateTimeLeft();

  static Duration _calculateTimeLeft() {
    DateTime targetDate = DateTime(2025, 3, 12, 12, 0, 0);
    return targetDate.difference(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft = _calculateTimeLeft();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(8),
          child: Image.asset("assets/images/mobgenfest_logo.png"),
        ),
        actions: [],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "30|31 Mayo | 1 Junio 2025",
                          style: TextStyle(
                              letterSpacing: 2.0, fontSize: 30, fontFamily: 'Lab', color: const Color(0xFFFF6600)),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text("Ledoño",
                            style: TextStyle(
                                fontSize: 30,
                                fontFamily: 'Lab',
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFF6600))),
                        SizedBox(
                          width: 8,
                        ),
                        Text("A Coruña",
                            style: TextStyle(
                                fontSize: 30, fontFamily: 'Lab', letterSpacing: 2.0, color: const Color(0xFFFF6600))),
                      ],
                    ),
                    AlternatingWrap(),
                    SizedBox(
                      height: 32,
                    ),
                    Text(
                      "Inscripciones abiertas en",
                      style: TextStyle(
                        fontFamily: 'Lab',
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      // Widget Center adicional
                      child: FlipClockPlus.reverseCountdown(
                        duration: _calculateTimeLeft(),
                        digitColor: Colors.white,
                        backgroundColor: Colors.black,
                        digitSize: 30.0,
                        centerGapSpace: 0.0,
                        borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                        onDone: () {},
                      ),
                    ),
                  ],
                ),
                Center(
                  // Widget Center para el logo
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF6600),
                          width: 24.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            spreadRadius: 10,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: Center(
                        child: RotationTransition(
                          turns: _pulseAnimation,
                          child: Image.asset(
                            "assets/images/mobgenfest_logo.png",
                            height: 150,
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Save the date',
                      style: TextStyle(
                        fontFamily: 'Lab',
                        color: Colors.black,
                        fontSize: 40,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '31 Mayo 2025',
                      style: TextStyle(
                        fontFamily: 'Lab',
                        color: Color(0xFFFF6600),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _NavButton({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: 'Lab')),
    );
  }
}
