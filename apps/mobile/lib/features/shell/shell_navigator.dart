import 'package:flutter_base_kit/core/domain/entity/pokemon_entity.dart';
import 'package:flutter_base_kit/features/pokemon_detail/view/pokemon_detail_screen.dart';
import 'package:go_router/go_router.dart';

import '../favorites/view/favorites_screen.dart';
import '../pokemon_home/view/pokemon_home_screen.dart';
import 'view/shell_screen.dart';

final class ShellNavigator {
  static const String appointmentsPath = '/appointments';
  static const String pokemonPath = '/pokemon';

  StatefulShellRoute get route => StatefulShellRoute.indexedStack(
    builder: (_, _, navigationShell) =>
        ShellScreen(navigationShell: navigationShell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: pokemonPath,
            builder: (_, _) => const PokemonHomeScreen(),
            routes: [
              GoRoute(
                path: 'pokemon/:id',
                builder: (context, state) => PokemonDetailScreen(
                  pokemonId: int.parse(state.pathParameters['id']!),
                  pokemon: state.extra as Pokemon?,
                  activeKey: 'pokemon_detail_${state.pageKey.value}',
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: appointmentsPath,
            builder: (_, _) => const FavoritesScreen(),
            routes: [
              GoRoute(
                path: 'pokemon/:id',
                builder: (context, state) => PokemonDetailScreen(
                  pokemonId: int.parse(state.pathParameters['id']!),
                  pokemon: state.extra as Pokemon?,
                  activeKey: 'fav_pokemon_${state.pageKey.value}',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
