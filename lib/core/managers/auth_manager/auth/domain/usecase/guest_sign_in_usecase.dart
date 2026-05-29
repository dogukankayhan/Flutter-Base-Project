import 'package:flutter_base_kit/core/networking/core/network/error/api_error.dart';
import 'package:flutter_base_kit/core/networking/core/utils/result.dart';
import '../entity/auth_entity.dart';
import '../repository/auth_repository.dart';

class GuestSignInUseCase {
  final AuthRepository repository;
  const GuestSignInUseCase(this.repository);

  Future<Result<AuthTokens, ApiError>> call() => repository.guestSignIn();
}
