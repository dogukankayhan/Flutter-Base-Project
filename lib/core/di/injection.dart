import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_base_kit/core/config/app_environment.dart';
import 'package:flutter_base_kit/core/networking/core/config/api_config.dart';
import 'package:flutter_base_kit/core/networking/core/network/serializer/json_serializer.dart';
import 'package:flutter_base_kit/core/networking/core/network/serializer/serializer_interface.dart';
import 'package:flutter_base_kit/core/networking/core/network/client/http_client_interface.dart'
    as net;
import 'package:flutter_base_kit/core/networking/core/network/client/dio_client.dart';
import 'package:flutter_base_kit/core/networking/core/network/api/api_manager_interface.dart'
    as netapi;
import 'package:flutter_base_kit/core/networking/core/network/api/api_manager.dart';
import 'package:flutter_base_kit/core/networking/core/network/connectivity/network_info.dart';

import 'package:flutter_base_kit/core/managers/auth_manager/auth/manager/auth_manager.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/login_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/register_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/me_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/update_profile_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/logout_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/refresh_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/apple_sign_in_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/google_sign_in_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/guest_sign_in_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/repository/auth_repository.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/data/repository/auth_repository_impl.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/data/remote/auth_remote_datasource.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/token/token_store.dart';
import 'package:flutter_base_kit/core/managers/device_info_manager/manager/device_info_manager.dart';
import '../managers/revenuecat_manager/revenuecat_manager.dart';
import '../managers/auth_manager/auth/bloc/auth_bloc.dart';
import '../managers/navigation_manager/app_router.dart';
import '../managers/navigation_manager/guards.dart';

final getIt = GetIt.instance;

class Injection {
  Injection._();

  static Future<void> init() async {
    // ─────────────────────────────────────────────
    // Core Configuration
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<ApiConfig>(
      () => ApiConfig(
        baseUrl: AppConfig.instance.baseUrl,
        enableLogging: !AppConfig.instance.isProd,
      ),
    );

    // ─────────────────────────────────────────────
    // Networking Layer
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<Serializer>(() => JsonSerializer());

    getIt.registerLazySingleton<Connectivity>(() => Connectivity());

    getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(getIt<Connectivity>()),
    );

    getIt.registerLazySingleton<net.HttpClient>(
      () => DioClient(getIt<ApiConfig>(), networkInfo: getIt<NetworkInfo>()),
    );

    getIt.registerLazySingleton<netapi.ApiManager>(
      () => DioApiManager(
        client: getIt<net.HttpClient>(),
        serializer: getIt<Serializer>(),
      ),
    );

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
    // Auth — Data Layer
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<netapi.ApiManager>()),
    );

    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );

    // ─────────────────────────────────────────────
    // Auth — Manager (singleton, app yaşam döngüsü boyunca yaşar)
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<AuthManager>(
      () {
        if (!AuthManager.isInitialized) {
          throw StateError(
            'AuthManager must be initialized via AuthManager.init() first',
          );
        }
        return AuthManager.instance;
      },
    );

    await AuthManager.init(
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
    // BLoC (app yaşam döngüsü boyunca yaşar)
    // ─────────────────────────────────────────────

    getIt.registerLazySingleton<AuthBloc>(() => AuthBloc());

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
