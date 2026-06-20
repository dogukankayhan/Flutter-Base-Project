import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';

import '../repository/auth_repository.dart';
import '../entity/auth_entity.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);
  Future<Result<AuthTokens, ApiError>> call({
    required String email,
    required String password,
  }) => repository.login(email: email, password: password);
}
