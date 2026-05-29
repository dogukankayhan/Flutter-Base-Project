import 'package:flutter_base_kit/core/domain/base_use_case.dart';
import 'package:flutter_base_kit/core/networking/core/network/error/api_error.dart';
import 'package:flutter_base_kit/core/networking/core/utils/result.dart';

import '../repository/auth_repository.dart';

class LogoutUseCase extends BaseUseCase<void> {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);
  @override
  Future<Result<void, ApiError>> call() => repository.logout();
}
