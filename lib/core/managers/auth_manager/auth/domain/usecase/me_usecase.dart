import 'package:flutter_base_kit/core/domain/base_use_case.dart';
import 'package:flutter_base_kit/core/networking/core/network/error/api_error.dart';
import 'package:flutter_base_kit/core/networking/core/utils/result.dart';

import '../repository/auth_repository.dart';
import '../entity/profile_entity.dart';

class MeUseCase extends BaseUseCase<Profile> {
  final AuthRepository repository;
  const MeUseCase(this.repository);
  @override
  Future<Result<Profile, ApiError>> call() => repository.me();
}
