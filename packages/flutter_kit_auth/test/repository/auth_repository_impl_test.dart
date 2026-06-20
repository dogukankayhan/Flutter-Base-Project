import 'package:flutter_kit_auth/auth/data/dto/auth_dto.dart';
import 'package:flutter_kit_auth/auth/data/remote/auth_remote_datasource.dart';
import 'package:flutter_kit_auth/auth/data/repository/auth_repository_impl.dart';
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_impl_test.mocks.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _kTokensDto = TokensDto(accessToken: 'access', refreshToken: 'refresh');
final _kProfileDto = ProfileDto(
  id: '1',
  email: 'test@test.com',
  firstName: 'John',
  lastName: 'Doe',
);
final _kError = ApiError(statusCode: 401, message: 'unauthorized');

// ─── Mocks ────────────────────────────────────────────────────────────────────

@GenerateMocks([AuthRemoteDataSource])
void main() {
  late MockAuthRemoteDataSource mockRemote;
  late AuthRepositoryImpl repo;

  setUp(() {
    provideDummy<Result<TokensDto, ApiError>>(Ok(_kTokensDto));
    provideDummy<Result<ProfileDto, ApiError>>(Ok(_kProfileDto));
    provideDummy<Result<void, ApiError>>(const Ok(null));
    mockRemote = MockAuthRemoteDataSource();
    repo = AuthRepositoryImpl(mockRemote);
  });

  // ─── login ─────────────────────────────────────────────────────────────────

  group('login', () {
    test('returns Ok(AuthTokens) on success', () async {
      when(mockRemote.login(any)).thenAnswer((_) async => Ok(_kTokensDto));

      final result = await repo.login(email: 'test@test.com', password: 'pw');

      result.when(
        ok: (tokens) {
          expect(tokens.accessToken, 'access');
          expect(tokens.refreshToken, 'refresh');
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('forwards correct email and password via LoginRequestDto', () async {
      when(mockRemote.login(any)).thenAnswer((_) async => Ok(_kTokensDto));

      await repo.login(email: 'a@b.com', password: 'secret');

      final dto =
          verify(mockRemote.login(captureAny)).captured.first
              as LoginRequestDto;
      expect(dto.email, 'a@b.com');
      expect(dto.password, 'secret');
    });

    test('returns Err on failure', () async {
      when(mockRemote.login(any)).thenAnswer((_) async => Err(_kError));

      final result = await repo.login(email: 'x@y.com', password: 'pw');

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'unauthorized'),
      );
    });
  });

  // ─── register ──────────────────────────────────────────────────────────────

  group('register', () {
    test('returns Ok(AuthTokens) on success', () async {
      when(mockRemote.register(any)).thenAnswer((_) async => Ok(_kTokensDto));

      final result = await repo.register(
        email: 'new@test.com',
        password: 'pw',
        firstName: 'John',
        lastName: 'Doe',
      );

      result.when(
        ok: (tokens) => expect(tokens.accessToken, 'access'),
        err: (_) => fail('expected ok'),
      );
    });

    test('forwards all fields via RegisterRequestDto', () async {
      when(mockRemote.register(any)).thenAnswer((_) async => Ok(_kTokensDto));

      await repo.register(
        email: 'new@test.com',
        password: 'pw',
        firstName: 'John',
        lastName: 'Doe',
      );

      final dto =
          verify(mockRemote.register(captureAny)).captured.first
              as RegisterRequestDto;
      expect(dto.email, 'new@test.com');
      expect(dto.password, 'pw');
      expect(dto.firstName, 'John');
      expect(dto.lastName, 'Doe');
    });

    test('returns Err on failure', () async {
      when(mockRemote.register(any)).thenAnswer((_) async => Err(_kError));

      final result = await repo.register(email: 'x@y.com', password: 'pw');

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.statusCode, 401),
      );
    });
  });

  // ─── refresh ───────────────────────────────────────────────────────────────

  group('refresh', () {
    test('returns Ok(AuthTokens) on success', () async {
      when(mockRemote.refresh(any)).thenAnswer((_) async => Ok(_kTokensDto));

      final result = await repo.refresh(refreshToken: 'old-refresh');

      result.when(
        ok: (tokens) => expect(tokens.accessToken, 'access'),
        err: (_) => fail('expected ok'),
      );
      verify(mockRemote.refresh('old-refresh')).called(1);
    });

    test('returns Err on failure', () async {
      when(mockRemote.refresh(any)).thenAnswer((_) async => Err(_kError));

      final result = await repo.refresh(refreshToken: 'bad');

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'unauthorized'),
      );
    });
  });

  // ─── me ────────────────────────────────────────────────────────────────────

  group('me', () {
    test('returns Ok(Profile) mapped from ProfileDto', () async {
      when(mockRemote.me()).thenAnswer((_) async => Ok(_kProfileDto));

      final result = await repo.me();

      result.when(
        ok: (profile) {
          expect(profile.id, '1');
          expect(profile.email, 'test@test.com');
          expect(profile.firstName, 'John');
          expect(profile.fullName, 'John Doe');
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on failure', () async {
      when(mockRemote.me()).thenAnswer((_) async => Err(_kError));

      final result = await repo.me();

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'unauthorized'),
      );
    });
  });

  // ─── updateProfile ─────────────────────────────────────────────────────────

  group('updateProfile', () {
    test('returns Ok(Profile) with updated fields', () async {
      final updated = ProfileDto(
        id: '1',
        email: 'test@test.com',
        firstName: 'Jane',
        lastName: 'Doe',
      );
      when(mockRemote.updateProfile(any)).thenAnswer((_) async => Ok(updated));

      final result = await repo.updateProfile({'firstName': 'Jane'});

      result.when(
        ok: (profile) => expect(profile.firstName, 'Jane'),
        err: (_) => fail('expected ok'),
      );
      verify(mockRemote.updateProfile({'firstName': 'Jane'})).called(1);
    });

    test('returns Err on failure', () async {
      when(mockRemote.updateProfile(any)).thenAnswer((_) async => Err(_kError));

      final result = await repo.updateProfile({'firstName': 'Bad'});

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'unauthorized'),
      );
    });
  });

  // ─── logout ────────────────────────────────────────────────────────────────

  group('logout', () {
    test('delegates directly to remote and returns Ok(null)', () async {
      when(mockRemote.logout()).thenAnswer((_) async => const Ok(null));

      final result = await repo.logout();

      expect(result.isOk, true);
      verify(mockRemote.logout()).called(1);
    });

    test('returns Err when remote returns Err', () async {
      when(mockRemote.logout()).thenAnswer((_) async => Err(_kError));

      final result = await repo.logout();

      expect(result.isErr, true);
    });
  });

  // ─── appleSignIn ───────────────────────────────────────────────────────────

  group('appleSignIn', () {
    test('returns Ok(AuthTokens) and sends apple provider', () async {
      when(
        mockRemote.appleSignIn(any),
      ).thenAnswer((_) async => Ok(_kTokensDto));

      final result = await repo.appleSignIn(idToken: 'apple-token');

      result.when(
        ok: (tokens) => expect(tokens.accessToken, 'access'),
        err: (_) => fail('expected ok'),
      );

      final dto =
          verify(mockRemote.appleSignIn(captureAny)).captured.first
              as SocialAuthRequestDto;
      expect(dto.idToken, 'apple-token');
      expect(dto.provider, 'apple');
    });

    test('returns Err on failure', () async {
      when(mockRemote.appleSignIn(any)).thenAnswer((_) async => Err(_kError));

      final result = await repo.appleSignIn(idToken: 'bad');

      expect(result.isErr, true);
    });
  });

  // ─── googleSignIn ──────────────────────────────────────────────────────────

  group('googleSignIn', () {
    test('returns Ok(AuthTokens) and sends google provider', () async {
      when(
        mockRemote.googleSignIn(any),
      ).thenAnswer((_) async => Ok(_kTokensDto));

      final result = await repo.googleSignIn(idToken: 'google-token');

      result.when(
        ok: (tokens) => expect(tokens.accessToken, 'access'),
        err: (_) => fail('expected ok'),
      );

      final dto =
          verify(mockRemote.googleSignIn(captureAny)).captured.first
              as SocialAuthRequestDto;
      expect(dto.idToken, 'google-token');
      expect(dto.provider, 'google');
    });

    test('returns Err on failure', () async {
      when(mockRemote.googleSignIn(any)).thenAnswer((_) async => Err(_kError));

      final result = await repo.googleSignIn(idToken: 'bad');

      expect(result.isErr, true);
    });
  });

  // ─── guestSignIn ───────────────────────────────────────────────────────────

  group('guestSignIn', () {
    test('returns Ok(AuthTokens) on success', () async {
      when(mockRemote.guestSignIn()).thenAnswer((_) async => Ok(_kTokensDto));

      final result = await repo.guestSignIn();

      result.when(
        ok: (tokens) => expect(tokens.accessToken, 'access'),
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on failure', () async {
      when(mockRemote.guestSignIn()).thenAnswer((_) async => Err(_kError));

      final result = await repo.guestSignIn();

      expect(result.isErr, true);
    });
  });
}
