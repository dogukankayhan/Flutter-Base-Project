import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_kit_network/core/config/api_config.dart';
import 'package:flutter_kit_network/core/di/service_locator.dart'
    as network_di;
import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart'
    as netapi;

import 'package:flutter_kit_auth/auth/manager/auth_manager.dart';
import 'package:flutter_kit_auth/auth/domain/entity/auth_entity.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/login_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/register_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/me_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/update_profile_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/logout_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/refresh_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/apple_sign_in_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/google_sign_in_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/guest_sign_in_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/repository/auth_repository.dart';
import 'package:flutter_kit_auth/auth/data/repository/auth_repository_impl.dart';
import 'package:flutter_kit_auth/auth/data/remote/auth_remote_datasource.dart';
import 'package:flutter_kit_auth/auth/data/dto/auth_dto.dart';
import 'package:flutter_kit_auth/auth/token/token_store.dart';
import 'package:flutter_base_kit/core/managers/device_info_manager/manager/device_info_manager.dart';
import 'package:flutter_kit_purchase/revenuecat_manager.dart';
import 'package:flutter_kit_auth/auth/bloc/auth_bloc.dart';
import '../managers/navigation_manager/app_router.dart';
import '../managers/navigation_manager/guards.dart';

final getIt = GetIt.instance;

class Injection {
  Injection._();

  static Future<void> init({required ApiConfig apiConfig}) async {
    // ─────────────────────────────────────────────
    // Storage — network setup'tan önce, token provider'lar bunu kullanır
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );
    getIt.registerLazySingleton<TokenStore>(
      () => SecureTokenStore(storage: getIt<FlutterSecureStorage>()),
    );

    // ─────────────────────────────────────────────
    // Networking — service_locator'a delege edildi (tek kaynak)
    // ─────────────────────────────────────────────

    await network_di.setupNetworkingWithApiConfig(
      config: apiConfig,
      tokenProvider: () => getIt<TokenStore>().readAccess(),
      refreshTokenProvider: () => getIt<TokenStore>().readRefresh(),
      refreshTokenFunction: (rt) => _refreshToken(
        baseUrl: apiConfig.baseUrl,
        refreshToken: rt,
      ),
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
    // Auth — Data Layer
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<netapi.ApiManager>()),
    );
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );

    // ─────────────────────────────────────────────
    // Auth — Manager
    // ─────────────────────────────────────────────

    final authManager = await AuthManager.create(
      loginUseCase: LoginUseCase(getIt<AuthRepository>()),
      registerUseCase: RegisterUseCase(getIt<AuthRepository>()),
      meUseCase: MeUseCase(getIt<AuthRepository>()),
      updateProfileUseCase: UpdateProfileUseCase(getIt<AuthRepository>()),
      logoutUseCase: LogoutUseCase(getIt<AuthRepository>()),
      refreshUseCase: RefreshUseCase(getIt<AuthRepository>()),
      appleSignInUseCase: AppleSignInUseCase(getIt<AuthRepository>()),
      googleSignInUseCase: GoogleSignInUseCase(getIt<AuthRepository>()),
      guestSignInUseCase: GuestSignInUseCase(getIt<AuthRepository>()),
      tokenStore: getIt<TokenStore>(),
    );
    getIt.registerSingleton<AuthManager>(authManager);

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
    // BLoC
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthManager>()));

    // ─────────────────────────────────────────────
    // Navigation
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<GoRouter>(() {
      final notifier = AuthRouterNotifier(getIt<AuthBloc>());
      return AppRouter.create(auth: notifier);
    });
  }

  /// Refresh için bağımsız bare Dio — ana DioClient'ı kullanmak
  /// circular dependency yaratır (interceptor → manager → interceptor).
  static Future<String?> _refreshToken({
    required String baseUrl,
    required String refreshToken,
  }) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 15),
      ));
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      if (response.data == null) return null;
      return TokensDto.fromJson(response.data!).accessToken;
    } catch (_) {
      return null;
    }
  }

  static Future<void> reset() async => getIt.reset();
}
