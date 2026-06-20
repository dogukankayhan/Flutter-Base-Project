import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/localization/localization_extension.dart';
import 'package:flutter_base_kit/core/utils/pokemon_utils.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';
import 'package:go_router/go_router.dart';
import '../bloc/pokemon_home_bloc.dart';
import '../bloc/pokemon_home_state.dart';
import '../widgets/pokemon_card.dart';

class PokemonHomeScreen extends StatelessWidget {
  const PokemonHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<PokemonHomeBloc, PokemonHomeState>(
      create: () => PokemonHomeBloc.create()..add(PokemonHomeStarted()),
      loadingOverlay: const SizedBox.shrink(),
      builder: (context, state, bloc) {
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: bloc.searchController,
              decoration: InputDecoration(
                hintText: context.translations.pokemon.searchHint,
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: bloc.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          bloc.searchController.clear();
                          bloc.add(PokemonHomeSearchQueryChanged(''));
                        },
                      )
                    : null,
              ),
              onChanged: (query) {
                bloc.add(PokemonHomeSearchQueryChanged(query));
              },
            ),
          ),
          body: Column(
            children: [
              // Type Filter Chips
              _buildTypeFilterChips(bloc, state),

              // Pokemon Grid
              Expanded(child: _buildPokemonGrid(context, state, bloc)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeFilterChips(PokemonHomeBloc bloc, PokemonHomeState state) {
    final types = [
      'fire',
      'water',
      'grass',
      'electric',
      'psychic',
      'ice',
      'dragon',
      'dark',
      'fairy',
      'fighting',
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = state.selectedType == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                type.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : null,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  bloc.add(PokemonHomeFilterByType(type));
                } else {
                  bloc.add(PokemonHomeFilterByType(null));
                }
              },
              selectedColor: PokemonUtils.getTypeColor(type),
              checkmarkColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPokemonGrid(
    BuildContext context,
    PokemonHomeState state,
    PokemonHomeBloc bloc,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => bloc.add(PokemonHomeStarted()),
              child: Text(context.translations.common.retry),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          bloc.add(
            PokemonHomeScrollPositionChanged(
              metrics.pixels,
              metrics.maxScrollExtent,
            ),
          );
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          bloc.add(PokemonHomeRefresh());
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: GridView.builder(
          controller: bloc.scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.hasMore
              ? state.items.length + 2
              : state.items.length,
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            final pokemon = state.items[index];
            return PokemonCard(
              key: ValueKey(pokemon.id),
              pokemon: pokemon,
              isFavorite: state.favoriteIds.contains(pokemon.id),
              onTap: () => context.push(
                '/pokemon/pokemon/${pokemon.id}',
                extra: pokemon,
              ),
              onFavoriteToggle: () =>
                  bloc.add(PokemonHomeToggleFavorite(pokemon.id)),
            );
          },
        ),
      ),
    );
  }
}
