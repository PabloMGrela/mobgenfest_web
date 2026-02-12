import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobgenfest/constants.dart';
import 'models/restaurant.dart';
import 'widgets/restaurant_card.dart';
import 'widgets/wheel_animation_overlay.dart';

class DondeSeComeScreen extends StatefulWidget {
  const DondeSeComeScreen({super.key});

  @override
  State<DondeSeComeScreen> createState() => _DondeSeComeScreenState();
}

class _DondeSeComeScreenState extends State<DondeSeComeScreen> {
  List<Restaurant> _allRestaurants = [];
  late List<bool> _selections;
  Restaurant? _winner;
  bool _isSpinning = false;
  bool _isLoadingData = true;
  bool _showWheelAnimation = false;

  /// Set of categories currently enabled (all enabled by default).
  Set<String> _enabledCategories = {};

  /// All unique categories extracted from the data.
  List<String> _allCategories = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/restaurants.json');
      final data = json.decode(response);
      final List<dynamic> places = data['places'] ?? [];

      final restaurants = places.map((place) {
        final name = place['displayName']?['text'] ?? 'Unknown';
        final address = place['formattedAddress'] ?? '';
        final rating = place['rating']?.toString() ?? 'N/A';
        final userRatingCount = place['userRatingCount']?.toString() ?? '0';
        final photoUrl = place['photoUrl'];
        final distance = place['distanceText'] ?? '';
        final duration = place['durationText'] ?? '';
        final category = place['category'] ?? 'Restaurantes';

        String price = '€';
        final priceLevel = place['priceLevel'];
        if (priceLevel == 'PRICE_LEVEL_MODERATE') price = '€€';
        if (priceLevel == 'PRICE_LEVEL_EXPENSIVE') price = '€€€';
        if (priceLevel == 'PRICE_LEVEL_VERY_EXPENSIVE') price = '€€€€';

        return Restaurant.fromMap({
          'name': name,
          'type': 'Restaurante',
          'category': category,
          'address': address,
          'rating': rating,
          'ratingCount': userRatingCount,
          'price': price,
          'photoUrl': photoUrl,
          'distance': distance,
          'duration': duration,
          'phone': place['nationalPhoneNumber'],
        });
      }).toList();

      // Extract unique categories preserving order of appearance
      final seen = <String>{};
      final categories = <String>[];
      for (final r in restaurants) {
        if (seen.add(r.category)) {
          categories.add(r.category);
        }
      }

      setState(() {
        _allRestaurants = restaurants;
        _allCategories = categories;
        _enabledCategories = categories.toSet();
        _selections = List.generate(restaurants.length, (_) => true);
        _isLoadingData = false;
      });
    } catch (e) {
      debugPrint('Error loading restaurant data: $e');
      setState(() {
        _isLoadingData = false;
        _allRestaurants = [];
        _selections = [];
      });
    }
  }

  /// Toggle a whole category on/off — updates individual selections too.
  void _toggleCategory(String category) {
    setState(() {
      if (_enabledCategories.contains(category)) {
        _enabledCategories.remove(category);
        // Deselect all restaurants of this category
        for (int i = 0; i < _allRestaurants.length; i++) {
          if (_allRestaurants[i].category == category) {
            _selections[i] = false;
          }
        }
      } else {
        _enabledCategories.add(category);
        // Select all restaurants of this category
        for (int i = 0; i < _allRestaurants.length; i++) {
          if (_allRestaurants[i].category == category) {
            _selections[i] = true;
          }
        }
      }
    });
  }

  void _spinTheWheel() {
    final selectedRestaurants = _selections
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => _allRestaurants[entry.key])
        .toList();

    if (selectedRestaurants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("¡Selecciona al menos un restaurante!"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final random = Random();
    final winner =
        selectedRestaurants[random.nextInt(selectedRestaurants.length)];

    setState(() {
      _isSpinning = true;
      _winner = winner;
      _showWheelAnimation = true;
    });
  }

  void _onWheelAnimationComplete() {
    setState(() {
      _showWheelAnimation = false;
      _isSpinning = false;
    });
    _showWinnerDialog();
  }

  void _showWinnerDialog() {
    if (_winner == null) return;
    final w = _winner!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppConstants.brandOrange, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppConstants.brandOrange.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confetti icon
              const Text("🎉", style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                "¡HOY SE COME EN!",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Winner photo
              if (w.photo.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: w.photo.startsWith('http')
                          ? NetworkImage(w.photo)
                          : AssetImage(w.photo) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              // Winner name
              Text(
                w.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppConstants.brandOrange,
                  fontSize: 26,
                  fontFamily: 'Lab',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Address
              Text(
                w.address,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              // Rating + Price
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star,
                      color: AppConstants.brandOrange, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "${w.rating} (${w.ratingCount})",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    w.price,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Distance
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_walk,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "${w.distance} (${w.duration})",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              // Phone
              if (w.phoneNumber.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone,
                        color: AppConstants.brandOrange, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      w.phoneNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.brandOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    "¡VAMOS!",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _selectedCount() => _selections.where((s) => s).length;

  /// Emoji icon for each category
  String _categoryIcon(String category) {
    switch (category) {
      case 'Restaurantes':
        return '🍽️';
      case 'Comida Rápida':
        return '🍔';
      case 'Tapas':
        return '🍢';
      case 'Pizzerías':
        return '🍕';
      case 'Sushi & Asiático':
        return '🍣';
      case 'Bares & Copas':
        return '🍸';
      default:
        return '🍴';
    }
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _allCategories[index];
          final isEnabled = _enabledCategories.contains(category);
          final count =
              _allRestaurants.where((r) => r.category == category).length;

          return FilterChip(
            selected: isEnabled,
            showCheckmark: false,
            avatar: Text(_categoryIcon(category),
                style: const TextStyle(fontSize: 16)),
            label: Text(
              '$category ($count)',
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.white54,
                fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            backgroundColor: const Color(0xFF1A1A1A),
            selectedColor: AppConstants.brandOrange.withValues(alpha: 0.25),
            side: BorderSide(
              color: isEnabled ? AppConstants.brandOrange : Colors.white24,
              width: 1.2,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onSelected: (_) => _toggleCategory(category),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Scaffold
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text(
              '¿DONDE SE COME?',
              style: TextStyle(
                fontFamily: 'Lab',
                letterSpacing: 3,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A0A0A),
                  const Color(0xFF121212),
                  const Color(0xFF1A1A2E),
                  AppConstants.brandOrange.withValues(alpha: 0.08),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header section
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "SELECCIONA TUS OPCIONES",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          if (!_isLoadingData && _allRestaurants.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppConstants.brandOrange
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppConstants.brandOrange
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                "${_selectedCount()} / ${_allRestaurants.length}",
                                style: const TextStyle(
                                  color: AppConstants.brandOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Category filter chips
                      if (!_isLoadingData && _allCategories.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildCategoryChips(),
                      ],

                      const SizedBox(height: 16),

                      // Restaurant grid
                      Expanded(
                        child: _isLoadingData
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppConstants.brandOrange),
                              )
                            : _allRestaurants.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No se encontraron restaurantes :(",
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      int crossAxisCount = 1;
                                      if (constraints.maxWidth > 1200) {
                                        crossAxisCount = 4;
                                      } else if (constraints.maxWidth > 900) {
                                        crossAxisCount = 3;
                                      } else if (constraints.maxWidth > 600) {
                                        crossAxisCount = 2;
                                      }

                                      // Filter to only show restaurants in enabled categories
                                      final visibleIndices = <int>[];
                                      for (int i = 0;
                                          i < _allRestaurants.length;
                                          i++) {
                                        if (_enabledCategories.contains(
                                            _allRestaurants[i].category)) {
                                          visibleIndices.add(i);
                                        }
                                      }

                                      if (visibleIndices.isEmpty) {
                                        return const Center(
                                          child: Text(
                                            "Ninguna categoría seleccionada",
                                            style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 16),
                                          ),
                                        );
                                      }

                                      return GridView.builder(
                                        padding:
                                            const EdgeInsets.only(bottom: 80),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          childAspectRatio: 0.8,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                        itemCount: visibleIndices.length,
                                        itemBuilder: (context, gridIndex) {
                                          final actualIndex =
                                              visibleIndices[gridIndex];
                                          final restaurant =
                                              _allRestaurants[actualIndex];
                                          final isSelected =
                                              _selections[actualIndex];
                                          return RestaurantCard(
                                            restaurant: restaurant,
                                            isSelected: isSelected,
                                            onTap: () {
                                              setState(() {
                                                _selections[actualIndex] =
                                                    !_selections[actualIndex];
                                              });
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isSpinning ? null : _spinTheWheel,
            backgroundColor: AppConstants.brandOrange,
            elevation: 12,
            icon: _isSpinning
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.casino, size: 28),
            label: const Text(
              "¡SORTEAR!",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ),
        ),

        // Wheel animation overlay (on top of everything)
        if (_showWheelAnimation && _winner != null)
          WheelAnimationOverlay(
            selectedRestaurants: _selections
                .asMap()
                .entries
                .where((entry) => entry.value)
                .map((entry) => _allRestaurants[entry.key])
                .toList(),
            winner: _winner!,
            onComplete: _onWheelAnimationComplete,
          ),
      ],
    );
  }
}
