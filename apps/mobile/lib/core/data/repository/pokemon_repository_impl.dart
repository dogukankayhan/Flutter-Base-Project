import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';

import '../../domain/entity/evolution_chain_entity.dart';
import '../../domain/entity/pokemon_entity.dart';
import '../../domain/entity/pokemon_species_entity.dart';
import '../../domain/repository/pokemon_repository.dart';
import '../datasource/pokemon_remote_datasource.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource _datasource;
  final int pageSize;

  PokemonRepositoryImpl({
    required PokemonRemoteDataSource datasource,
    this.pageSize = 20,
  }) : _datasource = datasource;

  @override
  Future<Result<(List<Pokemon>, bool, int), ApiError>> page(int offset) {
    return pageWithSize(pageSize, offset);
  }

  @override
  Future<Result<(List<Pokemon>, bool, int), ApiError>> pageWithSize(
    int size,
    int offset,
  ) async {
    try {
      final briefs = await _datasource.listPokemon(limit: size, offset: offset);
      final details = await _batchFetchDetails(briefs, concurrency: 5);
      final hasMore = briefs.isNotEmpty && briefs.length == size;
      return Ok((details, hasMore, offset + briefs.length));
    } on ApiError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<(List<Pokemon>, bool, int), ApiError>> pageByType(
    String type,
    int size,
    int offset,
  ) async {
    try {
      final briefs = await _datasource.filterByType(type);
      final batch = briefs.skip(offset).take(size).toList();
      final details = await _batchFetchDetails(batch, concurrency: 5);
      final hasMore = (offset + batch.length) < briefs.length;
      return Ok((details, hasMore, offset + batch.length));
    } on ApiError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<(List<Pokemon>, bool, int), ApiError>> pageSearch(
    String query,
    int size,
    int offset,
  ) async {
    try {
      final briefs = await _datasource.searchPokemon(query);
      final batch = briefs.skip(offset).take(size).toList();
      final details = await _batchFetchDetails(batch, concurrency: 5);
      final hasMore = (offset + batch.length) < briefs.length;
      return Ok((details, hasMore, offset + batch.length));
    } on ApiError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<Pokemon, ApiError>> getById(int id) async {
    try {
      return Ok(await _datasource.getDetailByName(id.toString()));
    } on ApiError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<Pokemon, ApiError>> getByName(String name) async {
    try {
      return Ok(await _datasource.getDetailByName(name));
    } on ApiError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<PokemonSpecies, ApiError>> getSpecies(String url) async {
    try {
      return Ok(await _datasource.getSpeciesByUrl(url));
    } on ApiError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<EvolutionChain, ApiError>> getEvolutionChain(String url) async {
    try {
      return Ok(await _datasource.getEvolutionChain(url));
    } on ApiError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  // Batch fetch with concurrency limit to prevent network congestion
  Future<List<Pokemon>> _batchFetchDetails(
    List briefs, {
    int concurrency = 5,
  }) async {
    final results = <Pokemon>[];
    for (var i = 0; i < briefs.length; i += concurrency) {
      final batch = briefs.skip(i).take(concurrency).toList();
      final batchDetails = await Future.wait(
        batch.map(
          (b) => _datasource.getDetailByUrl(b.url, includeMoves: false),
        ),
        eagerError: true,
      );
      results.addAll(batchDetails);
    }
    return results;
  }
}
