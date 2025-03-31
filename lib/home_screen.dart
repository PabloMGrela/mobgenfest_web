import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobgenfest/alternate_wrap.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Duration timeLeft = _calculateTimeLeft();
  bool showJoinButton = true;

  static Duration _calculateTimeLeft() {
    DateTime targetDate = DateTime(2025, 4, 15, 12, 0, 0);
    return targetDate.difference(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    showJoinButton = !_calculateTimeLeft().isNegative;
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

  @override
  void dispose() {
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
        actions: [
          MaterialButton(
              child: Text(
                "FAQ",
                style: TextStyle(fontFamily: 'Lab', fontSize: 30, letterSpacing: 2, color: const Color(0xFFFF6600)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/faq');
              })
        ],
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
                    if (showJoinButton)
                      Text(
                        "Inscripciones abiertas",
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
                    if (!showJoinButton)
                      Text(
                        "Inscripciones cerradas",
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
                    if (showJoinButton)
                      ElevatedButton.icon(
                        icon: Icon(Icons.monetization_on_outlined, color: Color(0xFFFF6600)),
                        label: Text(
                          'Abonos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6600),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: Color(0xFFFF6600),
                              width: 2.0,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          final Uri url = Uri.parse("https://forms.gle/86cUnAnAbUMoqcTw9");
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, webOnlyWindowName: '_blank');
                          } else {
                            throw 'No se pudo abrir $url';
                          }
                        },
                      ),
                    SizedBox(
                      height: 8,
                    ),
                    if (showJoinButton)
                      Text(
                        "Se cierran las inscripciones en:",
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
                    if (showJoinButton)
                      Center(
                        child: FlipClockPlus.reverseCountdown(
                          duration: _calculateTimeLeft(),
                          digitColor: Colors.white,
                          backgroundColor: Colors.black,
                          digitSize: 30.0,
                          centerGapSpace: 0.0,
                          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                          onDone: () {
                            setState(() {
                              showJoinButton = true;
                            });
                          },
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
