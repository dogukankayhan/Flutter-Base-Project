import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';

/// Parametresiz use case'ler için base sınıf.
///
/// ```dart
/// class MeUseCase extends BaseUseCase<Profile> {
///   @override
///   Future<Result<Profile, ApiError>> call() => repository.me();
/// }
/// ```
abstract class BaseUseCase<Output> {
  const BaseUseCase();
  Future<Result<Output, ApiError>> call();
}

/// Parametreli use case'ler için base sınıf.
///
/// ```dart
/// class LoginUseCase extends BaseParamsUseCase<LoginParams, AuthTokens> {
///   @override
///   Future<Result<AuthTokens, ApiError>> call(LoginParams params) => ...
/// }
/// ```
abstract class BaseParamsUseCase<Params, Output> {
  const BaseParamsUseCase();
  Future<Result<Output, ApiError>> call(Params params);
}
