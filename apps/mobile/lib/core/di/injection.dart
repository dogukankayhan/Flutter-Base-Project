import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_kit_network/core/config/api_config.dart';
import 'package:flutter_kit_network/core/di/service_locator.dart'
    as network_di;
import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart'
    as netapi;

import 'package:flutter_kit_auth/flutter_kit_auth.dart';
import 'package:flutter_base_kit/core/managers/device_info_manager/manager/device_info_manager.dart';
import 'package:flutter_kit_purchase/revenuecat_manager.dart';
import 'package:flutter_base_kit/core/domain/repository/user_repository.dart';
import 'package:flutter_base_kit/core/domain/usecase/get_user_profile_usecase.dart';
import 'package:flutter_base_kit/core/data/datasource/user_remote_datasource.dart';
import 'package:flutter_base_kit/core/data/repository/user_repository_impl.dart';
import '../managers/navigation_manager/app_router.dart';
import '../managers/navigation_manager/guards.dart';

final getIt = GetIt.instance;

class Injection {
  Injection._();

  static Future<void> init({required ApiConfig apiConfig}) async {
    // ─────────────────────────────────────────────
    // Storage
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );
    getIt.registerLazySingleton<TokenStore>(
      () => SecureTokenStore(storage: getIt<FlutterSecureStorage>()),
    );

    // ─────────────────────────────────────────────
    // Networking
    // ─────────────────────────────────────────────

    await network_di.setupNetworkingWithApiConfig(
      config: apiConfig,
      tokenProvider: () => getIt<TokenStore>().readAccess(),
      refreshTokenProvider: () => getIt<TokenStore>().readRefresh(),
      refreshTokenFunction: (_) async {
        final result = await getIt<AuthManager>().refreshIfNeeded();
        return result.when(ok: (tokens) => tokens?.accessToken, err: (_) => null);
      },
      onTokenRefreshed: (accessToken, refreshToken) {
        final tokens = AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        unawaited(getIt<TokenStore>().write(tokens));
        if (getIt.isRegistered<AuthManager>()) {
          unawaited(getIt<AuthManager>().saveTokens(tokens));
        }
      },
    );

    // ─────────────────────────────────────────────
    // Auth
    // ─────────────────────────────────────────────

    await setupAuth(
      getIt: getIt,
      apiManager: getIt<netapi.ApiManager>(),
      tokenStore: getIt<TokenStore>(),
    );

    // ─────────────────────────────────────────────
    // Core Domain & Data Layer
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(getIt<netapi.ApiManager>()),
    );
    getIt.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(getIt<UserRemoteDataSource>()),
    );
    getIt.registerLazySingleton<GetUserProfileUseCase>(
      () => GetUserProfileUseCase(getIt<UserRepository>()),
    );

    // ─────────────────────────────────────────────
    // Managers
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<DeviceInfoManager>(
      () => DeviceInfoManager.instance,
    );
    getIt.registerLazySingleton<RevenueCatManager>(
      () => RevenueCatManager.instance,
    );

    // ─────────────────────────────────────────────
    // Navigation
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<GoRouter>(() {
      final notifier = AuthRouterNotifier(getIt<AuthBloc>());
      return AppRouter.create(auth: notifier);
    });
  }

  static Future<void> reset() async => getIt.reset();
}
