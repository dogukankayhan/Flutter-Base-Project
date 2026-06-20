import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/domain/entity/pokemon_entity.dart';
import 'package:flutter_base_kit/core/localization/localization_extension.dart';
import '../../../../core/utils/pokemon_utils.dart';

class PokemonMovesTab extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonMovesTab({super.key, required this.pokemon});

  @override
  State<PokemonMovesTab> createState() => _PokemonMovesTabState();
}

class _PokemonMovesTabState extends State<PokemonMovesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      key: const PageStorageKey('moves'),
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final move = widget.pokemon.moves[index];
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      PokemonUtils.capitalize(
                        move.move.name.replaceAll('-', ' '),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'LV. ${move.versionGroupDetails.first.levelLearnedAt}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      context.translations.pokemon.detail.moves.learnMethod(
                        method: move
                            .versionGroupDetails
                            .first
                            .moveLearnMethod
                            .name
                            .replaceAll('-', ' '),
                      ),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  if (index < widget.pokemon.moves.length - 1) const Divider(),
                ],
              );
            }, childCount: widget.pokemon.moves.length),
          ),
        ),
      ],
    );
  }
}
