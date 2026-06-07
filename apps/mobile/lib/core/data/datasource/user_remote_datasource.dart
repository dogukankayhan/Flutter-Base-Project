import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart';
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
import '../../domain/entity/user_profile.dart';
import '../dto/user_dto.dart';

abstract interface class UserRemoteDataSource {
  Future<Result<UserProfile, ApiError>> getProfile();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  const UserRemoteDataSourceImpl(this._api);

  final ApiManager _api;

  @override
  Future<Result<UserProfile, ApiError>> getProfile() async {
    try {
      final response = await _api.get<Map<String, dynamic>>(path: '/user/me');
      return Ok(UserDto.fromJson(response.data).toDomain());
    } on ApiError catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }
}
