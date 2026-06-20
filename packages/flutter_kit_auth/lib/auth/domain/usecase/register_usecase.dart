import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';

import '../repository/auth_repository.dart';
import '../entity/auth_entity.dart';

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);
  Future<Result<AuthTokens, ApiError>> call({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) => repository.register(
    email: email,
    password: password,
    firstName: firstName,
    lastName: lastName,
  );
}
