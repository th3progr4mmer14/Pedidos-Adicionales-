/// Roles del sistema, tal cual los define el backend (com.oxxo.pedidos.domain.model.Rol).
enum Rol {
  colaborador,
  asesorTienda,
  admin;

  static Rol desdeBackend(String valor) {
    switch (valor) {
      case 'COLABORADOR':
        return Rol.colaborador;
      case 'ASESOR_TIENDA':
        return Rol.asesorTienda;
      case 'ADMIN':
        return Rol.admin;
      default:
        throw ArgumentError('Rol desconocido: $valor');
    }
  }

  String aBackend() {
    switch (this) {
      case Rol.colaborador:
        return 'COLABORADOR';
      case Rol.asesorTienda:
        return 'ASESOR_TIENDA';
      case Rol.admin:
        return 'ADMIN';
    }
  }
}

class TiendaResumen {
  final String id;
  final String? codigo;
  final String nombre;
  final String? plaza;

  const TiendaResumen({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.plaza,
  });

  factory TiendaResumen.fromJson(Map<String, dynamic> json) {
    return TiendaResumen(
      id: json['id'] as String,
      codigo: json['codigo'] as String?,
      nombre: json['nombre'] as String,
      plaza: json['plaza'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'codigo': codigo,
        'nombre': nombre,
        'plaza': plaza,
      };
}

class Perfil {
  final String numeroEmpleado;
  final String nombre;
  final Rol rol;
  final List<TiendaResumen> tiendas;

  /// Version del aviso de privacidad/terminos que aceptó (LegalTexts.version)
  /// y cuándo, según el reloj del servidor. Null si todavía no acepta.
  final String? politicasVersion;
  final DateTime? politicasAceptadasEn;

  const Perfil({
    required this.numeroEmpleado,
    required this.nombre,
    required this.rol,
    required this.tiendas,
    this.politicasVersion,
    this.politicasAceptadasEn,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      numeroEmpleado: json['numeroEmpleado'] as String,
      nombre: json['nombre'] as String,
      rol: Rol.desdeBackend(json['rol'] as String),
      tiendas: (json['tiendas'] as List)
          .map((t) => TiendaResumen.fromJson(t as Map<String, dynamic>))
          .toList(),
      politicasVersion: json['politicasVersion'] as String?,
      politicasAceptadasEn: json['politicasAceptadasEn'] == null
          ? null
          : DateTime.parse(json['politicasAceptadasEn'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'numeroEmpleado': numeroEmpleado,
        'nombre': nombre,
        'rol': rol.aBackend(),
        'tiendas': tiendas.map((t) => t.toJson()).toList(),
        'politicasVersion': politicasVersion,
        'politicasAceptadasEn': politicasAceptadasEn?.toIso8601String(),
      };
}
