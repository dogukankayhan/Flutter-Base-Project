import 'dart:async';
import '../../domain/entity/pokemon_entity.dart';
import '../../domain/repository/favorites_repository.dart';
import '../../domain/repository/pokemon_repository.dart';
import '../datasource/favorites_local_datasource.dart';

/// Implementation of FavoritesRepository
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource _localDataSource;
  final PokemonRepository _pokemonRepository;
  final _favoritesController = StreamController<Set<int>>.broadcast();

  FavoritesRepositoryImpl({
    required FavoritesLocalDataSource localDataSource,
    required PokemonRepository pokemonRepository,
  }) : _localDataSource = localDataSource,
       _pokemonRepository = pokemonRepository {
    // Broadcast initial state
    _emitCurrentFavorites();
  }

  @override
  Stream<Set<int>> get favoriteIdsStream => _favoritesController.stream;

  Future<void> _emitCurrentFavorites() async {
    final ids = await _localDataSource.getFavoriteIds();
    _favoritesController.add(ids);
  }

  @override
  Future<List<Pokemon>> getFavorites() async {
    final ids = await _localDataSource.getFavoriteIds();

    if (ids.isEmpty) {
      return [];
    }

    final results = <Pokemon>[];
    for (var id in ids) {
      final result = await _pokemonRepository.getById(id);
      result.when(ok: (pokemon) => results.add(pokemon), err: (_) {});
    }

    return results;
  }

  @override
  Future<void> addFavorite(int id) async {
    await _localDataSource.addFavorite(id);
    await _emitCurrentFavorites();
  }

  @override
  Future<void> removeFavorite(int id) async {
    await _localDataSource.removeFavorite(id);
    await _emitCurrentFavorites();
  }

  @override
  Future<bool> isFavorite(int id) async {
    return _localDataSource.isFavorite(id);
  }

  @override
  Future<bool> toggleFavorite(int id) async {
    final result = await _localDataSource.toggleFavorite(id);
    await _emitCurrentFavorites();
    return result;
  }

  @override
  Future<Set<int>> getFavoriteIds() async {
    return _localDataSource.getFavoriteIds();
  }

  @override
  Future<void> clearAll() async {
    await _localDataSource.clearAll();
    await _emitCurrentFavorites();
  }

  @override
  void dispose() {
    _favoritesController.close();
  }
}
