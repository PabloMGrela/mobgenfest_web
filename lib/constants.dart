import 'package:flutter/material.dart';

class AppConstants {
  static const String festivalName = "MOBGEN FEST";
  static const String festivalYear = "2026";
  static const String location = "Ledoño, A Coruña";
  static const String dates = "29 - 31 DE MAYO 2026";

  static const Color brandOrange = Color(0xFFFF6600);
  static const Color brandDark = Color(0xFF0A0A0A);
  static const Color brandSecondary = Color(0xFFFFCC00);

  static final DateTime countdownDate = DateTime(2026, 5, 29, 18, 0, 0);

  static final DateTime earlyBirdDeadline = DateTime(2026, 3, 1);
  static const int vipTicketLimit = 16;

  static bool get isEarlyBirdAvailable =>
      DateTime.now().isBefore(earlyBirdDeadline);

  static const List<Artist> lineup = [
    Artist(
        name: "FIESTA",
        category: "EVENTO PRINCIPAL",
        image: "assets/images/picgroup.png"),
    Artist(
        name: "DJ CARIBE",
        category: "ARTISTA ESTRELLA",
        image: "assets/images/djcaribe1.png"),
    Artist(
        name: "NUEVAS ESTRELLAS",
        category: "PROXIMAMENTE",
        image: "assets/images/brownieman.png"),
  ];

  static const List<FoodVendor> foodVendors = [
    FoodVendor(name: "CALLOS", type: "SESION VERMUT", rating: 5.0),
    FoodVendor(name: "LACON", type: "COMIDA TRADICIONAL", rating: 5.0),
    FoodVendor(name: "CENA", type: "ARROCES DEL COMPI", rating: 5.0),
  ];
}

class Artist {
  final String name;
  final String category;
  final String image;
  const Artist(
      {required this.name, required this.category, required this.image});
}

class FoodVendor {
  final String name;
  final String type;
  final double rating;
  const FoodVendor(
      {required this.name, required this.type, required this.rating});
}
