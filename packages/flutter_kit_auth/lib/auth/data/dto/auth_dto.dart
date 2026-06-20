import '../../domain/entity/auth_entity.dart';
import '../../domain/entity/profile_entity.dart';

class LoginRequestDto {
  final String email;
  final String password;
  const LoginRequestDto({required this.email, required this.password});
  Map<String, dynamic> toJson() => {"email": email, "password": password};
}

class RegisterRequestDto {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  const RegisterRequestDto({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });
  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
    if (firstName != null) "firstName": firstName,
    if (lastName != null) "lastName": lastName,
  };
}

class TokensDto {
  final String accessToken;
  final String? refreshToken;
  TokensDto({required this.accessToken, this.refreshToken});
  factory TokensDto.fromJson(Map<String, dynamic> j) => TokensDto(
    accessToken: j['accessToken'] ?? j['access_token'] ?? "",
    refreshToken: j['refreshToken'] ?? j['refresh_token'],
  );
}

class ProfileDto {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final int coinCount;
  final String? about;

  ProfileDto({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.coinCount = 0,
    this.about,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> j) => ProfileDto(
    id: (j['id'] ?? j['_id'] ?? j['userId']).toString(),
    email: j['email']?.toString(),
    firstName: j['firstName']?.toString(),
    lastName: j['lastName']?.toString(),
    avatarUrl: j['avatar']?.toString() ?? j['avatarUrl']?.toString(),
    coinCount: switch (j['coinCount']) {
      final int v => v,
      final String v => int.tryParse(v) ?? 0,
      _ => 0,
    },
    about: j['about']?.toString(),
  );
}

class SocialAuthRequestDto {
  final String provider;
  final String? idToken;
  final String? accessToken;

  const SocialAuthRequestDto({
    required this.provider,
    this.idToken,
    this.accessToken,
  });

  Map<String, dynamic> toJson() => {
    'provider': provider,
    if (idToken != null) 'idToken': idToken,
    if (accessToken != null) 'accessToken': accessToken,
  };
}

// Extensions map DTO -> Entity

extension TokensDtoX on TokensDto {
  AuthTokens toEntity() =>
      AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
}

extension ProfileDtoX on ProfileDto {
  Profile toEntity() => Profile(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    avatarUrl: avatarUrl,
    coinCount: coinCount,
    about: about,
  );
}
