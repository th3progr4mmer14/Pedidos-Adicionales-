import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/perfil.dart';
import '../models/sesion.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

/// Estado de sesión de la app: perfil actual, login/activación/cambio de
/// contraseña y logout. El token vivo se guarda en flutter_secure_storage;
/// este provider solo mantiene en memoria lo necesario para construir la UI.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService(ApiClient.instance) {
    ApiClient.instance.onSesionExpirada = _limpiarSesionLocal;
  }

  final AuthService _authService;

  Perfil? _perfil;
  bool _restaurandoSesion = true;

  Perfil? get perfil => _perfil;
  bool get estaAutenticado => _perfil != null;
  bool get restaurandoSesion => _restaurandoSesion;

  /// Lee la sesión guardada localmente (sin llamar al backend) para que el
  /// arranque de la app no dependa de que el servidor esté despierto.
  Future<void> restaurarSesion() async {
    final token = await TokenStorage.instance.leerToken();
    final perfilJson = await TokenStorage.instance.leerPerfil();
    if (token != null && perfilJson != null) {
      _perfil = Perfil.fromJson(perfilJson);
    }
    _restaurandoSesion = false;
    notifyListeners();

    if (_perfil != null) {
      // Verifica en segundo plano que el token siga vigente sin bloquear el arranque.
      unawaited(_refrescarPerfil());
    }
  }

  Future<void> _refrescarPerfil() async {
    try {
      final perfilFresco = await _authService.me();
      _perfil = perfilFresco;
      notifyListeners();
    } catch (_) {
      // Si el token ya no es válido, onSesionExpirada ya habrá limpiado la sesión.
      // Cualquier otro error (timeout, sin conexión) se ignora: se reintentará
      // en la siguiente acción que el usuario haga contra el backend.
    }
  }

  Future<void> login(String numeroEmpleado, String password) async {
    final sesion = await _authService.login(numeroEmpleado, password);
    await _guardarSesion(sesion);
  }

  Future<void> activar({
    required String numeroEmpleado,
    required String passwordTemporal,
    required String passwordNueva,
  }) async {
    final sesion = await _authService.activar(
      numeroEmpleado: numeroEmpleado,
      passwordTemporal: passwordTemporal,
      passwordNueva: passwordNueva,
    );
    await _guardarSesion(sesion);
  }

  Future<void> cambiarPassword({
    required String passwordActual,
    required String passwordNueva,
  }) {
    return _authService.cambiarPassword(
      passwordActual: passwordActual,
      passwordNueva: passwordNueva,
    );
  }

  Future<void> logout() async {
    await TokenStorage.instance.borrarSesion();
    _perfil = null;
    notifyListeners();
  }

  Future<void> _guardarSesion(Sesion sesion) async {
    await TokenStorage.instance.guardarSesion(
      token: sesion.accessToken,
      perfilJson: sesion.perfil.toJson(),
    );
    _perfil = sesion.perfil;
    notifyListeners();
  }

  void _limpiarSesionLocal() {
    TokenStorage.instance.borrarSesion();
    _perfil = null;
    notifyListeners();
  }
}
