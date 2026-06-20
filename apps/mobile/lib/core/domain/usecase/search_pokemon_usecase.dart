import 'package:flutter_kit_network/core/network/error/api_error.dart';

import '../entity/pokemon_entity.dart';
import '../repository/pokemon_repository.dart';

class SearchPokemonUseCase {
  final PokemonRepository _repository;

  const SearchPokemonUseCase(this._repository);

  Future<(List<Pokemon>, bool, int)> call({
    required String query,
    required int size,
    required int offset,
  }) async {
    final result = await _repository.pageSearch(query, size, offset);
    return result.when(
      ok: (data) => data,
      err: (e) => throw ApiError(message: e.message),
    );
  }
}
