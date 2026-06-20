import 'package:flutter/material.dart';
import 'package:flutter_kit_ui/widgets/app_image.dart';
import '../../../core/domain/entity/pokemon_entity.dart';

class PokemonFullItem extends StatelessWidget {
  final Pokemon data;
  const PokemonFullItem({super.key, required this.data});

  /// Soft gradient color based on pokemon id
  Color _bgColor() {
    final colors = [
      const Color(0xFF78C850), // grass
      const Color(0xFFF08030), // fire
      const Color(0xFF6890F0), // water
      const Color(0xFFA8B820), // bug
      const Color(0xFFA040A0), // poison
      const Color(0xFFE0C068), // ground
      const Color(0xFFB8A038), // rock
      const Color(0xFF705898), // ghost
      const Color(0xFFF85888), // fairy
      const Color(0xFFF8D030), // electric
    ];
    return colors[data.id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _bgColor();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.4),
            Colors.black87,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Pokemon image – preserve ratio with contain, show fully
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 60, 32, 100),
              child: AppImage(
                imageUrl:
                    data.sprites.other?.officialArtwork?.frontDefault ??
                    data.sprites.frontDefault,
                fit: BoxFit.contain,
                fallbackIcon: Icons.catching_pokemon,
                fallbackIconSize: 80,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          // Alt gradient + isim
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                  stops: [0.0, 0.8],
                ),
              ),
              child: Text(
                '#${data.id}  ${data.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
