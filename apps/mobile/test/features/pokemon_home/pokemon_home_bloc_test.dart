import 'dart:async';
import 'package:flutter_base_kit/core/domain/entity/pokemon_ability_entity.dart';
import 'package:flutter_base_kit/core/domain/entity/pokemon_entity.dart';
import 'package:flutter_base_kit/core/domain/entity/pokemon_sprites_entity.dart';
import 'package:flutter_base_kit/core/domain/entity/pokemon_stats_entity.dart';
import 'package:flutter_base_kit/core/domain/entity/pokemon_type_entity.dart';
import 'package:flutter_base_kit/core/domain/repository/favorites_repository.dart';
import 'package:flutter_base_kit/core/domain/usecase/filter_pokemon_by_type_usecase.dart';
import 'package:flutter_base_kit/core/domain/usecase/get_pokemon_page_usecase.dart';
import 'package:flutter_base_kit/core/domain/usecase/search_pokemon_usecase.dart';
import 'package:flutter_base_kit/features/pokemon_home/bloc/pokemon_home_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'pokemon_home_bloc_test.mocks.dart';

@GenerateMocks([
  GetPokemonPageUseCase,
  FilterPokemonByTypeUseCase,
  SearchPokemonUseCase,
  FavoritesRepository,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetPokemonPageUseCase mockGetPageUseCase;
  late MockFilterPokemonByTypeUseCase mockFilterUseCase;
  late MockSearchPokemonUseCase mockSearchUseCase;
  late MockFavoritesRepository mockFavoritesRepo;
  late PokemonHomeBloc bloc;

  final tPokemon = const Pokemon(
    id: 1,
    name: 'bulbasaur',
    height: 7,
    weight: 69,
    baseExperience: 64,
    types: [
      PokemonType(
        slot: 1,
        type: TypeInfo(name: 'grass', url: ''),
      ),
    ],
    abilities: [
      PokemonAbility(
        isHidden: false,
        slot: 1,
        ability: AbilityInfo(name: 'overgrow', url: ''),
      ),
    ],
    stats: PokemonStats(
      hp: 45,
      attack: 49,
      defense: 49,
      specialAttack: 65,
      specialDefense: 65,
      speed: 45,
    ),
    sprites: PokemonSprites(frontDefault: 'sprite_url'),
    speciesName: 'bulbasaur',
    speciesUrl: 'species_url',
  );

  setUp(() {
    mockGetPageUseCase = MockGetPokemonPageUseCase();
    mockFilterUseCase = MockFilterPokemonByTypeUseCase();
    mockSearchUseCase = MockSearchPokemonUseCase();
    mockFavoritesRepo = MockFavoritesRepository();

    when(
      mockFavoritesRepo.favoriteIdsStream,
    ).thenAnswer((_) => Stream.value({}));

    bloc = PokemonHomeBloc(
      mockGetPageUseCase,
      mockFilterUseCase,
      mockSearchUseCase,
      mockFavoritesRepo,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('PokemonHomeBloc Initial State', () {
    test('initial state has correct default values', () {
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.isLoading, false);
      expect(bloc.state.hasMore, true);
      expect(bloc.state.nextOffset, 0);
      expect(bloc.state.selectedType, isNull);
      expect(bloc.state.searchQuery, isNull);
    });
  });

  group('PokemonHomeStarted', () {
    test('loads initial page of pokemons successfully', () async {
      when(
        mockGetPageUseCase(size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], true, 20));

      final loadingStates = <bool>[];
      final subscription = bloc.stream.listen(
        (s) => loadingStates.add(s.isLoading),
      );

      bloc.add(PokemonHomeStarted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(loadingStates, containsAll([true, false]));
      expect(bloc.state.items, contains(tPokemon));
      expect(bloc.state.hasMore, true);
      expect(bloc.state.nextOffset, 20);

      await subscription.cancel();
    });

    test('emits error state when loading page fails', () async {
      when(
        mockGetPageUseCase(size: 20, offset: 0),
      ).thenThrow(Exception('Network error'));

      bloc.add(PokemonHomeStarted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.isLoading, false);
      expect(bloc.state.errorMessage, contains('Network error'));
    });
  });

  group('PokemonHomeFilterByType', () {
    test('loads pokemons filtered by type', () async {
      when(
        mockFilterUseCase(type: 'grass', size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], false, 1));

      bloc.add(PokemonHomeFilterByType('grass'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.selectedType, 'grass');
      expect(bloc.state.items, contains(tPokemon));
      expect(bloc.state.hasMore, false);
    });
  });

  group('PokemonHomeSearch', () {
    test('loads searched pokemons', () async {
      when(
        mockSearchUseCase(query: 'bulb', size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], false, 1));

      bloc.add(PokemonHomeSearch('bulb'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.searchQuery, 'bulb');
      expect(bloc.state.items, contains(tPokemon));
    });
  });
}
