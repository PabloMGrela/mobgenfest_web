import 'package:flutter/material.dart';
import 'package:mobgenfest/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketSection extends StatefulWidget {
  const TicketSection({super.key});

  @override
  State<TicketSection> createState() => _TicketSectionState();
}

class _TicketSectionState extends State<TicketSection> {
  int _vipCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVipCount();
  }

  Future<void> _fetchVipCount() async {
    try {
      final response = await Supabase.instance.client
          .from('registrations')
          .select('id')
          .eq('ticket_type', 'VIP EXPERIENCE');

      if (mounted) {
        setState(() {
          _vipCount = (response as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isVipSoldOut = _vipCount >= AppConstants.vipTicketLimit;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      color: Colors.black,
      child: Column(
        children: [
          Text(
            "ENTRADAS",
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  letterSpacing: 4,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            "ASEGURA TU LUGAR EN LA MEJOR EXPERIENCIA DEL AÑO",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white54, letterSpacing: 3, fontSize: 18),
          ),
          const SizedBox(height: 60),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Wrap(
                  spacing: 30,
                  runSpacing: 30,
                  alignment: WrapAlignment.center,
                  children: [
                    _TicketCard(
                      title: "EARLY BIRD",
                      price: "55€",
                      description:
                          "Disponible hasta el 6 de feb.\nAcceso general de un dia.",
                      isRecommended: true,
                      isSoldOut: !AppConstants.isEarlyBirdAvailable,
                    ),
                    _TicketCard(
                      title: "GENERAL PASS",
                      price: "65€",
                      description:
                          "Acceso estandar.\nAcceso general de un dia.",
                      isRecommended: false,
                    ),
                    _TicketCard(
                      title: "VIP EXPERIENCE",
                      price: "120€",
                      description: isVipSoldOut
                          ? "Limitado a 16 plazas.\n¡Agotado!"
                          : "Zonas premium.\nAcceso de tres dias.",
                      isRecommended: false,
                      isSoldOut: isVipSoldOut,
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final bool isRecommended;
  final bool isSoldOut;

  const _TicketCard({
    required this.title,
    required this.price,
    required this.description,
    this.isRecommended = false,
    this.isSoldOut = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(30),
        border: isRecommended && !isSoldOut
            ? Border.all(color: AppConstants.brandOrange, width: 2)
            : Border.all(color: Colors.white10),
        boxShadow: [
          if (isRecommended && !isSoldOut)
            BoxShadow(
              color: AppConstants.brandOrange.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            )
        ],
      ),
      child: Column(
        children: [
          if (isRecommended || isSoldOut)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isSoldOut ? Colors.red : AppConstants.brandOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isSoldOut ? "AGOTADO" : "EL MAS POPULAR",
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white54,
                letterSpacing: 3,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            price,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lab',
                letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white38, height: 1.5, fontSize: 18),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSoldOut
                  ? null
                  : () {
                      Navigator.pushNamed(
                        context,
                        '/registro',
                        arguments: {
                          'type': title,
                          'price': price,
                        },
                      );
                    },
              style: isSoldOut
                  ? ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white24,
                    )
                  : (isRecommended
                      ? null
                      : ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                        )),
              child: Text(isSoldOut ? "NO DISPONIBLE" : "RESERVAR AHORA"),
            ),
          ),
        ],
      ),
    );
  }
}
