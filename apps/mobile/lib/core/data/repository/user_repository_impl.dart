import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
import '../../domain/entity/user_profile.dart';
import '../../domain/repository/user_repository.dart';
import '../datasource/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._remote);

  final UserRemoteDataSource _remote;

  @override
  Future<Result<UserProfile, ApiError>> getProfile() => _remote.getProfile();
}
