import 'package:flutter_base_kit/core/data/repository/favorites_repository_impl.dart';
import 'package:flutter_base_kit/core/domain/repository/favorites_repository.dart';
import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasource/favorites_local_datasource.dart';
import '../../data/datasource/pokemon_remote_datasource.dart';
import '../../data/repository/pokemon_repository_impl.dart';
import '../../domain/repository/pokemon_repository.dart';

void setupPokemonModule(GetIt getIt) {
  getIt.registerLazySingleton<PokemonRepository>(
    () => PokemonRepositoryImpl(
      datasource: PokemonRemoteDataSourceImpl(api: getIt<ApiManager>()),
    ),
  );

  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      localDataSource: FavoritesLocalDataSource(getIt<SharedPreferences>()),
      pokemonRepository: getIt<PokemonRepository>(),
    ),
  );
}
