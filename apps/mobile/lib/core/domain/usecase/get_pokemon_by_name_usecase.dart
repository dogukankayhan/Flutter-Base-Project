import 'package:flutter_kit_network/core/network/error/api_error.dart';

import '../entity/pokemon_entity.dart';
import '../repository/pokemon_repository.dart';

class GetPokemonByNameUseCase {
  final PokemonRepository _repository;

  const GetPokemonByNameUseCase(this._repository);

  Future<Pokemon> call(String name) async {
    final result = await _repository.getByName(name);
    return result.when(
      ok: (data) => data,
      err: (e) => throw ApiError(message: e.message),
    );
  }
}
