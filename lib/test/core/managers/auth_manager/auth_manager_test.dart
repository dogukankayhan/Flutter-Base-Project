/* import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/manager/auth_manager.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/login_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/register_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/me_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/update_profile_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/logout_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/usecase/refresh_usecase.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/token/token_store.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/entity/auth_entity.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/domain/entity/profile_entity.dart';
import 'package:flutter_base_kit/core/networking/core/network/error/api_error.dart';
import 'package:flutter_base_kit/core/networking/core/utils/result.dart';

@GenerateMocks([
  LoginUseCase,
  RegisterUseCase,
  MeUseCase,
  UpdateProfileUseCase,
  LogoutUseCase,
  RefreshUseCase,
  TokenStore,
])


void main() {
  late AuthManager authManager;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockMeUseCase mockMeUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockRefreshUseCase mockRefreshUseCase;
  late MockTokenStore mockTokenStore;

  setUp(() async {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockMeUseCase = MockMeUseCase();
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockRefreshUseCase = MockRefreshUseCase();
    mockTokenStore = MockTokenStore();

    // Setup default mock behaviors
    when(mockTokenStore.read()).thenAnswer((_) async => null);
    when(mockTokenStore.write(any)).thenAnswer((_) async {});
    when(mockTokenStore.clear()).thenAnswer((_) async {});
    when(mockTokenStore.readRefresh()).thenAnswer((_) async => null);

    await AuthManager.init(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      meUseCase: mockMeUseCase,
      updateProfileUseCase: mockUpdateProfileUseCase,
      logoutUseCase: mockLogoutUseCase,
      refreshUseCase: mockRefreshUseCase,
      tokenStore: mockTokenStore,
    );

    authManager = AuthManager.instance;
  });

  group('AuthManager Login Tests', () {
    test('should successfully login and save tokens', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final mockTokens = AuthTokens(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      );
      final mockProfile = Profile(
        id: '123',
        email: email,
        firstName: 'Test',
        lastName: 'User',
      );

      when(mockLoginUseCase(email: email, password: password))
          .thenAnswer((_) async => Ok(mockTokens));
      when(mockMeUseCase()).thenAnswer((_) async => Ok(mockProfile));

      // Act
      final result = await authManager.login(email, password);

      // Assert
      expect(result.isOk, true);
      expect(authManager.isLoggedIn, true);
      expect(authManager.tokens, mockTokens);
      expect(authManager.profile, mockProfile);
      verify(mockTokenStore.write(mockTokens)).called(1);
      verify(mockMeUseCase()).called(1);
    });

    test('should handle login failure', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'wrong_password';
      final error = ApiError(
        message: 'Invalid credentials',
        statusCode: 401,
      );

      when(mockLoginUseCase(email: email, password: password))
          .thenAnswer((_) async => Err(error));

      // Act
      final result = await authManager.login(email, password);

      // Assert
      expect(result.isErr, true);
      expect(authManager.isLoggedIn, false);
      expect(authManager.tokens, null);
      verifyNever(mockTokenStore.write(any));
      verifyNever(mockMeUseCase());
    });

    test('should set busy state during login', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final mockTokens = AuthTokens(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      );
      final mockProfile = Profile(
        id: '123',
        email: email,
        firstName: 'Test',
        lastName: 'User',
      );

      when(mockLoginUseCase(email: email, password: password))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return Ok(mockTokens);
      });
      when(mockMeUseCase()).thenAnswer((_) async => Ok(mockProfile));

      // Act
      final loginFuture = authManager.login(email, password);
      
      // Assert - Should be busy during login
      await Future.delayed(Duration(milliseconds: 50));
      expect(authManager.isBusy, true);
      
      await loginFuture;
      expect(authManager.isBusy, false);
    });
  });

  group('AuthManager Register Tests', () {
    test('should successfully register new user', () async {
      // Arrange
      const email = 'newuser@example.com';
      const password = 'password123';
      const firstName = 'New';
      const lastName = 'User';
      final mockTokens = AuthTokens(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      );
      final mockProfile = Profile(
        id: '123',
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      when(mockRegisterUseCase(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      )).thenAnswer((_) async => Ok(mockTokens));
      when(mockMeUseCase()).thenAnswer((_) async => Ok(mockProfile));

      // Act
      final result = await authManager.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      // Assert
      expect(result.isOk, true);
      expect(authManager.isLoggedIn, true);
      expect(authManager.tokens, mockTokens);
      expect(authManager.profile, mockProfile);
      verify(mockTokenStore.write(mockTokens)).called(1);
    });

    test('should handle registration failure', () async {
      // Arrange
      const email = 'existing@example.com';
      const password = 'password123';
      final error = ApiError(
        message: 'Email already exists',
        statusCode: 409,
      );

      when(mockRegisterUseCase(
        email: email,
        password: password,
        firstName: null,
        lastName: null,
      )).thenAnswer((_) async => Err(error));

      // Act
      final result = await authManager.register(
        email: email,
        password: password,
      );

      // Assert
      expect(result.isErr, true);
      expect(authManager.isLoggedIn, false);
      verifyNever(mockTokenStore.write(any));
    });
  });

  group('AuthManager FetchMe Tests', () {
    test('should successfully fetch user profile', () async {
      // Arrange
      final mockProfile = Profile(
        id: '123',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
      );

      when(mockMeUseCase()).thenAnswer((_) async => Ok(mockProfile));

      // Act
      final result = await authManager.fetchMe();

      // Assert
      expect(result.isOk, true);
      expect(authManager.profile, mockProfile);
      verify(mockMeUseCase()).called(1);
    });

    test('should handle fetchMe failure', () async {
      // Arrange
      final error = ApiError(
        message: 'Unauthorized',
        statusCode: 401,
      );

      when(mockMeUseCase()).thenAnswer((_) async => Err(error));

      // Act
      final result = await authManager.fetchMe();

      // Assert
      expect(result.isErr, true);
      expect(authManager.profile, null);
    });
  });

  group('AuthManager UpdateProfile Tests', () {
    test('should successfully update user profile', () async {
      // Arrange
      final patch = {'firstName': 'Updated'};
      final updatedProfile = Profile(
        id: '123',
        email: 'test@example.com',
        firstName: 'Updated',
        lastName: 'User',
      );

      when(mockUpdateProfileUseCase(patch))
          .thenAnswer((_) async => Ok(updatedProfile));

      // Act
      final result = await authManager.updateProfile(patch);

      // Assert
      expect(result.isOk, true);
      expect(authManager.profile, updatedProfile);
      expect(authManager.profile?.firstName, 'Updated');
      verify(mockUpdateProfileUseCase(patch)).called(1);
    });

    test('should handle updateProfile failure', () async {
      // Arrange
      final patch = {'firstName': 'Invalid'};
      final error = ApiError(
        message: 'Invalid data',
        statusCode: 400,
      );

      when(mockUpdateProfileUseCase(patch))
          .thenAnswer((_) async => Err(error));

      // Act
      final result = await authManager.updateProfile(patch);

      // Assert
      expect(result.isErr, true);
    });
  });

  group('AuthManager SaveTokens Tests', () {
    test('should save tokens successfully', () async {
      // Arrange
      final tokens = AuthTokens(
        accessToken: 'new_access',
        refreshToken: 'new_refresh',
      );

      // Act
      await authManager.saveTokens(tokens);

      // Assert
      expect(authManager.tokens, tokens);
      verify(mockTokenStore.write(tokens)).called(1);
    });

    test('should clear tokens when null is passed', () async {
      // Arrange & Act
      await authManager.saveTokens(null);

      // Assert
      expect(authManager.tokens, null);
      verify(mockTokenStore.clear()).called(1);
    });
  });

  group('AuthManager Logout Tests', () {
    test('should successfully logout and clear tokens', () async {
      // Arrange
      when(mockLogoutUseCase()).thenAnswer((_) async => const Ok(null));

      // Act
      final result = await authManager.logout();

      // Assert
      expect(result.isOk, true);
      expect(authManager.isLoggedIn, false);
      expect(authManager.tokens, null);
      expect(authManager.profile, null);
      verify(mockTokenStore.clear()).called(1);
      verify(mockLogoutUseCase()).called(1);
    });

    test('should clear local data even if logout API fails', () async {
      // Arrange
      when(mockLogoutUseCase()).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => authManager.logout(),
        throwsException,
      );

      // Verify that tokens were cleared despite the exception
      expect(authManager.tokens, null);
      expect(authManager.profile, null);
      verify(mockTokenStore.clear()).called(1);
    });
  });

  group('AuthManager RefreshIfNeeded Tests', () {
    test('should refresh tokens when refresh token exists', () async {
      // Arrange
      const refreshToken = 'old_refresh_token';
      final newTokens = AuthTokens(
        accessToken: 'new_access',
        refreshToken: 'new_refresh',
      );

      when(mockTokenStore.readRefresh())
          .thenAnswer((_) async => refreshToken);
      when(mockRefreshUseCase(refreshToken))
          .thenAnswer((_) async => Ok(newTokens));

      // Act
      final result = await authManager.refreshIfNeeded();

      // Assert
      expect(result, newTokens);
      expect(authManager.tokens, newTokens);
      verify(mockTokenStore.write(newTokens)).called(1);
    });

    test('should return current tokens if no refresh token', () async {
      // Arrange
      when(mockTokenStore.readRefresh()).thenAnswer((_) async => null);

      // Act
      final result = await authManager.refreshIfNeeded();

      // Assert
      expect(result, authManager.tokens);
      verifyNever(mockRefreshUseCase(any));
    });

    test('should return current tokens if refresh fails', () async {
      // Arrange
      const refreshToken = 'invalid_refresh';
      final error = ApiError(
        message: 'Invalid refresh token',
        statusCode: 401,
      );

      when(mockTokenStore.readRefresh())
          .thenAnswer((_) async => refreshToken);
      when(mockRefreshUseCase(refreshToken))
          .thenAnswer((_) async => Err(error));

      // Act
      final result = await authManager.refreshIfNeeded();

      // Assert
      expect(result, authManager.tokens);
      verifyNever(mockTokenStore.write(any));
    });

    test('should not refresh if refresh token is empty', () async {
      // Arrange
      when(mockTokenStore.readRefresh()).thenAnswer((_) async => '');

      // Act
      final result = await authManager.refreshIfNeeded();

      // Assert
      expect(result, authManager.tokens);
      verifyNever(mockRefreshUseCase(any));
    });
  });

  group('AuthManager State Tests', () {
    test('should correctly report logged in state', () async {
      // Initially not logged in
      expect(authManager.isLoggedIn, false);

      // After saving tokens
      final tokens = AuthTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
      );
      await authManager.saveTokens(tokens);
      expect(authManager.isLoggedIn, true);

      // After clearing tokens
      await authManager.saveTokens(null);
      expect(authManager.isLoggedIn, false);
    });

    test('should not be logged in with empty access token', () async {
      // Arrange
      final tokens = AuthTokens(
        accessToken: '',
        refreshToken: 'refresh',
      );

      // Act
      await authManager.saveTokens(tokens);

      // Assert
      expect(authManager.isLoggedIn, false);
    });
  });

  group('AuthManager Initialization Tests', () {
    test('should load persisted tokens on initialization', () async {
      // Arrange
      final persistedTokens = AuthTokens(
        accessToken: 'persisted_access',
        refreshToken: 'persisted_refresh',
      );
      final mockProfile = Profile(
        id: '123',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
      );

      when(mockTokenStore.read()).thenAnswer((_) async => persistedTokens);
      when(mockMeUseCase()).thenAnswer((_) async => Ok(mockProfile));

      // Act
      await AuthManager.init(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        meUseCase: mockMeUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshUseCase: mockRefreshUseCase,
        tokenStore: mockTokenStore,
      );

      final manager = AuthManager.instance;

      // Assert
      expect(manager.tokens, persistedTokens);
      verify(mockMeUseCase()).called(1);
    });

    test('should not fetch profile if no persisted tokens', () async {
      // Arrange
      when(mockTokenStore.read()).thenAnswer((_) async => null);

      // Act
      await AuthManager.init(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        meUseCase: mockMeUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        logoutUseCase: mockLogoutUseCase,
        refreshUseCase: mockRefreshUseCase,
        tokenStore: mockTokenStore,
      );

      // Assert
      verifyNever(mockMeUseCase());
    });
  });
}
 */
