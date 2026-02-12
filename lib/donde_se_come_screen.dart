import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobgenfest/constants.dart';

class DondeSeComeScreen extends StatefulWidget {
  const DondeSeComeScreen({super.key});

  @override
  State<DondeSeComeScreen> createState() => _DondeSeComeScreenState();
}

class _DondeSeComeScreenState extends State<DondeSeComeScreen>
    with SingleTickerProviderStateMixin {
  // Hardcoded coordinates for context
  // Lat: 43.367870, Long: -8.403319 (Culleredo, A Coruña)

  List<Map<String, dynamic>> _allRestaurants = [];
  late List<bool> _selections;
  String? _winner;
  bool _isSpinning = false;
  bool _isLoadingData = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/restaurants.json');
      final data = json.decode(response);
      final List<dynamic> places = data['places'] ?? [];

      setState(() {
        _allRestaurants = places.map((place) {
          final name = place['displayName']?['text'] ?? 'Unknown';
          final address = place['formattedAddress'] ?? '';
          final rating = place['rating']?.toString() ?? 'N/A';
          final userRatingCount = place['userRatingCount']?.toString() ?? '0';
          final photoUrl = place['photoUrl'];
          final distance = place['distanceText'] ?? '';
          final duration = place['durationText'] ?? '';

          String price = '€';
          final priceLevel = place['priceLevel'];
          if (priceLevel == 'PRICE_LEVEL_MODERATE') price = '€€';
          if (priceLevel == 'PRICE_LEVEL_EXPENSIVE') price = '€€€';
          if (priceLevel == 'PRICE_LEVEL_VERY_EXPENSIVE') price = '€€€€';

          // Simple "type" derivation or just use address as subtitle
          // We don't have explicit "type" in standard Places response without deeper parsing
          // So we'll use address and rating for subtitle.

          return {
            'name': name,
            'type': 'Restaurante', // Generic fallback
            'address': address,
            'rating': rating,
            'ratingCount': userRatingCount,
            'price': price,
            'photoUrl': photoUrl,
            'distance': distance,
            'duration': duration,
            'phone': place['nationalPhoneNumber'],
          };
        }).toList();

        _selections = List.generate(_allRestaurants.length, (_) => true);
        _isLoadingData = false;
      });
    } catch (e) {
      debugPrint('Error loading restaurant data: $e');
      setState(() {
        _isLoadingData = false;
        // Fallback to empty or error state
        _allRestaurants = [];
        _selections = [];
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinTheWheel() {
    final selectedIndices = _selections
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona al menos un restaurante!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
      _winner = null;
    });

    _controller.forward(from: 0).then((_) {
      final random = Random();
      final winnerIndex =
          selectedIndices[random.nextInt(selectedIndices.length)];
      setState(() {
        _isSpinning = false;
        _winner = _allRestaurants[winnerIndex]['name'];
      });
      _showWinnerDialog();
    });
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppConstants.brandOrange, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppConstants.brandOrange.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "¡HOY SE COME EN!",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Show photo of winner if available
              if (_winner != null) ...[
                Builder(builder: (context) {
                  final winningRestaurant =
                      _allRestaurants.firstWhere((r) => r['name'] == _winner);
                  final photoUrl = winningRestaurant['photoUrl'];
                  if (photoUrl != null) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: (photoUrl.startsWith('http'))
                              ? NetworkImage(photoUrl)
                              : AssetImage(photoUrl) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
              Text(
                _winner?.toUpperCase() ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppConstants.brandOrange,
                  fontSize: 28,
                  fontFamily: 'Lab',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Extra Details
              if (_winner != null)
                Builder(builder: (context) {
                  final winningRestaurant =
                      _allRestaurants.firstWhere((r) => r['name'] == _winner);
                  return Column(
                    children: [
                      Text(
                        winningRestaurant['address'] ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star,
                              color: AppConstants.brandOrange, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            "${winningRestaurant['rating']} (${winningRestaurant['ratingCount']})",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            winningRestaurant['price'] ?? "",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_walk,
                              color: Colors.white70, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            "${winningRestaurant['distance']} (${winningRestaurant['duration']})",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      if (winningRestaurant['phone'] != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone,
                                color: AppConstants.brandOrange, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              winningRestaurant['phone'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                }),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.brandOrange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("¡VAMOS!"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          '¿DONDE SE COME?',
          style: TextStyle(fontFamily: 'Lab', letterSpacing: 1.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConstants.brandOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppConstants.brandOrange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppConstants.brandOrange, size: 30),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "OFICINA",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "43.367870, -8.403319",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "SELECCIONA OPCIONES",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoadingData
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppConstants.brandOrange))
                    : _allRestaurants.isEmpty
                        ? const Center(
                            child: Text("No se encontraron restaurantes :(",
                                style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            itemCount: _allRestaurants.length,
                            itemBuilder: (context, index) {
                              final restaurant = _allRestaurants[index];
                              final isSelected = _selections[index];
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1E1E1E)
                                      : const Color(0xFF0F0F0F),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white24
                                        : Colors.white10,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selections[index] = !_selections[index];
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      // Photo
                                      if (restaurant['photoUrl'] != null)
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              bottomLeft: Radius.circular(12),
                                            ),
                                            image: DecorationImage(
                                              image: (restaurant['photoUrl']
                                                      .startsWith('http'))
                                                  ? NetworkImage(
                                                      restaurant['photoUrl'])
                                                  : AssetImage(restaurant[
                                                          'photoUrl'])
                                                      as ImageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppConstants.brandOrange
                                                : Colors.white10,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              bottomLeft: Radius.circular(12),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.restaurant,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white38,
                                            size: 30,
                                          ),
                                        ),

                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                restaurant['name'],
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.white38,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                restaurant['address'],
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white60
                                                      : Colors.white24,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.star,
                                                      size: 14,
                                                      color: AppConstants
                                                          .brandSecondary),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${restaurant['rating']} (${restaurant['ratingCount']})",
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? Colors.white70
                                                          : Colors.white30,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    restaurant['price'],
                                                    style: TextStyle(
                                                      color: Colors.greenAccent,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (restaurant['distance']
                                                      .isNotEmpty) ...[
                                                    const SizedBox(width: 12),
                                                    Icon(Icons.directions_walk,
                                                        size: 14,
                                                        color: isSelected
                                                            ? Colors.white70
                                                            : Colors.white24),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "${restaurant['distance']} (${restaurant['duration']})",
                                                      style: TextStyle(
                                                        color: isSelected
                                                            ? Colors.white70
                                                            : Colors.white30,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: Checkbox(
                                          value: isSelected,
                                          activeColor: AppConstants.brandOrange,
                                          checkColor: Colors.white,
                                          side: const BorderSide(
                                              color: Colors.white24),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _selections[index] =
                                                  value ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSpinning ? null : _spinTheWheel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.brandOrange,
                    elevation: 8,
                    shadowColor: AppConstants.brandOrange.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSpinning
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.casino, size: 28),
                            SizedBox(width: 12),
                            Text(
                              "¡SORTEAR!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
