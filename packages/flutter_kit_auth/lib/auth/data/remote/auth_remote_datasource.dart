import 'package:dio/dio.dart';
import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart';
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/network/error/api_exception.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
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
  Future<Result<TokensDto, ApiError>> guestSignIn({CancelToken? cancelToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiManager api;
  AuthRemoteDataSourceImpl(this.api);

  @override
  Future<Result<TokensDto, ApiError>> login(
    LoginRequestDto dto, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await api.post<Map<String, dynamic>>(
        path: "/Account/Login",
        body: dto.toJson(),
        cancelToken: cancelToken,
      );
      return Ok(TokensDto.fromJson(response.data));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<TokensDto, ApiError>> register(
    RegisterRequestDto dto, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await api.post<Map<String, dynamic>>(
        path: "/auth/register",
        body: dto.toJson(),
        cancelToken: cancelToken,
      );
      return Ok(TokensDto.fromJson(response.data));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<TokensDto, ApiError>> refresh(
    String refreshToken, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await api.post<Map<String, dynamic>>(
        path: "/auth/refresh",
        body: {"refreshToken": refreshToken},
        cancelToken: cancelToken,
      );
      return Ok(TokensDto.fromJson(response.data));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<ProfileDto, ApiError>> me({CancelToken? cancelToken}) async {
    try {
      final response = await api.get<Map<String, dynamic>>(
        path: "/auth/me",
        cancelToken: cancelToken,
      );
      return Ok(ProfileDto.fromJson(response.data));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<ProfileDto, ApiError>> updateProfile(
    Map<String, dynamic> patch, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await api.patch<Map<String, dynamic>>(
        path: "/auth/me",
        body: patch,
        cancelToken: cancelToken,
      );
      return Ok(ProfileDto.fromJson(response.data));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<void, ApiError>> logout({CancelToken? cancelToken}) async {
    try {
      await api.post(path: "/auth/logout", body: {}, cancelToken: cancelToken);
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<TokensDto, ApiError>> appleSignIn(
    SocialAuthRequestDto dto, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await api.post<Map<String, dynamic>>(
        path: "/auth/apple",
        body: dto.toJson(),
        cancelToken: cancelToken,
      );
      return Ok(TokensDto.fromJson(response.data));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<TokensDto, ApiError>> googleSignIn(
    SocialAuthRequestDto dto, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await api.post<Map<String, dynamic>>(
        path: "/auth/google",
        body: dto.toJson(),
        cancelToken: cancelToken,
      );
      return Ok(TokensDto.fromJson(response.data));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<TokensDto, ApiError>> guestSignIn({
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await api.post<Map<String, dynamic>>(
        path: "/auth/guest",
        body: {},
        cancelToken: cancelToken,
      );
      return Ok(TokensDto.fromJson(response.data));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }
}
