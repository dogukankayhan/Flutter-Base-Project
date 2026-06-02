import 'package:flutter_kit_auth/auth/domain/entity/auth_entity.dart';
import 'package:flutter_kit_auth/auth/domain/entity/profile_entity.dart';
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
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_manager_test.mocks.dart';

@GenerateMocks([
  LoginUseCase,
  RegisterUseCase,
  MeUseCase,
  UpdateProfileUseCase,
  LogoutUseCase,
  RefreshUseCase,
  AppleSignInUseCase,
  GoogleSignInUseCase,
  GuestSignInUseCase,
  TokenStore,
])
void main() {
  late MockLoginUseCase mockLogin;
  late MockRegisterUseCase mockRegister;
  late MockMeUseCase mockMe;
  late MockUpdateProfileUseCase mockUpdateProfile;
  late MockLogoutUseCase mockLogout;
  late MockRefreshUseCase mockRefresh;
  late MockAppleSignInUseCase mockApple;
  late MockGoogleSignInUseCase mockGoogle;
  late MockGuestSignInUseCase mockGuest;
  late MockTokenStore mockTokenStore;

  const email = 'test@example.com';
  const password = 'pass123';
  const accessToken = 'access_token';
  const refreshToken = 'refresh_token';

  final tokens = AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  final profile = Profile(id: '1', email: email, firstName: 'John');
  final apiError = ApiError(statusCode: 401, message: 'Unauthorized');

  Future<AuthManager> buildManager({AuthTokens? storedTokens}) async {
    when(mockTokenStore.read()).thenAnswer((_) async => storedTokens);
    if (storedTokens != null) {
      when(mockMe()).thenAnswer((_) async => Ok(profile));
    }
    return AuthManager.create(
      loginUseCase: mockLogin,
      registerUseCase: mockRegister,
      meUseCase: mockMe,
      updateProfileUseCase: mockUpdateProfile,
      logoutUseCase: mockLogout,
      refreshUseCase: mockRefresh,
      appleSignInUseCase: mockApple,
      googleSignInUseCase: mockGoogle,
      guestSignInUseCase: mockGuest,
      tokenStore: mockTokenStore,
    );
  }

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockRegister = MockRegisterUseCase();
    mockMe = MockMeUseCase();
    mockUpdateProfile = MockUpdateProfileUseCase();
    mockLogout = MockLogoutUseCase();
    mockRefresh = MockRefreshUseCase();
    mockApple = MockAppleSignInUseCase();
    mockGoogle = MockGoogleSignInUseCase();
    mockGuest = MockGuestSignInUseCase();
    mockTokenStore = MockTokenStore();

    provideDummy<Result<AuthTokens, ApiError>>(Ok(AuthTokens(accessToken: '', refreshToken: null)));
    provideDummy<Result<Profile, ApiError>>(Ok(Profile(id: '')));
    provideDummy<Result<void, ApiError>>(const Ok(null));
    provideDummy<Result<AuthTokens?, ApiError>>(const Ok(null));
  });

  group('Initialization', () {
    test('starts logged out when no stored tokens', () async {
      final auth = await buildManager(storedTokens: null);
      expect(auth.isLoggedIn, false);
      expect(auth.tokens, null);
      expect(auth.profile, null);
    });

    test('restores session when stored tokens exist', () async {
      final auth = await buildManager(storedTokens: tokens);
      expect(auth.isLoggedIn, true);
      expect(auth.tokens, tokens);
      expect(auth.profile, profile);
      verify(mockMe()).called(1);
    });

    test('starts as not busy', () async {
      final auth = await buildManager();
      expect(auth.isBusy, false);
    });
  });

  group('Login', () {
    test('successful login updates state and persists tokens', () async {
      final auth = await buildManager();
      when(mockLogin(email: email, password: password)).thenAnswer((_) async => Ok(tokens));
      when(mockMe()).thenAnswer((_) async => Ok(profile));
      when(mockTokenStore.write(tokens)).thenAnswer((_) async {});

      final result = await auth.login(email, password);

      expect(result.isOk, true);
      expect(auth.isLoggedIn, true);
      expect(auth.tokens, tokens);
      expect(auth.profile, profile);
      expect(auth.isBusy, false);
      verify(mockTokenStore.write(tokens)).called(1);
    });

    test('failed login leaves state unchanged', () async {
      final auth = await buildManager();
      when(mockLogin(email: email, password: password)).thenAnswer((_) async => Err(apiError));

      final result = await auth.login(email, password);

      expect(result.isErr, true);
      expect(auth.isLoggedIn, false);
      verifyNever(mockTokenStore.write(any));
      verifyNever(mockMe());
    });

    test('isBusy is true during login', () async {
      final auth = await buildManager();
      bool busyDuringCall = false;
      when(mockLogin(email: email, password: password)).thenAnswer((_) async {
        busyDuringCall = auth.isBusy;
        return Ok(tokens);
      });
      when(mockMe()).thenAnswer((_) async => Ok(profile));
      when(mockTokenStore.write(tokens)).thenAnswer((_) async {});

      await auth.login(email, password);

      expect(busyDuringCall, true);
      expect(auth.isBusy, false);
    });

    test('empty access token is treated as logged out', () async {
      final auth = await buildManager();
      final emptyTokens = AuthTokens(accessToken: '', refreshToken: refreshToken);
      when(mockTokenStore.write(emptyTokens)).thenAnswer((_) async {});

      await auth.saveTokens(emptyTokens);

      expect(auth.isLoggedIn, false);
    });
  });

  group('Registration', () {
    test('successful registration logs user in', () async {
      final auth = await buildManager();
      when(mockRegister(email: email, password: password, firstName: 'John', lastName: 'Doe'))
          .thenAnswer((_) async => Ok(tokens));
      when(mockMe()).thenAnswer((_) async => Ok(profile));
      when(mockTokenStore.write(tokens)).thenAnswer((_) async {});

      final result = await auth.register(email: email, password: password, firstName: 'John', lastName: 'Doe');

      expect(result.isOk, true);
      expect(auth.isLoggedIn, true);
    });

    test('failed registration leaves state unchanged', () async {
      final auth = await buildManager();
      when(mockRegister(email: email, password: password)).thenAnswer((_) async => Err(apiError));

      final result = await auth.register(email: email, password: password);

      expect(result.isErr, true);
      expect(auth.isLoggedIn, false);
    });
  });

  group('Logout', () {
    test('successful logout clears all state', () async {
      final auth = await buildManager(storedTokens: tokens);
      when(mockLogout()).thenAnswer((_) async => const Ok(null));
      when(mockTokenStore.clear()).thenAnswer((_) async {});

      final result = await auth.logout();

      expect(result.isOk, true);
      expect(auth.isLoggedIn, false);
      expect(auth.tokens, null);
      expect(auth.profile, null);
      verify(mockTokenStore.clear()).called(1);
    });

    test('state is cleared even when API logout fails', () async {
      final auth = await buildManager(storedTokens: tokens);
      when(mockLogout()).thenAnswer((_) async => Err(apiError));
      when(mockTokenStore.clear()).thenAnswer((_) async {});

      final result = await auth.logout();

      expect(result.isErr, true);
      expect(auth.isLoggedIn, false);
      expect(auth.tokens, null);
      verify(mockTokenStore.clear()).called(1);
    });
  });

  group('Profile', () {
    test('fetchMe updates profile on success', () async {
      final auth = await buildManager(storedTokens: tokens);
      final newProfile = Profile(id: '2', email: 'new@test.com');
      when(mockMe()).thenAnswer((_) async => Ok(newProfile));

      final result = await auth.fetchMe();

      expect(result.isOk, true);
      expect(auth.profile, newProfile);
    });

    test('updateProfile updates profile on success', () async {
      final auth = await buildManager(storedTokens: tokens);
      final updated = Profile(id: '1', firstName: 'Jane');
      when(mockUpdateProfile({'firstName': 'Jane'})).thenAnswer((_) async => Ok(updated));

      final result = await auth.updateProfile({'firstName': 'Jane'});

      expect(result.isOk, true);
      expect(auth.profile, updated);
    });

    test('updateProfile keeps old profile on failure', () async {
      final auth = await buildManager(storedTokens: tokens);
      when(mockUpdateProfile(any)).thenAnswer((_) async => Err(apiError));

      await auth.updateProfile({'firstName': 'Bad'});

      expect(auth.profile, profile);
    });
  });

  group('Token Refresh', () {
    test('refreshIfNeeded updates tokens on success', () async {
      final auth = await buildManager(storedTokens: tokens);
      final newTokens = AuthTokens(accessToken: 'new_access', refreshToken: 'new_refresh');
      when(mockTokenStore.readRefresh()).thenAnswer((_) async => refreshToken);
      when(mockRefresh(refreshToken)).thenAnswer((_) async => Ok(newTokens));
      when(mockTokenStore.write(newTokens)).thenAnswer((_) async {});

      final result = await auth.refreshIfNeeded();

      expect(result.isOk, true);
      expect(auth.tokens, newTokens);
    });

    test('refreshIfNeeded returns existing tokens when no refresh token', () async {
      final auth = await buildManager(storedTokens: tokens);
      when(mockTokenStore.readRefresh()).thenAnswer((_) async => null);

      final result = await auth.refreshIfNeeded();

      expect(result.isOk, true);
      verifyNever(mockRefresh(any));
    });

    test('failed refresh clears session', () async {
      final auth = await buildManager(storedTokens: tokens);
      when(mockTokenStore.readRefresh()).thenAnswer((_) async => refreshToken);
      when(mockRefresh(refreshToken)).thenAnswer((_) async => Err(apiError));
      when(mockTokenStore.clear()).thenAnswer((_) async {});

      final result = await auth.refreshIfNeeded();

      expect(result.isErr, true);
      expect(auth.isLoggedIn, false);
    });
  });

  group('Social Sign-In', () {
    test('Apple sign-in success logs user in', () async {
      final auth = await buildManager();
      when(mockApple(idToken: 'apple_token')).thenAnswer((_) async => Ok(tokens));
      when(mockMe()).thenAnswer((_) async => Ok(profile));
      when(mockTokenStore.write(tokens)).thenAnswer((_) async {});

      final result = await auth.signInWithApple('apple_token');

      expect(result.isOk, true);
      expect(auth.isLoggedIn, true);
    });

    test('Google sign-in success logs user in', () async {
      final auth = await buildManager();
      when(mockGoogle(idToken: 'google_token')).thenAnswer((_) async => Ok(tokens));
      when(mockMe()).thenAnswer((_) async => Ok(profile));
      when(mockTokenStore.write(tokens)).thenAnswer((_) async {});

      final result = await auth.signInWithGoogle('google_token');

      expect(result.isOk, true);
      expect(auth.isLoggedIn, true);
    });

    test('guest sign-in success logs user in', () async {
      final auth = await buildManager();
      when(mockGuest()).thenAnswer((_) async => Ok(tokens));
      when(mockMe()).thenAnswer((_) async => Ok(profile));
      when(mockTokenStore.write(tokens)).thenAnswer((_) async {});

      final result = await auth.signInAsGuest();

      expect(result.isOk, true);
      expect(auth.isLoggedIn, true);
    });
  });

  group('Token Management', () {
    test('saveTokens persists and updates state', () async {
      final auth = await buildManager();
      when(mockTokenStore.write(tokens)).thenAnswer((_) async {});

      await auth.saveTokens(tokens);

      expect(auth.tokens, tokens);
      verify(mockTokenStore.write(tokens)).called(1);
    });

    test('saveTokens(null) clears and removes persisted tokens', () async {
      final auth = await buildManager(storedTokens: tokens);
      when(mockTokenStore.clear()).thenAnswer((_) async {});

      await auth.saveTokens(null);

      expect(auth.tokens, null);
      verify(mockTokenStore.clear()).called(1);
    });
  });

  group('ChangeNotifier', () {
    test('notifies listeners on login', () async {
      final auth = await buildManager();
      int notifyCount = 0;
      auth.addListener(() => notifyCount++);

      when(mockLogin(email: email, password: password)).thenAnswer((_) async => Ok(tokens));
      when(mockMe()).thenAnswer((_) async => Ok(profile));
      when(mockTokenStore.write(tokens)).thenAnswer((_) async {});

      await auth.login(email, password);

      expect(notifyCount, greaterThan(0));
    });

    test('notifies listeners on logout', () async {
      final auth = await buildManager(storedTokens: tokens);
      int notifyCount = 0;
      auth.addListener(() => notifyCount++);

      when(mockLogout()).thenAnswer((_) async => const Ok(null));
      when(mockTokenStore.clear()).thenAnswer((_) async {});
      await auth.logout();

      expect(notifyCount, greaterThan(0));
    });
  });
}
