import 'package:flutter_kit_network/core/network/error/api_error.dart';

import '../entity/evolution_chain_entity.dart';
import '../repository/pokemon_repository.dart';

class GetEvolutionChainUseCase {
  final PokemonRepository _repository;

  const GetEvolutionChainUseCase(this._repository);

  Future<EvolutionChain> call(String url) async {
    final result = await _repository.getEvolutionChain(url);
    return result.when(
      ok: (data) => data,
      err: (e) => throw ApiError(message: e.message),
    );
  }
}
