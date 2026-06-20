import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';

import '../entity/evolution_chain_entity.dart';
import '../entity/pokemon_entity.dart';
import '../entity/pokemon_species_entity.dart';

abstract class PokemonRepository {
  Future<Result<(List<Pokemon>, bool, int), ApiError>> page(int offset);
  Future<Result<(List<Pokemon>, bool, int), ApiError>> pageWithSize(
    int size,
    int offset,
  );
  Future<Result<(List<Pokemon>, bool, int), ApiError>> pageByType(
    String type,
    int size,
    int offset,
  );
  Future<Result<(List<Pokemon>, bool, int), ApiError>> pageSearch(
    String query,
    int size,
    int offset,
  );
  Future<Result<Pokemon, ApiError>> getById(int id);
  Future<Result<Pokemon, ApiError>> getByName(String name);
  Future<Result<PokemonSpecies, ApiError>> getSpecies(String url);
  Future<Result<EvolutionChain, ApiError>> getEvolutionChain(String url);
}
