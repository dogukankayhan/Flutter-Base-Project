import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
import '../entity/auth_entity.dart';
import '../repository/auth_repository.dart';

class AppleSignInUseCase {
  final AuthRepository repository;
  const AppleSignInUseCase(this.repository);

  Future<Result<AuthTokens, ApiError>> call({required String idToken}) =>
      repository.appleSignIn(idToken: idToken);
}
