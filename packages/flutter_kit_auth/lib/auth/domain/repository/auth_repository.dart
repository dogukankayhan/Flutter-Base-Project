import 'package:dio/dio.dart';
import 'package:flutter_kit_core/domain/base_repository.dart';
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
import '../../domain/entity/auth_entity.dart';
import '../../domain/entity/profile_entity.dart';

abstract class AuthRepository implements BaseRepository {
  Future<Result<AuthTokens, ApiError>> login({
    required String email,
    required String password,
    CancelToken? cancelToken,
  });
  Future<Result<AuthTokens, ApiError>> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    CancelToken? cancelToken,
  });
  Future<Result<AuthTokens, ApiError>> refresh({
    required String refreshToken,
    CancelToken? cancelToken,
  });
  Future<Result<Profile, ApiError>> me({CancelToken? cancelToken});
  Future<Result<Profile, ApiError>> updateProfile(
    Map<String, dynamic> patch, {
    CancelToken? cancelToken,
  });
  Future<Result<void, ApiError>> logout({CancelToken? cancelToken});

  // Social Auth
  Future<Result<AuthTokens, ApiError>> appleSignIn({
    required String idToken,
    CancelToken? cancelToken,
  });
  Future<Result<AuthTokens, ApiError>> googleSignIn({
    required String idToken,
    CancelToken? cancelToken,
  });
  Future<Result<AuthTokens, ApiError>> guestSignIn({CancelToken? cancelToken});
}
