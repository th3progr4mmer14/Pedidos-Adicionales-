import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el access token y el último perfil conocido en almacenamiento
/// seguro del sistema (Keystore en Android, Keychain en iOS). Nunca en
/// SharedPreferences ni en memoria plana.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _tokenKey = 'access_token';
  static const _perfilKey = 'perfil_json';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> guardarSesion({required String token, required Map<String, dynamic> perfilJson}) {
    return Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _perfilKey, value: jsonEncode(perfilJson)),
    ]);
  }

  Future<String?> leerToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<Map<String, dynamic>?> leerPerfil() async {
    final raw = await _storage.read(key: _perfilKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Actualiza solo el perfil cacheado (p. ej. tras aceptar políticas),
  /// sin tocar el token.
  Future<void> actualizarPerfil(Map<String, dynamic> perfilJson) {
    return _storage.write(key: _perfilKey, value: jsonEncode(perfilJson));
  }

  Future<void> borrarSesion() {
    return Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _perfilKey),
    ]);
  }
}
