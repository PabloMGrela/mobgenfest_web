import 'package:flutter/material.dart';
import 'package:mobgenfest/constants.dart';

class FoodSection extends StatelessWidget {
  const FoodSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
      ),
      child: Column(
        children: [
          Text(
            "GASTRONOMIA",
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppConstants.brandSecondary,
                  letterSpacing: 4,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            "UN VIAJE POR LOS SABORES LOCALES",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white54, letterSpacing: 3, fontSize: 18),
          ),
          const SizedBox(height: 60),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: AppConstants.foodVendors
                  .map((vendor) => _FoodVendorCard(vendor: vendor))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodVendorCard extends StatelessWidget {
  final FoodVendor vendor;
  const _FoodVendorCard({required this.vendor});

  IconData _getIcon() {
    switch (vendor.name) {
      case "CALLOS":
        return Icons.soup_kitchen;
      case "LACÓN":
        return Icons.restaurant_menu;
      case "CENA":
        return Icons.rice_bowl_outlined;
      case "TEQUEÑOS":
        return Icons.breakfast_dining;
      default:
        return Icons.fastfood;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[900]!,
                  Colors.black,
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Center(
                child: Icon(_getIcon(),
                    size: 60,
                    color: AppConstants.brandSecondary.withOpacity(0.4))),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lab',
                      letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  vendor.type,
                  style: TextStyle(
                    color: vendor.name == "CENA"
                        ? AppConstants.brandOrange
                        : Colors.white54,
                    fontSize: 14,
                    fontWeight: vendor.name == "CENA"
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
