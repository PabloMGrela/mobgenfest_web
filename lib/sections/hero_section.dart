import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobgenfest/constants.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback? onGetTicketsTap;
  const HeroSection({super.key, this.onGetTicketsTap});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  late Timer _timer;
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateTime();
        });
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    _timeRemaining = AppConstants.countdownDate.isAfter(now)
        ? AppConstants.countdownDate.difference(now)
        : Duration.zero;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppConstants.brandDark,
      ),
      child: Stack(
        children: [
          // Background Gradient Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.brandOrange.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.brandSecondary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with Glow
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.brandOrange.withOpacity(0.3),
                        blurRadius: 50,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/mobgenfest_logo.png',
                    height: 120,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFFFCC00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    AppConstants.festivalName,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          letterSpacing: 12,
                          height: 1.0,
                        ),
                  ),
                ),
                Text(
                  AppConstants.festivalYear,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppConstants.brandOrange,
                        letterSpacing: 16,
                        fontWeight: FontWeight.w300,
                      ),
                ),
                const SizedBox(height: 16),

                // Location & Dates
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on,
                        color: AppConstants.brandOrange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppConstants.location,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(letterSpacing: 3, fontSize: 22),
                    ),
                    const SizedBox(width: 24),
                    const Icon(Icons.calendar_today,
                        color: AppConstants.brandOrange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppConstants.dates,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(letterSpacing: 3, fontSize: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Countdown
                _buildCountdown(),

                const SizedBox(height: 60),

                // Call to Action
                ElevatedButton(
                  onPressed: widget.onGetTicketsTap,
                  child: const Text("CONSIGUE TUS ENTRADAS",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _countdownItem(_timeRemaining.inDays, "DIAS"),
        _countdownDivider(),
        _countdownItem(_timeRemaining.inHours % 24, "HORAS"),
        _countdownDivider(),
        _countdownItem(_timeRemaining.inMinutes % 60, "MINUTOS"),
        _countdownDivider(),
        _countdownItem(_timeRemaining.inSeconds % 60, "SEGUNDOS"),
      ],
    );
  }

  Widget _countdownItem(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Lab',
            letterSpacing: 4,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            letterSpacing: 4,
            color: AppConstants.brandOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _countdownDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(":", style: TextStyle(fontSize: 40, color: Colors.white38)),
    );
  }
}
