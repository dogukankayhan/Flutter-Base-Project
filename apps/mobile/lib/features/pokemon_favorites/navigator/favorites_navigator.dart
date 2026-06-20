import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/domain/entity/pokemon_entity.dart';
import 'package:go_router/go_router.dart';

import '../../shell/shell_navigator.dart';

final class PokemonFavoritesNavigator {
  static void showDetail(BuildContext context, Pokemon pokemon) {
    context.push(
      '${ShellNavigator.appointmentsPath}/pokemon/${pokemon.id}',
      extra: pokemon,
    );
  }
}
