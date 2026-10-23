import 'perfil.dart';

/// Datos del colaborador que se muestran en Ajustes / Mis datos.
///
/// Es una vista de presentación de [Perfil] (el modelo real que viene del
/// backend): [UserProfile.fromPerfil] hace la traducción. No se construye
/// a mano en ningún otro lado de la app.
class UserProfile {
  const UserProfile({
    required this.employeeNumber,
    required this.fullName,
    required this.role,
    required this.plaza,
    required this.store,
    this.email,
    this.activatedAt,
    this.policiesAcceptedVersion,
    this.policiesAcceptedAt,
  });

  final String employeeNumber;
  final String fullName;

  /// colaborador | asesor | admin
  final String role;
  final String plaza;
  final String store;
  final String? email;
  final DateTime? activatedAt;

  /// Versión de las políticas que aceptó (ej. "1.0") y cuándo.
  final String? policiesAcceptedVersion;
  final DateTime? policiesAcceptedAt;

  String get roleLabel => switch (role) {
        'colaborador' => 'Colaborador',
        'asesor' => 'Asesor de tienda',
        'admin' => 'Administrador',
        _ => role,
      };

  /// Traduce el [Perfil] autenticado (el modelo real de la app) a lo que
  /// necesita la pantalla de Ajustes. La plaza/tienda que se muestran son
  /// las de la primera tienda asignada (o la lista completa si el usuario
  /// tiene varias, como un asesor); un admin sin tiendas asignadas ve "—".
  factory UserProfile.fromPerfil(Perfil perfil) {
    final tiendas = perfil.tiendas;
    final plaza = tiendas.isEmpty
        ? '—'
        : tiendas.map((t) => t.plaza ?? '').where((p) => p.isNotEmpty).toSet().join(', ');
    final store = tiendas.isEmpty ? '—' : tiendas.map((t) => t.nombre).join(', ');

    return UserProfile(
      employeeNumber: perfil.numeroEmpleado,
      fullName: perfil.nombre,
      role: switch (perfil.rol) {
        Rol.colaborador => 'colaborador',
        Rol.asesorTienda => 'asesor',
        Rol.admin => 'admin',
      },
      plaza: plaza.isEmpty ? '—' : plaza,
      store: store,
      policiesAcceptedVersion: perfil.politicasVersion,
      policiesAcceptedAt: perfil.politicasAceptadasEn,
    );
  }
}
