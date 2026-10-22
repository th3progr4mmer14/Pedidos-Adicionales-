import 'perfil.dart';

/// Resultado de un login/activación exitosos: el token ya resuelto junto
/// con el perfil que trae el propio backend.
class Sesion {
  final String accessToken;
  final Perfil perfil;

  const Sesion({required this.accessToken, required this.perfil});

  factory Sesion.fromJson(Map<String, dynamic> json) {
    return Sesion(
      accessToken: json['accessToken'] as String,
      perfil: Perfil.fromJson(json['perfil'] as Map<String, dynamic>),
    );
  }
}
