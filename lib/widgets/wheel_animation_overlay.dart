import 'dart:math';
import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../constants.dart';

class WheelAnimationOverlay extends StatefulWidget {
  final List<Restaurant> selectedRestaurants;
  final Restaurant winner;
  final VoidCallback onComplete;

  const WheelAnimationOverlay({
    super.key,
    required this.selectedRestaurants,
    required this.winner,
    required this.onComplete,
  });

  @override
  State<WheelAnimationOverlay> createState() => _WheelAnimationOverlayState();
}

class _WheelAnimationOverlayState extends State<WheelAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scrollAnimation;
  late ScrollController _scrollController;

  final double _cardWidth = 300.0;
  final double _cardSpacing = 20.0;

  /// We need the screen width to centre the winner under the arrow.
  /// It's resolved in didChangeDependencies so we can use MediaQuery.
  double _screenWidth = 0;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sw = MediaQuery.of(context).size.width;
    if (_screenWidth != sw) {
      _screenWidth = sw;
    }
    if (!_animationStarted) {
      _animationStarted = true;
      _setupAndStartAnimation();
    }
  }

  void _setupAndStartAnimation() {
    final winnerIndex = widget.selectedRestaurants.indexOf(widget.winner);
    final cardTotalWidth = _cardWidth + _cardSpacing;

    // The arrow sits at the horizontal centre of the screen.
    // We want the *centre* of the winner card to align with that arrow.
    // scroll offset that puts the winner card's centre at screen centre:
    //   winnerIndex * cardTotalWidth  →  left edge of the winner card in scroll coordinates
    //   + cardWidth / 2               →  centre of the card
    //   - screenWidth / 2             →  shift so it's at the screen centre
    final centerCorrection = (_cardWidth / 2) - (_screenWidth / 2);

    // Add 3-5 full cycles before landing on winner for dramatic effect
    final cycles = 3 + Random().nextDouble() * 2;
    final totalCards = widget.selectedRestaurants.length;
    final targetOffset = (cycles * totalCards * cardTotalWidth) +
        (winnerIndex * cardTotalWidth) +
        centerCorrection;

    _scrollAnimation = Tween<double>(
      begin: 0.0,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scrollAnimation.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollAnimation.value);
      }
    });

    // Start animation after a brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _controller.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) widget.onComplete();
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create an extended list by repeating restaurants for infinite scroll effect
    final extendedList = List<Restaurant>.generate(
      widget.selectedRestaurants.length * 10,
      (index) =>
          widget.selectedRestaurants[index % widget.selectedRestaurants.length],
    );

    return Material(
      color: Colors.black.withValues(alpha: 0.95),
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.95),
                  const Color(0xFF1A1A1A).withValues(alpha: 0.95),
                ],
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  '¡GIRANDO LA RULETA!',
                  style: TextStyle(
                    color: AppConstants.brandOrange,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontFamily: 'Lab',
                  ),
                ),
                const SizedBox(height: 60),

                // Wheel container
                SizedBox(
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Horizontal scrolling cards
                      ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: extendedList.length,
                        itemBuilder: (context, index) {
                          final restaurant = extendedList[index];
                          return Container(
                            width: _cardWidth,
                            margin: EdgeInsets.only(right: _cardSpacing),
                            child: _buildWheelCard(restaurant),
                          );
                        },
                      ),

                      // Gradient edges for fade effect
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.95),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Colors.black.withValues(alpha: 0.95),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelCard(Restaurant restaurant) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppConstants.brandOrange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      color: const Color(0xFF1E1E1E),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Restaurant photo
          if (restaurant.photo.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: restaurant.photo.startsWith('http')
                  ? Image.network(
                      restaurant.photo,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _photoPlaceholder(),
                    )
                  : Image.asset(
                      restaurant.photo,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _photoPlaceholder(),
                    ),
            ),

          // Restaurant info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star,
                        color: AppConstants.brandOrange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.rating,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      restaurant.price,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      height: 120,
      color: Colors.grey[800],
      child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
    );
  }
}
