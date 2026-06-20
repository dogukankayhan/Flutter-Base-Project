import '../domain/entity/auth_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStore {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
  Future<String?> readAccess();
  Future<String?> readRefresh();
}

class SecureTokenStore implements TokenStore {
  static const _kA = 'access_token';
  static const _kR = 'refresh_token';
  final FlutterSecureStorage _s;

  SecureTokenStore({FlutterSecureStorage? storage})
    : _s = storage ?? const FlutterSecureStorage();

  @override
  Future<void> clear() async {
    await _s.delete(key: _kA);
    await _s.delete(key: _kR);
  }

  @override
  Future<AuthTokens?> read() async {
    final a = await _s.read(key: _kA);
    final r = await _s.read(key: _kR);
    if (a == null || a.isEmpty) return null;
    return AuthTokens(accessToken: a, refreshToken: r);
  }

  @override
  Future<String?> readAccess() => _s.read(key: _kA);

  @override
  Future<String?> readRefresh() => _s.read(key: _kR);

  @override
  Future<void> write(AuthTokens tokens) async {
    await _s.write(key: _kA, value: tokens.accessToken);
    if (tokens.refreshToken != null) {
      await _s.write(key: _kR, value: tokens.refreshToken);
    }
  }
}
