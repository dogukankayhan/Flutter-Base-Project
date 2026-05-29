import 'package:dio/dio.dart';
import 'package:flutter_base_kit/core/networking/core/extensions/api_response_when.dart';
import 'package:flutter_base_kit/core/networking/core/network/api/api_manager_interface.dart';
import 'package:flutter_base_kit/core/networking/core/network/error/api_error.dart';
import 'package:flutter_base_kit/core/networking/core/utils/result.dart';
import '../dto/auth_dto.dart';

abstract class AuthRemoteDataSource {
  Future<Result<TokensDto, ApiError>> login(
    LoginRequestDto dto, {
    CancelToken? cancelToken,
  });
  Future<Result<TokensDto, ApiError>> register(
    RegisterRequestDto dto, {
    CancelToken? cancelToken,
  });
  Future<Result<TokensDto, ApiError>> refresh(
    String refreshToken, {
    CancelToken? cancelToken,
  });
  Future<Result<ProfileDto, ApiError>> me({CancelToken? cancelToken});
  Future<Result<ProfileDto, ApiError>> updateProfile(
    Map<String, dynamic> patch, {
    CancelToken? cancelToken,
  });
  Future<Result<void, ApiError>> logout({CancelToken? cancelToken});

  // Social Auth
  Future<Result<TokensDto, ApiError>> appleSignIn(
    SocialAuthRequestDto dto, {
    CancelToken? cancelToken,
  });
  Future<Result<TokensDto, ApiError>> googleSignIn(
    SocialAuthRequestDto dto, {
    CancelToken? cancelToken,
  });
  Future<Result<TokensDto, ApiError>> guestSignIn({
    CancelToken? cancelToken,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiManager api;
  AuthRemoteDataSourceImpl(this.api);

  @override
  Future<Result<TokensDto, ApiError>> login(
    LoginRequestDto dto, {
    CancelToken? cancelToken,
  }) async {
    final response = await api.post<Map<String, dynamic>>(
      path: "/auth/login",
      body: dto.toJson(),
      cancelToken: cancelToken,
    );
    return response.when(
      ok: (json) => Ok(TokensDto.fromJson(json)),
      err: (error) => Err(error),
    );
  }

  @override
  Future<Result<TokensDto, ApiError>> register(
    RegisterRequestDto dto, {
    CancelToken? cancelToken,
  }) async {
    final response = await api.post<Map<String, dynamic>>(
      path: "/auth/register",
      body: dto.toJson(),
      cancelToken: cancelToken,
    );
    return response.when(
      ok: (json) => Ok(TokensDto.fromJson(json)),
      err: Err.new,
    );
  }

  @override
  Future<Result<TokensDto, ApiError>> refresh(
    String refreshToken, {
    CancelToken? cancelToken,
  }) async {
    final response = await api.post<Map<String, dynamic>>(
      path: "/auth/refresh",
      body: {"refreshToken": refreshToken},
      cancelToken: cancelToken,
    );
    return response.when(
      ok: (json) => Ok(TokensDto.fromJson(json)),
      err: Err.new,
    );
  }

  @override
  Future<Result<ProfileDto, ApiError>> me({CancelToken? cancelToken}) async {
    final response = await api.get<Map<String, dynamic>>(
      path: "/auth/me",
      cancelToken: cancelToken,
    );
    return response.when(
      ok: (json) => Ok(ProfileDto.fromJson(json)),
      err: Err.new,
    );
  }

  @override
  Future<Result<ProfileDto, ApiError>> updateProfile(
    Map<String, dynamic> patch, {
    CancelToken? cancelToken,
  }) async {
    final response = await api.patch<Map<String, dynamic>>(
      path: "/auth/me",
      body: patch,
      cancelToken: cancelToken,
    );
    return response.when(
      ok: (json) => Ok(ProfileDto.fromJson(json)),
      err: Err.new,
    );
  }

  @override
  Future<Result<void, ApiError>> logout({CancelToken? cancelToken}) async {
    final response = await api.post(
      path: "/auth/logout",
      body: {},
      cancelToken: cancelToken,
    );
    return response.when(ok: (_) => const Ok(null), err: Err.new);
  }

  @override
  Future<Result<TokensDto, ApiError>> appleSignIn(
    SocialAuthRequestDto dto, {
    CancelToken? cancelToken,
  }) async {
    final response = await api.post<Map<String, dynamic>>(
      path: "/auth/apple",
      body: dto.toJson(),
      cancelToken: cancelToken,
    );
    return response.when(ok: (json) => Ok(TokensDto.fromJson(json)), err: Err.new);
  }

  @override
  Future<Result<TokensDto, ApiError>> googleSignIn(
    SocialAuthRequestDto dto, {
    CancelToken? cancelToken,
  }) async {
    final response = await api.post<Map<String, dynamic>>(
      path: "/auth/google",
      body: dto.toJson(),
      cancelToken: cancelToken,
    );
    return response.when(ok: (json) => Ok(TokensDto.fromJson(json)), err: Err.new);
  }

  @override
  Future<Result<TokensDto, ApiError>> guestSignIn({
    CancelToken? cancelToken,
  }) async {
    final response = await api.post<Map<String, dynamic>>(
      path: "/auth/guest",
      body: {},
      cancelToken: cancelToken,
    );
    return response.when(ok: (json) => Ok(TokensDto.fromJson(json)), err: Err.new);
  }
}
