/// Errores de la API, ya traducidos a algo que la UI puede mostrar o usar
/// para decidir a dónde navegar (por ejemplo 428 -> pantalla de activación).
sealed class ApiException implements Exception {
  final String mensaje;
  const ApiException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// 401: credenciales o token inválido/expirado. La app debe volver al login.
class SesionInvalidaException extends ApiException {
  const SesionInvalidaException([super.mensaje = 'Credenciales inválidas o sesión expirada']);
}

/// 423: cuenta bloqueada por intentos fallidos.
class CuentaBloqueadaException extends ApiException {
  const CuentaBloqueadaException([super.mensaje = 'Tu cuenta está bloqueada temporalmente']);
}

/// 428: contraseña temporal pendiente de activación.
class CuentaPendienteActivacionException extends ApiException {
  const CuentaPendienteActivacionException([super.mensaje = 'Debes activar tu cuenta']);
}

/// 403: el usuario no tiene permiso para esa operación.
class SinPermisoException extends ApiException {
  const SinPermisoException([super.mensaje = 'No tienes permiso para esta operación']);
}

/// 429: límite de peticiones excedido.
class LimiteIntentosException extends ApiException {
  const LimiteIntentosException([super.mensaje = 'Demasiados intentos, espera un momento']);
}

/// 400: error de validación o de regla de negocio. [detalles] viene del
/// campo `detalles` de ErrorResponse cuando el backend lo manda.
class ValidacionException extends ApiException {
  final List<String> detalles;
  const ValidacionException(super.mensaje, [this.detalles = const []]);
}

/// Se agotó el tiempo de espera: probablemente el servidor estaba dormido
/// y no llegó a despertar dentro del timeout.
class ServidorDormidoException extends ApiException {
  const ServidorDormidoException([
    super.mensaje = 'El servidor está tardando en responder. Puede estar "dormido"; inténtalo de nuevo en un momento.',
  ]);
}

/// Sin conexión a internet o el host no respondió.
class ErrorConexionException extends ApiException {
  const ErrorConexionException([super.mensaje = 'No hay conexión con el servidor']);
}

/// 500 o cualquier otro error no mapeado explícitamente.
class ErrorServidorException extends ApiException {
  const ErrorServidorException([super.mensaje = 'Ocurrió un error en el servidor']);
}
