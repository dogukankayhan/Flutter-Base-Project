import 'package:flutter_kit_auth/auth/bloc/auth_bloc.dart';
import 'package:flutter_kit_auth/auth/data/remote/auth_remote_datasource.dart';
import 'package:flutter_kit_auth/auth/data/repository/auth_repository_impl.dart';
import 'package:flutter_kit_auth/auth/domain/repository/auth_repository.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/apple_sign_in_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/google_sign_in_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/guest_sign_in_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/login_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/logout_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/me_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/refresh_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/register_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/update_profile_usecase.dart';
import 'package:flutter_kit_auth/auth/manager/auth_manager.dart';
import 'package:flutter_kit_auth/auth/token/token_store.dart';
import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart';
import 'package:get_it/get_it.dart';

/// Auth paketinin DI kurulumu.
/// `apiManager` ve `tokenStore` dışarıdan verilir.
Future<void> setupAuth({
  required GetIt getIt,
  required ApiManager apiManager,
  required TokenStore tokenStore,
}) async {
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiManager),
    );
  }
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

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
    tokenStore: tokenStore,
  );
  getIt.registerSingleton<AuthManager>(authManager);
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthManager>()));
}
