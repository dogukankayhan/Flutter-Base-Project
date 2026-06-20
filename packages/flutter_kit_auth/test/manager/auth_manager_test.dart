import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kit_auth/auth/manager/auth_manager.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/login_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/register_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/me_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/update_profile_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/logout_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/refresh_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/apple_sign_in_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/google_sign_in_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/usecase/guest_sign_in_usecase.dart';
import 'package:flutter_kit_auth/auth/domain/entity/auth_entity.dart';
import 'package:flutter_kit_auth/auth/domain/entity/profile_entity.dart';
import 'package:flutter_kit_auth/auth/token/token_store.dart';
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'auth_manager_test.mocks.dart';

// Annotations for creating mock classes
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
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockMeUseCase mockMeUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockRefreshUseCase mockRefreshUseCase;
  late MockAppleSignInUseCase mockAppleSignInUseCase;
  late MockGoogleSignInUseCase mockGoogleSignInUseCase;
  late MockGuestSignInUseCase mockGuestSignInUseCase;
  late MockTokenStore mockTokenStore;
  late AuthManager authManager;

  // Test verileri
  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testFirstName = 'John';
  const testLastName = 'Doe';
  const testAccessToken = 'test_access_token';
  const testRefreshToken = 'test_refresh_token';

  final testTokens = AuthTokens(
    accessToken: testAccessToken,
    refreshToken: testRefreshToken,
  );

  final testProfile = Profile(
    id: '123',
    email: testEmail,
    firstName: testFirstName,
    lastName: testLastName,
  );

  final testApiError = ApiError(statusCode: 401, message: 'Unauthorized');

  setUp(() {
    // To allow Mockito to generate the Result<T,E> type as dummy
    provideDummy<Result<AuthTokens, ApiError>>(
      Ok(AuthTokens(accessToken: '', refreshToken: null)),
    );
    provideDummy<Result<Profile, ApiError>>(Ok(Profile(id: '')));
    provideDummy<Result<void, ApiError>>(const Ok(null));
    provideDummy<Result<AuthTokens?, ApiError>>(const Ok(null));

    // Create mocks before each test
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockMeUseCase = MockMeUseCase();
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockRefreshUseCase = MockRefreshUseCase();
    mockAppleSignInUseCase = MockAppleSignInUseCase();
    mockGoogleSignInUseCase = MockGoogleSignInUseCase();
    mockGuestSignInUseCase = MockGuestSignInUseCase();
    mockTokenStore = MockTokenStore();
  });

  group('AuthManager Initialization Tests', () {
    test('should initialize with existing tokens and fetch profile', () async {
      // Arrange
      when(mockTokenStore.read()).thenAnswer((_) async => testTokens);
      when(mockMeUseCase()).thenAnswer((_) async => Ok(testProfile));

      // Act
      authManager = await AuthManager.create(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        meUseCase: mockMeUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshUseCase: mockRefreshUseCase,
        appleSignInUseCase: mockAppleSignInUseCase,
        googleSignInUseCase: mockGoogleSignInUseCase,
        guestSignInUseCase: mockGuestSignInUseCase,
        tokenStore: mockTokenStore,
      );

      // Assert
      expect(authManager.isLoggedIn, true);
      expect(authManager.tokens, testTokens);
      expect(authManager.profile, testProfile);
      verify(mockTokenStore.read()).called(1);
      verify(mockMeUseCase()).called(1);
    });

    test('should initialize without tokens', () async {
      // Arrange
      when(mockTokenStore.read()).thenAnswer((_) async => null);

      // Act
      authManager = await AuthManager.create(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        meUseCase: mockMeUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshUseCase: mockRefreshUseCase,
        appleSignInUseCase: mockAppleSignInUseCase,
        googleSignInUseCase: mockGoogleSignInUseCase,
        guestSignInUseCase: mockGuestSignInUseCase,
        tokenStore: mockTokenStore,
      );

      // Assert
      expect(authManager.isLoggedIn, false);
      expect(authManager.tokens, null);
      expect(authManager.profile, null);
      verify(mockTokenStore.read()).called(1);
      verifyNever(mockMeUseCase());
    });
  });

  group('AuthManager Login Tests', () {
    setUp(() async {
      when(mockTokenStore.read()).thenAnswer((_) async => null);
      authManager = await AuthManager.create(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        meUseCase: mockMeUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshUseCase: mockRefreshUseCase,
        appleSignInUseCase: mockAppleSignInUseCase,
        googleSignInUseCase: mockGoogleSignInUseCase,
        guestSignInUseCase: mockGuestSignInUseCase,
        tokenStore: mockTokenStore,
      );
    });

    test('should login successfully', () async {
      // Arrange
      when(
        mockLoginUseCase(email: testEmail, password: testPassword),
      ).thenAnswer((_) async => Ok(testTokens));
      when(mockMeUseCase()).thenAnswer((_) async => Ok(testProfile));
      when(mockTokenStore.write(testTokens)).thenAnswer((_) async {});

      // Act
      final result = await authManager.login(testEmail, testPassword);

      // Assert
      expect(result.isOk, true);
      expect(authManager.isLoggedIn, true);
      expect(authManager.tokens, testTokens);
      expect(authManager.profile, testProfile);
      expect(authManager.isBusy, false);
      verify(
        mockLoginUseCase(email: testEmail, password: testPassword),
      ).called(1);
      verify(mockTokenStore.write(testTokens)).called(1);
      verify(mockMeUseCase()).called(1);
    });

    test('should handle login failure', () async {
      // Arrange
      when(
        mockLoginUseCase(email: testEmail, password: testPassword),
      ).thenAnswer((_) async => Err(testApiError));

      // Act
      final result = await authManager.login(testEmail, testPassword);

      // Assert
      expect(result.isErr, true);
      expect(authManager.isLoggedIn, false);
      expect(authManager.tokens, null);
      expect(authManager.isBusy, false);
      verify(
        mockLoginUseCase(email: testEmail, password: testPassword),
      ).called(1);
      verifyNever(mockTokenStore.write(any));
      verifyNever(mockMeUseCase());
    });

    test('should set and unset busy state during login', () async {
      // Arrange
      bool busyDuringLogin = false;
      when(
        mockLoginUseCase(email: testEmail, password: testPassword),
      ).thenAnswer((_) async {
        busyDuringLogin = authManager.isBusy;
        return Ok(testTokens);
      });
      when(mockMeUseCase()).thenAnswer((_) async => Ok(testProfile));
      when(mockTokenStore.write(testTokens)).thenAnswer((_) async {});

      // Act
      await authManager.login(testEmail, testPassword);

      // Assert
      expect(busyDuringLogin, true);
      expect(authManager.isBusy, false);
    });
  });

  group('AuthManager Register Tests', () {
    setUp(() async {
      when(mockTokenStore.read()).thenAnswer((_) async => null);
      authManager = await AuthManager.create(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        meUseCase: mockMeUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshUseCase: mockRefreshUseCase,
        appleSignInUseCase: mockAppleSignInUseCase,
        googleSignInUseCase: mockGoogleSignInUseCase,
        guestSignInUseCase: mockGuestSignInUseCase,
        tokenStore: mockTokenStore,
      );
    });

    test('should register successfully', () async {
      // Arrange
      when(
        mockRegisterUseCase(
          email: testEmail,
          password: testPassword,
          firstName: testFirstName,
          lastName: testLastName,
        ),
      ).thenAnswer((_) async => Ok(testTokens));
      when(mockMeUseCase()).thenAnswer((_) async => Ok(testProfile));
      when(mockTokenStore.write(testTokens)).thenAnswer((_) async {});

      // Act
      final result = await authManager.register(
        email: testEmail,
        password: testPassword,
        firstName: testFirstName,
        lastName: testLastName,
      );

      // Assert
      expect(result.isOk, true);
      expect(authManager.isLoggedIn, true);
      expect(authManager.tokens, testTokens);
      expect(authManager.profile, testProfile);
      verify(
        mockRegisterUseCase(
          email: testEmail,
          password: testPassword,
          firstName: testFirstName,
          lastName: testLastName,
        ),
      ).called(1);
      verify(mockTokenStore.write(testTokens)).called(1);
      verify(mockMeUseCase()).called(1);
    });

    test('should handle register failure', () async {
      // Arrange
      when(
        mockRegisterUseCase(email: testEmail, password: testPassword),
      ).thenAnswer((_) async => Err(testApiError));

      // Act
      final result = await authManager.register(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.isErr, true);
      expect(authManager.isLoggedIn, false);
      verifyNever(mockTokenStore.write(any));
      verifyNever(mockMeUseCase());
    });
  });

  group('AuthManager Profile Tests', () {
    setUp(() async {
      when(mockTokenStore.read()).thenAnswer((_) async => testTokens);
      when(mockMeUseCase()).thenAnswer((_) async => Ok(testProfile));
      authManager = await AuthManager.create(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        meUseCase: mockMeUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshUseCase: mockRefreshUseCase,
        appleSignInUseCase: mockAppleSignInUseCase,
        googleSignInUseCase: mockGoogleSignInUseCase,
        guestSignInUseCase: mockGuestSignInUseCase,
        tokenStore: mockTokenStore,
      );
    });

    test('should fetch profile successfully', () async {
      // Arrange
      final newProfile = Profile(
        id: '456',
        email: 'new@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
      );
      when(mockMeUseCase()).thenAnswer((_) async => Ok(newProfile));

      // Act
      final result = await authManager.fetchMe();

      // Assert
      expect(result.isOk, true);
      expect(authManager.profile, newProfile);
    });

    test('should update profile successfully', () async {
      // Arrange
      final updatedProfile = Profile(
        id: testProfile.id,
        email: testProfile.email,
        firstName: 'UpdatedFirstName',
        lastName: testProfile.lastName,
      );
      final patch = {'firstName': 'UpdatedFirstName'};
      when(
        mockUpdateProfileUseCase(patch),
      ).thenAnswer((_) async => Ok(updatedProfile));

      // Act
      final result = await authManager.updateProfile(patch);

      // Assert
      expect(result.isOk, true);
      expect(authManager.profile, updatedProfile);
      expect(authManager.profile!.firstName, 'UpdatedFirstName');
      verify(mockUpdateProfileUseCase(patch)).called(1);
    });

    test('should handle profile update failure', () async {
      // Arrange
      final patch = {'firstName': 'UpdatedFirstName'};
      when(
        mockUpdateProfileUseCase(patch),
      ).thenAnswer((_) async => Err(testApiError));

      // Act
      final result = await authManager.updateProfile(patch);

      // Assert
      expect(result.isErr, true);
      expect(
        authManager.profile,
        testProfile,
      ); // Profile should remain unchanged
    });
  });

  group('AuthManager Logout Tests', () {
    setUp(() async {
      when(mockTokenStore.read()).thenAnswer((_) async => testTokens);
      when(mockMeUseCase()).thenAnswer((_) async => Ok(testProfile));
      authManager = await AuthManager.create(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        meUseCase: mockMeUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshUseCase: mockRefreshUseCase,
        appleSignInUseCase: mockAppleSignInUseCase,
        googleSignInUseCase: mockGoogleSignInUseCase,
        guestSignInUseCase: mockGuestSignInUseCase,
        tokenStore: mockTokenStore,
      );
    });

    test('should logout successfully', () async {
      // Arrange
      when(mockLogoutUseCase()).thenAnswer((_) async => const Ok(null));
      when(mockTokenStore.clear()).thenAnswer((_) async {});

      // Act
      final result = await authManager.logout();

      // Assert
      expect(result.isOk, true);
      expect(authManager.isLoggedIn, false);
      expect(authManager.tokens, null);
      expect(authManager.profile, null);
      verify(mockLogoutUseCase()).called(1);
      verify(mockTokenStore.clear()).called(1);
    });

    test('should clear local data even if logout API fails', () async {
      // Arrange
      when(mockLogoutUseCase()).thenAnswer((_) async => Err(testApiError));
      when(mockTokenStore.clear()).thenAnswer((_) async {});

      // Act
      final result = await authManager.logout();

      // Assert
      expect(result.isErr, true);
      expect(authManager.isLoggedIn, false);
      expect(authManager.tokens, null);
      expect(authManager.profile, null);
      verify(mockTokenStore.clear()).called(1);
    });
  });

  group('AuthManager Token Refresh Tests', () {
    setUp(() async {
      when(mockTokenStore.read()).thenAnswer((_) async => testTokens);
      when(mockMeUseCase()).thenAnswer((_) async => Ok(testProfile));
      authManager = await AuthManager.create(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        meUseCase: mockMeUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshUseCase: mockRefreshUseCase,
        appleSignInUseCase: mockAppleSignInUseCase,
        googleSignInUseCase: mockGoogleSignInUseCase,
        guestSignInUseCase: mockGuestSignInUseCase,
        tokenStore: mockTokenStore,
      );
    });

    test('should refresh tokens successfully', () async {
      // Arrange
      const newAccessToken = 'new_access_token';
      const newRefreshToken = 'new_refresh_token';
      final newTokens = AuthTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      when(
        mockTokenStore.readRefresh(),
      ).thenAnswer((_) async => testRefreshToken);
      when(
        mockRefreshUseCase(testRefreshToken),
      ).thenAnswer((_) async => Ok(newTokens));
      when(mockTokenStore.write(newTokens)).thenAnswer((_) async {});

      // Act
      final result = await authManager.refreshIfNeeded();

      // Assert
      expect(result.isOk, true);
      expect((result as Ok).value, newTokens);
      expect(authManager.tokens, newTokens);
      verify(mockRefreshUseCase(testRefreshToken)).called(1);
      verify(mockTokenStore.write(newTokens)).called(1);
    });

    test('should return existing tokens if no refresh token', () async {
      // Arrange
      when(mockTokenStore.readRefresh()).thenAnswer((_) async => null);

      // Act
      final result = await authManager.refreshIfNeeded();

      // Assert
      expect(result.isOk, true);
      expect((result as Ok).value, testTokens);
      verifyNever(mockRefreshUseCase(any));
    });

    test('should handle refresh failure gracefully', () async {
      // Arrange
      when(
        mockTokenStore.readRefresh(),
      ).thenAnswer((_) async => testRefreshToken);
      when(
        mockRefreshUseCase(testRefreshToken),
      ).thenAnswer((_) async => Err(testApiError));
      when(mockTokenStore.clear()).thenAnswer((_) async {});

      // Act
      final result = await authManager.refreshIfNeeded();

      // Assert — when refresh fails, Err is returned, state is cleared
      expect(result.isErr, true);
      expect(authManager.isLoggedIn, false);
      verify(mockRefreshUseCase(testRefreshToken)).called(1);
      verifyNever(mockTokenStore.write(any));
    });
  });

  group('AuthManager Token Management Tests', () {
    setUp(() async {
      when(mockTokenStore.read()).thenAnswer((_) async => null);
      authManager = await AuthManager.create(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        meUseCase: mockMeUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshUseCase: mockRefreshUseCase,
        appleSignInUseCase: mockAppleSignInUseCase,
        googleSignInUseCase: mockGoogleSignInUseCase,
        guestSignInUseCase: mockGuestSignInUseCase,
        tokenStore: mockTokenStore,
      );
    });

    test('should save tokens', () async {
      // Arrange
      when(mockTokenStore.write(testTokens)).thenAnswer((_) async {});

      // Act
      await authManager.saveTokens(testTokens);

      // Assert
      expect(authManager.tokens, testTokens);
      verify(mockTokenStore.write(testTokens)).called(1);
    });

    test('should clear tokens when saving null', () async {
      // Arrange
      when(mockTokenStore.clear()).thenAnswer((_) async {});

      // Act
      await authManager.saveTokens(null);

      // Assert
      expect(authManager.tokens, null);
      verify(mockTokenStore.clear()).called(1);
    });
  });

  group('AuthManager State Tests', () {
    setUp(() async {
      when(mockTokenStore.read()).thenAnswer((_) async => null);
      authManager = await AuthManager.create(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        meUseCase: mockMeUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshUseCase: mockRefreshUseCase,
        appleSignInUseCase: mockAppleSignInUseCase,
        googleSignInUseCase: mockGoogleSignInUseCase,
        guestSignInUseCase: mockGuestSignInUseCase,
        tokenStore: mockTokenStore,
      );
    });

    test('should report not logged in when no tokens', () {
      expect(authManager.isLoggedIn, false);
    });

    test('should report not logged in when access token is empty', () async {
      final emptyTokens = AuthTokens(
        accessToken: '',
        refreshToken: testRefreshToken,
      );
      when(mockTokenStore.write(emptyTokens)).thenAnswer((_) async {});
      await authManager.saveTokens(emptyTokens);

      expect(authManager.isLoggedIn, false);
    });

    test('should report logged in when has valid access token', () async {
      when(mockTokenStore.write(testTokens)).thenAnswer((_) async {});
      await authManager.saveTokens(testTokens);

      expect(authManager.isLoggedIn, true);
    });

    test('should not be busy initially', () {
      expect(authManager.isBusy, false);
    });
  });
}
