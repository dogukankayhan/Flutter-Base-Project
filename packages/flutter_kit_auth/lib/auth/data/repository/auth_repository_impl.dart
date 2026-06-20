import 'package:dio/dio.dart';
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
import '../../domain/entity/auth_entity.dart';
import '../../domain/entity/profile_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/enum/social_auth_provider.dart';
import '../dto/auth_dto.dart';
import '../remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<Result<AuthTokens, ApiError>> login({
    required String email,
    required String password,
    CancelToken? cancelToken,
  }) async {
    final result = await remote.login(
      LoginRequestDto(email: email, password: password),
      cancelToken: cancelToken,
    );
    return result.when(
      ok: (tokensDto) => Ok(tokensDto.toEntity()),
      err: Err.new,
    );
  }

  @override
  Future<Result<AuthTokens, ApiError>> refresh({
    required String refreshToken,
    CancelToken? cancelToken,
  }) async {
    final result = await remote.refresh(refreshToken, cancelToken: cancelToken);
    return result.when(
      ok: (tokensDto) => Ok(tokensDto.toEntity()),
      err: Err.new,
    );
  }

  @override
  Future<Result<AuthTokens, ApiError>> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    CancelToken? cancelToken,
  }) async {
    final result = await remote.register(
      RegisterRequestDto(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      ),
      cancelToken: cancelToken,
    );
    return result.when(
      ok: (tokensDto) => Ok(tokensDto.toEntity()),
      err: Err.new,
    );
  }

  @override
  Future<Result<Profile, ApiError>> me({CancelToken? cancelToken}) async {
    final result = await remote.me(cancelToken: cancelToken);
    return result.when(
      ok: (profileDto) => Ok(profileDto.toEntity()),
      err: Err.new,
    );
  }

  @override
  Future<Result<Profile, ApiError>> updateProfile(
    Map<String, dynamic> patch, {
    CancelToken? cancelToken,
  }) async {
    final result = await remote.updateProfile(patch, cancelToken: cancelToken);
    return result.when(
      ok: (profileDto) => Ok(profileDto.toEntity()),
      err: Err.new,
    );
  }

  @override
  Future<Result<void, ApiError>> logout({CancelToken? cancelToken}) =>
      remote.logout(cancelToken: cancelToken);

  @override
  Future<Result<AuthTokens, ApiError>> appleSignIn({
    required String idToken,
    CancelToken? cancelToken,
  }) async {
    final result = await remote.appleSignIn(
      SocialAuthRequestDto(
        provider: SocialAuthProvider.apple.key,
        idToken: idToken,
      ),
      cancelToken: cancelToken,
    );
    return result.when(ok: (dto) => Ok(dto.toEntity()), err: Err.new);
  }

  @override
  Future<Result<AuthTokens, ApiError>> googleSignIn({
    required String idToken,
    CancelToken? cancelToken,
  }) async {
    final result = await remote.googleSignIn(
      SocialAuthRequestDto(
        provider: SocialAuthProvider.google.key,
        idToken: idToken,
      ),
      cancelToken: cancelToken,
    );
    return result.when(ok: (dto) => Ok(dto.toEntity()), err: Err.new);
  }

  @override
  Future<Result<AuthTokens, ApiError>> guestSignIn({
    CancelToken? cancelToken,
  }) async {
    final result = await remote.guestSignIn(cancelToken: cancelToken);
    return result.when(ok: (dto) => Ok(dto.toEntity()), err: Err.new);
  }
}
