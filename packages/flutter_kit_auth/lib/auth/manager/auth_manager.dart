import 'dart:async';

import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
import '../bloc/auth_status.dart';
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

/// managed via getIt — static singleton pattern removed.
/// Injection: `getIt.registerSingleton(await AuthManager.create(...))`
class AuthManager {
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

  /// Creates the object and restores session if token is saved.
  static Future<AuthManager> create({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required MeUseCase meUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required LogoutUseCase logoutUseCase,
    required RefreshUseCase refreshUseCase,
    required AppleSignInUseCase appleSignInUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required GuestSignInUseCase guestSignInUseCase,
    required TokenStore tokenStore,
  }) async {
    final manager = AuthManager._(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      meUseCase: meUseCase,
      updateProfileUseCase: updateProfileUseCase,
      logoutUseCase: logoutUseCase,
      refreshUseCase: refreshUseCase,
      appleSignInUseCase: appleSignInUseCase,
      googleSignInUseCase: googleSignInUseCase,
      guestSignInUseCase: guestSignInUseCase,
      tokenStore: tokenStore,
    );
    manager._tokens = await tokenStore.read();
    if (manager._tokens != null) {
      await manager.fetchMe();
    }
    return manager;
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
  bool _isRefreshing = false;
  Completer<Result<AuthTokens?, ApiError>>? _refreshCompleter;

  final _statusController = StreamController<AuthStatus>.broadcast();

  /// Stream to listen for auth state changes.
  /// AuthBloc bu stream'e subscribe olur.
  Stream<AuthStatus> get statusStream => _statusController.stream;

  AuthTokens? get tokens => _tokens;
  Profile? get profile => _profile;
  bool get isLoggedIn => _tokens != null && (_tokens!.accessToken.isNotEmpty);
  bool get isBusy => _busy;

  void _notify() {
    if (_statusController.isClosed) return;
    _statusController.add(
      isLoggedIn && _profile != null
          ? AuthAuthenticated(_profile!)
          : const AuthUnauthenticated(),
    );
  }

  void dispose() {
    _statusController.close();
  }

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
        _notify();
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
          _notify();
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
    _notify();
  }

  Future<Result<void, ApiError>> logout() async {
    try {
      final result = await logoutUseCase();
      await tokenStore.clear();
      _tokens = null;
      _profile = null;
      _notify();
      return result.when(ok: (_) => const Ok(null), err: (error) => Err(error));
    } catch (exception) {
      await tokenStore.clear();
      _tokens = null;
      _profile = null;
      _notify();
      rethrow;
    }
  }

  Future<Result<AuthTokens?, ApiError>> refreshIfNeeded() async {
    if (_isRefreshing) return _refreshCompleter!.future;

    _isRefreshing = true;
    _refreshCompleter = Completer<Result<AuthTokens?, ApiError>>();
    Result<AuthTokens?, ApiError>? mapped;
    try {
      final refreshToken = await tokenStore.readRefresh();
      if (refreshToken == null || refreshToken.isEmpty) {
        mapped = Ok(_tokens);
        return mapped;
      }
      final result = await refreshUseCase(refreshToken);
      if (result.isOk) {
        final tokens = (result as Ok<AuthTokens, ApiError>).value;
        _tokens = tokens;
        await tokenStore.write(tokens);
        _notify();
        mapped = Ok(tokens);
      } else {
        // Refresh failed → session invalid, clear
        _tokens = null;
        _profile = null;
        tokenStore.clear();
        _notify();
        mapped = Err((result as Err<AuthTokens, ApiError>).error);
      }
      return mapped;
    } catch (e) {
      mapped = Err(ApiError(message: e.toString()));
      return mapped;
    } finally {
      _refreshCompleter!.complete(mapped ?? Ok(_tokens));
      _isRefreshing = false;
      _refreshCompleter = null;
    }
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
  }
}
