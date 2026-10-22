import '../models/perfil.dart';
import '../models/sesion.dart';
import 'api_client.dart';

/// Llamadas al controlador de autenticación del backend
/// (/api/v1/auth: login, activar, cambiar-password, me).
class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  Future<Sesion> login(String numeroEmpleado, String password) async {
    final response = await _api.post('/auth/login', data: {
      'numeroEmpleado': numeroEmpleado,
      'password': password,
    });
    return Sesion.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Sesion> activar({
    required String numeroEmpleado,
    required String passwordTemporal,
    required String passwordNueva,
    String? politicasVersion,
  }) async {
    final response = await _api.post('/auth/activar', data: {
      'numeroEmpleado': numeroEmpleado,
      'passwordTemporal': passwordTemporal,
      'passwordNueva': passwordNueva,
      'politicasVersion': politicasVersion,
    });
    return Sesion.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cambiarPassword({
    required String passwordActual,
    required String passwordNueva,
  }) async {
    await _api.post('/auth/cambiar-password', data: {
      'passwordActual': passwordActual,
      'passwordNueva': passwordNueva,
    });
  }

  Future<Perfil> me() async {
    final response = await _api.get('/auth/me');
    return Perfil.fromJson(response.data as Map<String, dynamic>);
  }
}
