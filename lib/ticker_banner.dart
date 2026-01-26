import 'package:flutter/material.dart';
import 'package:mobgenfest/constants.dart';

class ModernTickerBanner extends StatefulWidget {
  const ModernTickerBanner({super.key});

  @override
  State<ModernTickerBanner> createState() => _ModernTickerBannerState();
}

class _ModernTickerBannerState extends State<ModernTickerBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<String> _words = [
    "MUSIC",
    "BEATS",
    "FESTIVAL",
    "NON STOP",
    "ENERGY",
    "VIBES",
    "DANCE",
    "NIGHT",
    "MOBGEN",
    "2026",
    "PARTY",
    "RAVE",
    "LIFE",
    "LIVE"
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      color: AppConstants.brandOrange,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FractionalTranslation(
              translation: Offset(-_controller.value, 0),
              child: OverflowBox(
                maxWidth: double.infinity,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (index) => _buildWordRow()),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWordRow() {
    return Row(
      children: _words.asMap().entries.map((entry) {
        final bool isEven = entry.key % 2 == 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            entry.value,
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w900,
              fontFamily: 'Lab',
              letterSpacing: -2,
              color: isEven ? Colors.black : null,
              foreground: isEven
                  ? null
                  : (Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = Colors.black45),
            ),
          ),
        );
      }).toList(),
    );
  }
}
