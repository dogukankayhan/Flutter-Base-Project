import 'package:flutter_kit_network/core/network/error/api_error.dart';

import '../entity/pokemon_species_entity.dart';
import '../repository/pokemon_repository.dart';

class GetPokemonSpeciesUseCase {
  final PokemonRepository _repository;

  const GetPokemonSpeciesUseCase(this._repository);

  Future<PokemonSpecies> call(String url) async {
    final result = await _repository.getSpecies(url);
    return result.when(
      ok: (data) => data,
      err: (e) => throw ApiError(message: e.message),
    );
  }
}
