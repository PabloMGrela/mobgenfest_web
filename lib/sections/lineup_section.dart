import 'package:flutter/material.dart';
import 'package:mobgenfest/constants.dart';

class LineupSection extends StatelessWidget {
  const LineupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      color: Colors.black,
      child: Column(
        children: [
          Text(
            "EL CARTEL",
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppConstants.brandOrange,
                  letterSpacing: 4,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            "LOS MEJORES ARTISTAS DE LA ESCENA",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white54, letterSpacing: 3, fontSize: 18),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1200
                  ? 3
                  : (constraints.maxWidth > 800 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  childAspectRatio: 0.8,
                ),
                itemCount: AppConstants.lineup.length,
                itemBuilder: (context, index) {
                  final artist = AppConstants.lineup[index];
                  return _ArtistCard(artist: artist);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ArtistCard extends StatefulWidget {
  final Artist artist;
  const _ArtistCard({required this.artist});

  @override
  State<_ArtistCard> createState() => _ArtistCardState();
}

class _ArtistCardState extends State<_ArtistCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isHovered)
              BoxShadow(
                color: AppConstants.brandOrange.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Artist image
            Image.asset(
              widget.artist.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[900],
                child:
                    const Icon(Icons.person, size: 100, color: Colors.white10),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Text Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.artist.name == "DJ 9.99" ||
                      widget.artist.name == "DJ CARIBE")
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppConstants.brandOrange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "ARTISTA ESTRELLA",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  Text(
                    widget.artist.category,
                    style: const TextStyle(
                      color: AppConstants.brandOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.artist.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
