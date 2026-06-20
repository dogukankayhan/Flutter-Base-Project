import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart';
import 'package:get_it/get_it.dart';

import '../../data/repository/user_repository_impl.dart';
import '../../domain/repository/user_repository.dart';

void setupFeatureModule(GetIt getIt) {
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<ApiManager>()),
  );
}
