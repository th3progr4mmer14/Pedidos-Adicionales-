import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el access token en almacenamiento seguro del sistema (Keystore en
/// Android, Keychain en iOS). Nunca en SharedPreferences ni en memoria plana.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _tokenKey = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> guardarToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> leerToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<void> borrarToken() {
    return _storage.delete(key: _tokenKey);
  }
}
