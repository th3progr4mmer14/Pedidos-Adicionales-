/// Replica en el cliente la regla de contraseñas del backend
/// (PoliticaPassword.java): mínimo 10 caracteres, mayúscula, minúscula,
/// número, sin el número de empleado y máximo 72. Es solo para dar
/// feedback inmediato; el backend vuelve a validar igual.
class PoliticaPassword {
  PoliticaPassword._();

  static const int min = 10;
  static const int max = 72;

  /// Devuelve el mensaje de error, o null si la contraseña cumple la política.
  static String? validar(String password, String numeroEmpleado) {
    if (password.length < min) {
      return 'La contraseña debe tener al menos $min caracteres';
    }
    if (password.length > max) {
      return 'La contraseña no puede exceder $max caracteres';
    }
    final tieneMayus = password.contains(RegExp(r'[A-Z]'));
    final tieneMinus = password.contains(RegExp(r'[a-z]'));
    final tieneDigito = password.contains(RegExp(r'[0-9]'));
    if (!(tieneMayus && tieneMinus && tieneDigito)) {
      return 'La contraseña debe incluir mayúscula, minúscula y número';
    }
    if (numeroEmpleado.trim().isNotEmpty &&
        password.toLowerCase().contains(numeroEmpleado.trim().toLowerCase())) {
      return 'La contraseña no puede contener tu número de empleado';
    }
    return null;
  }
}
