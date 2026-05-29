import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_base_kit/core/networking/core/network/error/api_error.dart';
import 'package:flutter_base_kit/core/networking/core/utils/result.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/entity/auth_entity.dart';
import '../domain/entity/profile_entity.dart';
import '../domain/usecase/login_usecase.dart';
import '../domain/usecase/register_usecase.dart';
import '../domain/usecase/me_usecase.dart';
import '../domain/usecase/update_profile_usecase.dart';
import '../domain/usecase/logout_usecase.dart';
import '../domain/usecase/refresh_usecase.dart';
import '../domain/usecase/apple_sign_in_usecase.dart';
import '../domain/usecase/google_sign_in_usecase.dart';
import '../domain/usecase/guest_sign_in_usecase.dart';
import '../token/token_store.dart';

/// Singleton + Provider friendly: use ChangeNotifierProvider.value(value: AuthManager.instance)
class AuthManager extends ChangeNotifier {
  AuthManager._({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.meUseCase,
    required this.updateProfileUseCase,
    required this.logoutUseCase,
    required this.refreshUseCase,
    required this.appleSignInUseCase,
    required this.googleSignInUseCase,
    required this.guestSignInUseCase,
    required this.tokenStore,
  });

  static AuthManager? _instance;

  static AuthManager get instance {
    assert(_instance != null, 'AuthManager.init() must be called before accessing instance');
    return _instance!;
  }

  static bool get isInitialized => _instance != null;

  // ignore: invalid_use_of_visible_for_testing_member
  @visibleForTesting
  static void resetForTesting() => _instance = null;

  static Future<void> init({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required MeUseCase meUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required LogoutUseCase logoutUseCase,
    required RefreshUseCase refreshUseCase,
    required AppleSignInUseCase appleSignInUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required GuestSignInUseCase guestSignInUseCase,
    TokenStore? tokenStore,
  }) async {
    assert(_instance == null, 'AuthManager.init() called more than once');

    final store =
        tokenStore ?? SecureTokenStore(storage: const FlutterSecureStorage());
    _instance = AuthManager._(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      meUseCase: meUseCase,
      updateProfileUseCase: updateProfileUseCase,
      logoutUseCase: logoutUseCase,
      refreshUseCase: refreshUseCase,
      appleSignInUseCase: appleSignInUseCase,
      googleSignInUseCase: googleSignInUseCase,
      guestSignInUseCase: guestSignInUseCase,
      tokenStore: store,
    );
    // Load persisted tokens & maybe auto-login state
    _instance!._tokens = await store.read();
    if (_instance!._tokens != null) {
      await _instance!.fetchMe();
    }
  }

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final MeUseCase meUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final LogoutUseCase logoutUseCase;
  final RefreshUseCase refreshUseCase;
  final AppleSignInUseCase appleSignInUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final GuestSignInUseCase guestSignInUseCase;
  final TokenStore tokenStore;

  AuthTokens? _tokens;
  Profile? _profile;
  bool _busy = false;

  AuthTokens? get tokens => _tokens;
  Profile? get profile => _profile;
  bool get isLoggedIn => _tokens != null && (_tokens!.accessToken.isNotEmpty);
  bool get isBusy => _busy;

  Future<Result<void, ApiError>> login(String email, String password) async {
    _setBusy(true);
    try {
      final result = await loginUseCase(email: email, password: password);
      return await result.when(
        ok: (tokens) async {
          _tokens = tokens;
          await tokenStore.write(tokens);
          await fetchMe();
          return const Ok(null);
        },
        err: (error) => Err(error),
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<Result<void, ApiError>> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    _setBusy(true);
    try {
      final result = await registerUseCase(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      return await result.when(
        ok: (tokens) async {
          _tokens = tokens;
          await tokenStore.write(tokens);
          await fetchMe();
          return const Ok(null);
        },
        err: (error) => Err(error),
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<Result<void, ApiError>> fetchMe() async {
    final result = await meUseCase();
    return result.when(
      ok: (profile) {
        _profile = profile;
        notifyListeners();
        return const Ok(null);
      },
      err: (error) => Err(error),
    );
  }

  Future<Result<void, ApiError>> updateProfile(
    Map<String, dynamic> patch,
  ) async {
    _setBusy(true);
    try {
      final result = await updateProfileUseCase(patch);
      return result.when(
        ok: (profile) {
          _profile = profile;
          notifyListeners();
          return const Ok(null);
        },
        err: (error) => Err(error),
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> saveTokens(AuthTokens? tokens) async {
    _tokens = tokens;
    if (tokens == null) {
      await tokenStore.clear();
    } else {
      await tokenStore.write(tokens);
    }
    notifyListeners();
  }

  Future<Result<void, ApiError>> logout() async {
    try {
      final result = await logoutUseCase();
      await tokenStore.clear();
      _tokens = null;
      _profile = null;
      notifyListeners();
      return result.when(ok: (_) => const Ok(null), err: (error) => Err(error));
    } catch (exception) {
      await tokenStore.clear();
      _tokens = null;
      _profile = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<Result<AuthTokens?, ApiError>> refreshIfNeeded() async {
    final refreshToken = await tokenStore.readRefresh();
    if (refreshToken == null || refreshToken.isEmpty) return Ok(_tokens);
    final result = await refreshUseCase(refreshToken);
    return result.when(
      ok: (tokens) async {
        _tokens = tokens;
        await tokenStore.write(tokens);
        notifyListeners();
        return Ok(tokens);
      },
      err: (error) {
        // Refresh başarısız → session geçersiz, temizle
        _tokens = null;
        _profile = null;
        tokenStore.clear();
        notifyListeners();
        return Err(error);
      },
    );
  }

  Future<Result<void, ApiError>> signInWithApple(String idToken) async {
    _setBusy(true);
    try {
      final result = await appleSignInUseCase(idToken: idToken);
      return await result.when(
        ok: (tokens) async {
          _tokens = tokens;
          await tokenStore.write(tokens);
          await fetchMe();
          return const Ok(null);
        },
        err: (error) => Err(error),
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<Result<void, ApiError>> signInWithGoogle(String idToken) async {
    _setBusy(true);
    try {
      final result = await googleSignInUseCase(idToken: idToken);
      return await result.when(
        ok: (tokens) async {
          _tokens = tokens;
          await tokenStore.write(tokens);
          await fetchMe();
          return const Ok(null);
        },
        err: (error) => Err(error),
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<Result<void, ApiError>> signInAsGuest() async {
    _setBusy(true);
    try {
      final result = await guestSignInUseCase();
      return await result.when(
        ok: (tokens) async {
          _tokens = tokens;
          await tokenStore.write(tokens);
          await fetchMe();
          return const Ok(null);
        },
        err: (error) => Err(error),
      );
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }
}
