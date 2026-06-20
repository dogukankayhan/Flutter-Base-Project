import 'package:flutter_kit_network/core/network/error/api_error.dart';

import '../entity/pokemon_entity.dart';
import '../repository/pokemon_repository.dart';

class GetPokemonByIdUseCase {
  final PokemonRepository _repository;

  const GetPokemonByIdUseCase(this._repository);

  Future<Pokemon> call(int id) async {
    final result = await _repository.getById(id);
    return result.when(
      ok: (data) => data,
      err: (e) => throw ApiError(message: e.message),
    );
  }
}
