import 'package:flutter_kit_auth/auth/data/dto/auth_dto.dart';
import 'package:flutter_kit_auth/auth/data/remote/auth_remote_datasource.dart';
import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart';
import 'package:flutter_kit_network/core/network/api/api_response.dart';
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/network/error/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_remote_datasource_test.mocks.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _kTokensJson = <String, dynamic>{
  'accessToken': 'access',
  'refreshToken': 'refresh',
};

final _kProfileJson = <String, dynamic>{
  'id': '1',
  'email': 'test@test.com',
  'firstName': 'John',
  'lastName': 'Doe',
};

ApiException _makeException([String msg = 'server error']) =>
    ApiException(ApiError(statusCode: 500, message: msg));

// ─── Mocks ────────────────────────────────────────────────────────────────────

@GenerateMocks([ApiManager])
void main() {
  late MockApiManager mockApi;
  late AuthRemoteDataSourceImpl ds;

  setUp(() {
    mockApi = MockApiManager();
    ds = AuthRemoteDataSourceImpl(mockApi);
  });

  // ─── login ─────────────────────────────────────────────────────────────────

  group('login', () {
    test('returns Ok(TokensDto) on successful POST', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: _kTokensJson));

      final result = await ds.login(
        LoginRequestDto(email: 'a@b.com', password: 'pw'),
      );

      result.when(
        ok: (dto) {
          expect(dto.accessToken, 'access');
          expect(dto.refreshToken, 'refresh');
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('posts to /Account/Login endpoint', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: _kTokensJson));

      await ds.login(LoginRequestDto(email: 'a@b.com', password: 'pw'));

      verify(
        mockApi.post<Map<String, dynamic>>(
          path: '/Account/Login',
          body: anyNamed('body'),
        ),
      ).called(1);
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenThrow(_makeException('invalid credentials'));

      final result = await ds.login(
        LoginRequestDto(email: 'bad@b.com', password: 'wrong'),
      );

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'invalid credentials'),
      );
    });

    test('wraps generic exception as Err(ApiError)', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenThrow(Exception('network timeout'));

      final result = await ds.login(
        LoginRequestDto(email: 'a@b.com', password: 'pw'),
      );

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, contains('network timeout')),
      );
    });
  });

  // ─── register ──────────────────────────────────────────────────────────────

  group('register', () {
    test('returns Ok(TokensDto) on success', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: _kTokensJson));

      final result = await ds.register(
        RegisterRequestDto(email: 'new@test.com', password: 'pw'),
      );

      result.when(
        ok: (dto) => expect(dto.accessToken, 'access'),
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenThrow(_makeException('email taken'));

      final result = await ds.register(
        RegisterRequestDto(email: 'taken@test.com', password: 'pw'),
      );

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'email taken'),
      );
    });
  });

  // ─── refresh ───────────────────────────────────────────────────────────────

  group('refresh', () {
    test('returns Ok(TokensDto) on success', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: _kTokensJson));

      final result = await ds.refresh('old-refresh');

      result.when(
        ok: (dto) => expect(dto.accessToken, 'access'),
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenThrow(_makeException('token expired'));

      final result = await ds.refresh('expired');

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'token expired'),
      );
    });
  });

  // ─── me ────────────────────────────────────────────────────────────────────

  group('me', () {
    test('returns Ok(ProfileDto) on successful GET', () async {
      when(
        mockApi.get<Map<String, dynamic>>(path: anyNamed('path')),
      ).thenAnswer((_) async => ApiResponse(data: _kProfileJson));

      final result = await ds.me();

      result.when(
        ok: (dto) {
          expect(dto.id, '1');
          expect(dto.email, 'test@test.com');
          expect(dto.firstName, 'John');
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.get<Map<String, dynamic>>(path: anyNamed('path')),
      ).thenThrow(_makeException('unauthorized'));

      final result = await ds.me();

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'unauthorized'),
      );
    });
  });

  // ─── updateProfile ─────────────────────────────────────────────────────────

  group('updateProfile', () {
    test('returns Ok(ProfileDto) on successful PATCH', () async {
      when(
        mockApi.patch<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: _kProfileJson));

      final result = await ds.updateProfile({'firstName': 'Jane'});

      result.when(
        ok: (dto) => expect(dto.firstName, 'John'),
        err: (_) => fail('expected ok'),
      );
      verify(
        mockApi.patch<Map<String, dynamic>>(
          path: '/auth/me',
          body: anyNamed('body'),
        ),
      ).called(1);
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.patch<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenThrow(_makeException('validation error'));

      final result = await ds.updateProfile({'firstName': 'B@d'});

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'validation error'),
      );
    });
  });

  // ─── logout ────────────────────────────────────────────────────────────────

  group('logout', () {
    test('returns Ok(null) on success', () async {
      when(
        mockApi.post(path: anyNamed('path'), body: anyNamed('body')),
      ).thenAnswer((_) async => ApiResponse(data: null));

      final result = await ds.logout();

      expect(result.isOk, true);
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.post(path: anyNamed('path'), body: anyNamed('body')),
      ).thenThrow(_makeException('session not found'));

      final result = await ds.logout();

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'session not found'),
      );
    });
  });

  // ─── appleSignIn ───────────────────────────────────────────────────────────

  group('appleSignIn', () {
    test('returns Ok(TokensDto) on success', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: _kTokensJson));

      final result = await ds.appleSignIn(
        SocialAuthRequestDto(provider: 'apple', idToken: 'apple-jwt'),
      );

      result.when(
        ok: (dto) => expect(dto.accessToken, 'access'),
        err: (_) => fail('expected ok'),
      );
      verify(
        mockApi.post<Map<String, dynamic>>(
          path: '/auth/apple',
          body: anyNamed('body'),
        ),
      ).called(1);
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenThrow(_makeException('invalid token'));

      final result = await ds.appleSignIn(
        SocialAuthRequestDto(provider: 'apple', idToken: 'bad'),
      );

      expect(result.isErr, true);
    });
  });

  // ─── googleSignIn ──────────────────────────────────────────────────────────

  group('googleSignIn', () {
    test('returns Ok(TokensDto) on success', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: _kTokensJson));

      final result = await ds.googleSignIn(
        SocialAuthRequestDto(provider: 'google', idToken: 'google-jwt'),
      );

      result.when(
        ok: (dto) => expect(dto.accessToken, 'access'),
        err: (_) => fail('expected ok'),
      );
      verify(
        mockApi.post<Map<String, dynamic>>(
          path: '/auth/google',
          body: anyNamed('body'),
        ),
      ).called(1);
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenThrow(_makeException('invalid token'));

      final result = await ds.googleSignIn(
        SocialAuthRequestDto(provider: 'google', idToken: 'bad'),
      );

      expect(result.isErr, true);
    });
  });

  // ─── guestSignIn ───────────────────────────────────────────────────────────

  group('guestSignIn', () {
    test('returns Ok(TokensDto) on success', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: _kTokensJson));

      final result = await ds.guestSignIn();

      result.when(
        ok: (dto) => expect(dto.accessToken, 'access'),
        err: (_) => fail('expected ok'),
      );
      verify(
        mockApi.post<Map<String, dynamic>>(
          path: '/auth/guest',
          body: anyNamed('body'),
        ),
      ).called(1);
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
        ),
      ).thenThrow(_makeException('guest disabled'));

      final result = await ds.guestSignIn();

      expect(result.isErr, true);
    });
  });
}
