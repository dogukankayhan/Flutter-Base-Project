import 'package:flutter_kit_auth/auth/bloc/auth_bloc.dart';
import 'package:flutter_kit_auth/auth/data/remote/auth_remote_datasource.dart';
import 'package:flutter_kit_auth/auth/data/repository/auth_repository_impl.dart';
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
/// `apiManager` and `tokenStore` are provided externally.
Future<void> setupAuth({
  required GetIt getIt,
  required ApiManager apiManager,
  required TokenStore tokenStore,
}) async {
  final authRepository = AuthRepositoryImpl(
    AuthRemoteDataSourceImpl(apiManager),
  );

  final authManager = await AuthManager.create(
    loginUseCase: LoginUseCase(authRepository),
    registerUseCase: RegisterUseCase(authRepository),
    meUseCase: MeUseCase(authRepository),
    updateProfileUseCase: UpdateProfileUseCase(authRepository),
    logoutUseCase: LogoutUseCase(authRepository),
    refreshUseCase: RefreshUseCase(authRepository),
    appleSignInUseCase: AppleSignInUseCase(authRepository),
    googleSignInUseCase: GoogleSignInUseCase(authRepository),
    guestSignInUseCase: GuestSignInUseCase(authRepository),
    tokenStore: tokenStore,
  );
  getIt.registerSingleton<AuthManager>(authManager);
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthManager>()));
}
