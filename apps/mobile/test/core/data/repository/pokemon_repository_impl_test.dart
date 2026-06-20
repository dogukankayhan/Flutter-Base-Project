import 'package:flutter_base_kit/core/data/datasource/pokemon_remote_datasource.dart';
import 'package:flutter_base_kit/core/data/repository/pokemon_repository_impl.dart';
import 'package:flutter_base_kit/core/domain/entity/evolution_chain_entity.dart';
import 'package:flutter_base_kit/core/domain/entity/pokemon_brief_entity.dart';
import 'package:flutter_base_kit/core/domain/entity/pokemon_entity.dart';
import 'package:flutter_base_kit/core/domain/entity/pokemon_species_entity.dart';
import 'package:flutter_base_kit/core/domain/entity/pokemon_sprites_entity.dart';
import 'package:flutter_base_kit/core/domain/entity/pokemon_stats_entity.dart';
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'pokemon_repository_impl_test.mocks.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const _kBrief = PokemonBrief(
  name: 'bulbasaur',
  url: 'https://pokeapi.co/api/v2/pokemon/1/',
);

const _kStats = PokemonStats(
  hp: 45,
  attack: 49,
  defense: 49,
  specialAttack: 65,
  specialDefense: 65,
  speed: 45,
);

const _kPokemon = Pokemon(
  id: 1,
  name: 'bulbasaur',
  height: 7,
  weight: 69,
  types: [],
  abilities: [],
  stats: _kStats,
  sprites: PokemonSprites(),
  speciesName: 'bulbasaur',
  speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/1/',
);

const _kSpecies = PokemonSpecies(
  id: 1,
  name: 'bulbasaur',
  description: 'A strange seed',
  genus: 'Seed Pokémon',
  eggGroups: [],
  genderRate: 1,
  evolutionChainUrl: 'https://pokeapi.co/api/v2/evolution-chain/1/',
);

const _kEvolution = EvolutionChain(
  id: 1,
  root: EvolutionNode(speciesName: 'bulbasaur', speciesId: 1, evolvesTo: []),
);

final _kError = ApiError(message: 'network error');

// ─── Mocks ────────────────────────────────────────────────────────────────────

@GenerateMocks([PokemonRemoteDataSource])
void main() {
  late MockPokemonRemoteDataSource mockDs;
  late PokemonRepositoryImpl repo;

  setUp(() {
    mockDs = MockPokemonRemoteDataSource();
    repo = PokemonRepositoryImpl(datasource: mockDs);
  });

  // ─── pageWithSize ──────────────────────────────────────────────────────────

  group('pageWithSize', () {
    test('returns Ok with correct items and offset on full page', () async {
      when(
        mockDs.listPokemon(limit: 20, offset: 0),
      ).thenAnswer((_) async => List.filled(20, _kBrief));
      when(
        mockDs.getDetailByUrl(any, includeMoves: anyNamed('includeMoves')),
      ).thenAnswer((_) async => _kPokemon);

      final result = await repo.pageWithSize(20, 0);

      result.when(
        ok: (data) {
          final (items, hasMore, offset) = data;
          expect(items.length, 20);
          expect(hasMore, true);
          expect(offset, 20);
        },
        err: (_) => fail('expected ok'),
      );
    });

    test(
      'hasMore=false when returned list is smaller than requested size',
      () async {
        when(
          mockDs.listPokemon(limit: 20, offset: 0),
        ).thenAnswer((_) async => [_kBrief]);
        when(
          mockDs.getDetailByUrl(any, includeMoves: anyNamed('includeMoves')),
        ).thenAnswer((_) async => _kPokemon);

        final result = await repo.pageWithSize(20, 0);

        result.when(
          ok: (data) => expect(data.$2, false),
          err: (_) => fail('expected ok'),
        );
      },
    );

    test('hasMore=false on empty list', () async {
      when(
        mockDs.listPokemon(
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        ),
      ).thenAnswer((_) async => []);

      final result = await repo.pageWithSize(20, 0);

      result.when(
        ok: (data) {
          final (items, hasMore, offset) = data;
          expect(items, isEmpty);
          expect(hasMore, false);
          expect(offset, 0);
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err wrapping ApiError from datasource', () async {
      when(
        mockDs.listPokemon(
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        ),
      ).thenThrow(_kError);

      final result = await repo.pageWithSize(20, 0);

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });

    test('wraps generic exception as Err(ApiError)', () async {
      when(
        mockDs.listPokemon(
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        ),
      ).thenThrow(Exception('timeout'));

      final result = await repo.pageWithSize(20, 0);

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, contains('timeout')),
      );
    });
  });

  // ─── page ──────────────────────────────────────────────────────────────────

  group('page', () {
    test('delegates to pageWithSize with default pageSize=20', () async {
      when(
        mockDs.listPokemon(limit: 20, offset: 0),
      ).thenAnswer((_) async => [_kBrief]);
      when(
        mockDs.getDetailByUrl(any, includeMoves: anyNamed('includeMoves')),
      ).thenAnswer((_) async => _kPokemon);

      await repo.page(0);

      verify(mockDs.listPokemon(limit: 20, offset: 0)).called(1);
    });
  });

  // ─── pageByType ────────────────────────────────────────────────────────────

  group('pageByType', () {
    test('returns first slice with hasMore=true when more exist', () async {
      final briefs = List.filled(3, _kBrief);
      when(mockDs.filterByType('grass')).thenAnswer((_) async => briefs);
      when(
        mockDs.getDetailByUrl(any, includeMoves: anyNamed('includeMoves')),
      ).thenAnswer((_) async => _kPokemon);

      final result = await repo.pageByType('grass', 2, 0);

      result.when(
        ok: (data) {
          final (items, hasMore, offset) = data;
          expect(items.length, 2);
          expect(hasMore, true);
          expect(offset, 2);
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('hasMore=false on last slice', () async {
      when(
        mockDs.filterByType('grass'),
      ).thenAnswer((_) async => [_kBrief, _kBrief]);
      when(
        mockDs.getDetailByUrl(any, includeMoves: anyNamed('includeMoves')),
      ).thenAnswer((_) async => _kPokemon);

      final result = await repo.pageByType('grass', 5, 0);

      result.when(
        ok: (data) => expect(data.$2, false),
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiError from datasource', () async {
      when(mockDs.filterByType(any)).thenThrow(_kError);

      final result = await repo.pageByType('fire', 20, 0);

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  // ─── pageSearch ────────────────────────────────────────────────────────────

  group('pageSearch', () {
    test('returns matching results with correct pagination', () async {
      when(mockDs.searchPokemon('bulb')).thenAnswer((_) async => [_kBrief]);
      when(
        mockDs.getDetailByUrl(any, includeMoves: anyNamed('includeMoves')),
      ).thenAnswer((_) async => _kPokemon);

      final result = await repo.pageSearch('bulb', 20, 0);

      result.when(
        ok: (data) {
          final (items, hasMore, offset) = data;
          expect(items, [_kPokemon]);
          expect(hasMore, false);
          expect(offset, 1);
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiError from datasource', () async {
      when(mockDs.searchPokemon(any)).thenThrow(_kError);

      final result = await repo.pageSearch('bad', 20, 0);

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  // ─── getById ───────────────────────────────────────────────────────────────

  group('getById', () {
    test('converts id to string and calls getDetailByName', () async {
      when(mockDs.getDetailByName('1')).thenAnswer((_) async => _kPokemon);

      final result = await repo.getById(1);

      result.when(ok: (p) => expect(p.id, 1), err: (_) => fail('expected ok'));
      verify(mockDs.getDetailByName('1')).called(1);
    });

    test('returns Err on ApiError', () async {
      when(mockDs.getDetailByName(any)).thenThrow(_kError);

      final result = await repo.getById(99);

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  // ─── getByName ─────────────────────────────────────────────────────────────

  group('getByName', () {
    test('returns Ok with pokemon on success', () async {
      when(
        mockDs.getDetailByName('bulbasaur'),
      ).thenAnswer((_) async => _kPokemon);

      final result = await repo.getByName('bulbasaur');

      result.when(
        ok: (p) => expect(p.name, 'bulbasaur'),
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiError', () async {
      when(mockDs.getDetailByName(any)).thenThrow(_kError);

      final result = await repo.getByName('unknown');

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  // ─── getSpecies ────────────────────────────────────────────────────────────

  group('getSpecies', () {
    test('delegates to getSpeciesByUrl and returns Ok', () async {
      const url = 'https://pokeapi.co/api/v2/pokemon-species/1/';
      when(mockDs.getSpeciesByUrl(url)).thenAnswer((_) async => _kSpecies);

      final result = await repo.getSpecies(url);

      result.when(
        ok: (s) => expect(s.name, 'bulbasaur'),
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiError', () async {
      when(mockDs.getSpeciesByUrl(any)).thenThrow(_kError);

      final result = await repo.getSpecies('bad-url');

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  // ─── getEvolutionChain ─────────────────────────────────────────────────────

  group('getEvolutionChain', () {
    test('delegates to datasource and returns Ok', () async {
      const url = 'https://pokeapi.co/api/v2/evolution-chain/1/';
      when(mockDs.getEvolutionChain(url)).thenAnswer((_) async => _kEvolution);

      final result = await repo.getEvolutionChain(url);

      result.when(
        ok: (e) {
          expect(e.id, 1);
          expect(e.root.speciesName, 'bulbasaur');
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiError', () async {
      when(mockDs.getEvolutionChain(any)).thenThrow(_kError);

      final result = await repo.getEvolutionChain('bad-url');

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });
}
