import 'package:flutter_kit_auth/auth/bloc/auth_bloc.dart';
import 'package:flutter_kit_auth/auth/data/repository/auth_repository_impl.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/guest_sign_in_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/login_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/logout_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/me_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/password_reset_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/refresh_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/register_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/social_sign_in_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/update_profile_usecase.dart';
import 'package:flutter_kit_auth/auth/manager/auth_manager.dart';
import 'package:flutter_kit_auth/auth/service/social_auth_service.dart';
import 'package:flutter_kit_auth/auth/token/token_store.dart';
import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart';
import 'package:get_it/get_it.dart';

/// Dependency Injection setup for the Auth package.
/// `apiManager` and `tokenStore` are provided externally.
///
/// [fcmTokenProvider] is optional — pass it only once the app layer has
/// wired up `flutter_kit_firebase`; see [FcmTokenProvider].
///
/// [googleServerClientId] is optional — pass it (from the app's own OAuth
/// client config, never hardcoded here) to register [SocialAuthService] for
/// Google/Apple sign-in. Left null, no social sign-in UI is available and the
/// registration is skipped.
///
/// [refreshApiManager] should be an [ApiManager] instance with no
/// auth/refresh interceptors attached, used only for the refresh-token call
/// — see [AuthRepositoryImpl.refreshApi]. Left null, [apiManager] is reused,
/// which is fine as long as nothing wires that instance's refresh flow back
/// through this same call.
Future<void> setupAuth({
  required GetIt getIt,
  required ApiManager apiManager,
  required TokenStore tokenStore,
  FcmTokenProvider? fcmTokenProvider,
  String? googleServerClientId,
  ApiManager? refreshApiManager,
}) async {
  // Stateless pass-through repository — built once here, not registered in
  // GetIt (see CLAUDE.md DI rules).
  final authRepository = AuthRepositoryImpl(
    apiManager,
    refreshApi: refreshApiManager,
  );

  final authManager = await AuthManager.create(
    loginUseCase: LoginUseCase(authRepository),
    registerUseCase: RegisterUseCase(authRepository),
    meUseCase: MeUseCase(authRepository),
    updateProfileUseCase: UpdateProfileUseCase(authRepository),
    logoutUseCase: LogoutUseCase(authRepository),
    refreshUseCase: RefreshUseCase(authRepository),
    socialSignInUseCase: SocialSignInUseCase(authRepository),
    guestSignInUseCase: GuestSignInUseCase(authRepository),
    startPasswordResetUseCase: StartPasswordResetUseCase(authRepository),
    verifyPasswordResetUseCase: VerifyPasswordResetUseCase(authRepository),
    completePasswordResetUseCase: CompletePasswordResetUseCase(authRepository),
    tokenStore: tokenStore,
    fcmTokenProvider: fcmTokenProvider,
  );
  getIt.registerSingleton<AuthManager>(authManager);
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthManager>()));

  // Holds Google's initialize-once flag → single shared instance.
  if (googleServerClientId != null) {
    getIt.registerLazySingleton<SocialAuthService>(
      () => SocialAuthService(googleServerClientId: googleServerClientId),
    );
  }
}
