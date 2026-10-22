/// Configuración del backend de Pedidos OXXO.
///
/// El servidor vive en el plan gratuito de Render: si nadie lo usó en un
/// rato se "duerme" y la primera petición puede tardar hasta un minuto en
/// responder mientras despierta. Por eso los timeouts son generosos.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://pedidos-oxxo-backend.onrender.com/api/v1';

  static const Duration connectTimeout = Duration(seconds: 65);
  static const Duration receiveTimeout = Duration(seconds: 65);
  static const Duration sendTimeout = Duration(seconds: 65);

  /// Tiempo de espera a partir del cual la UI puede mostrar el mensaje de
  /// "despertando el servidor" mientras sigue esperando la respuesta.
  static const Duration avisoServidorDormido = Duration(seconds: 5);
}
