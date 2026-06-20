import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/domain/entity/pokemon_entity.dart';
import '../../../core/utils/pokemon_utils.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
    this.isFavorite = false,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryType = pokemon.types.first.type.name;
    final bgColor = PokemonUtils.getTypeColor(primaryType);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    bgColor.withValues(alpha: 0.6),
                    bgColor.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pokemon Image
                  Expanded(
                    flex: 3,
                    child: Hero(
                      tag: 'pokemon-${pokemon.id}',
                      child: CachedNetworkImage(
                        imageUrl:
                            pokemon
                                .sprites
                                .other
                                ?.officialArtwork
                                ?.frontDefault ??
                            pokemon.sprites.frontDefault ??
                            '',
                        fit: BoxFit.contain,
                        memCacheWidth: 350,
                        placeholder: (context, url) => Center(
                          child: Icon(
                            Icons.catching_pokemon,
                            size: 48,
                            color: bgColor.withValues(alpha: 0.2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.catching_pokemon,
                          size: 64,
                          color: bgColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),

                  // Pokemon Info
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pokemon ID
                          Text(
                            '#${pokemon.id.toString().padLeft(3, '0')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Pokemon Name
                          Text(
                            PokemonUtils.capitalize(pokemon.name),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: pokemon.types.take(2).map((type) {
                              final typeColor = PokemonUtils.getTypeColor(
                                type.type.name,
                              );
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: typeColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  PokemonUtils.capitalize(type.type.name),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Favorite Button
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                    size: 24,
                  ),
                  onPressed: onFavoriteToggle,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
