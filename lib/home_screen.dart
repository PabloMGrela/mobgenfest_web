import 'package:flutter/material.dart';
import 'package:mobgenfest/constants.dart';
import 'package:mobgenfest/sections/hero_section.dart';
import 'package:mobgenfest/sections/lineup_section.dart';
import 'package:mobgenfest/sections/food_section.dart';
import 'package:mobgenfest/sections/ticket_section.dart';
import 'package:mobgenfest/ticker_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  final GlobalKey _lineupKey = GlobalKey();
  final GlobalKey _foodKey = GlobalKey();
  final GlobalKey _ticketsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(int index) {
    GlobalKey? key;
    if (index == 1) key = _lineupKey;
    if (index == 2) key = _foodKey;
    if (index == 3) key = _ticketsKey;

    if (key != null && key.currentContext != null) {
      final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
      final double position = box.localToGlobal(Offset.zero).dy;
      final double offset = _scrollController.offset + position - 80;

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    } else if (index == 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    } else if (index == -1) {
      Navigator.pushNamed(context, '/faq');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HeroSection(onGetTicketsTap: () => _scrollToSection(3)),
            const ModernTickerBanner(),
            LineupSection(key: _lineupKey),
            FoodSection(key: _foodKey),
            TicketSection(key: _ticketsKey),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    bool isScrolled = _scrollOffset > 50;
    return AppBar(
      backgroundColor: isScrolled
          ? AppConstants.brandDark.withOpacity(0.9)
          : Colors.transparent,
      elevation: isScrolled ? 4 : 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 80,
      title: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Image.asset(
          "assets/images/mobgenfest_logo.png",
          height: 40,
        ),
      ),
      actions: [
        _navButton("CARTEL", 1),
        _navButton("COMIDA", 2),
        _navButton("ENTRADAS", 3),
        _navButton("FAQ", -1), // Special case for separate screen
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _navButton(String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: () => _scrollToSection(index),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            letterSpacing: 3,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: Colors.black,
      width: double.infinity,
      child: Column(
        children: [
          Image.asset("assets/images/mobgenfest_logo.png", height: 60),
          const SizedBox(height: 30),
          Text(
            AppConstants.festivalName,
            style: const TextStyle(
              color: AppConstants.brandOrange,
              fontSize: 32,
              letterSpacing: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white10, indent: 100, endIndent: 100),
          const SizedBox(height: 40),
          const Text(
            "© 2026 MOBGEN FEST. TODOS LOS DERECHOS RESERVADOS.",
            style: TextStyle(
                color: Colors.white24, fontSize: 14, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/faq'),
            child: const Text(
              "PREGUNTAS FRECUENTES (FAQ)",
              style: TextStyle(
                color: AppConstants.brandOrange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
