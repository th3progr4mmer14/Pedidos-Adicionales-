import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// Punto único de acceso HTTP al backend de Pedidos OXXO.
///
/// Agrega el `Authorization: Bearer <token>` a cada petición (si hay sesión)
/// y traduce cualquier error de Dio a un [ApiException] concreto para que
/// las pantallas no tengan que lidiar con códigos HTTP ni con DioException.
class ApiClient {
  ApiClient._() : dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          sendTimeout: ApiConfig.sendTimeout,
        )) {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final token = await TokenStorage.instance.leerToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }));
  }

  static final ApiClient instance = ApiClient._();

  final Dio dio;

  /// Se invoca cuando el backend responde 401 (token ausente, inválido o
  /// expirado) para que la app pueda limpiar la sesión y volver al login
  /// sin que cada pantalla tenga que manejarlo por separado.
  void Function()? onSesionExpirada;

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _ejecutar(() => dio.get(path, queryParameters: queryParameters));
  }

  Future<Response<dynamic>> post(String path, {Object? data}) {
    return _ejecutar(() => dio.post(path, data: data));
  }

  Future<Response<dynamic>> delete(String path) {
    return _ejecutar(() => dio.delete(path));
  }

  Future<Response<dynamic>> _ejecutar(Future<Response<dynamic>> Function() peticion) async {
    try {
      return await peticion();
    } on DioException catch (e) {
      throw _traducir(e);
    }
  }

  ApiException _traducir(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServidorDormidoException();
      case DioExceptionType.connectionError:
        return const ErrorConexionException();
      default:
        break;
    }

    final response = e.response;
    if (response == null) {
      return const ErrorConexionException();
    }

    final mensaje = _mensajeDe(response);

    switch (response.statusCode) {
      case 400:
        return ValidacionException(mensaje ?? 'Error de validación', _detallesDe(response));
      case 401:
        onSesionExpirada?.call();
        return SesionInvalidaException(mensaje ?? 'Credenciales inválidas o sesión expirada');
      case 403:
        return SinPermisoException(mensaje ?? 'No tienes permiso para esta operación');
      case 423:
        return CuentaBloqueadaException(mensaje ?? 'Tu cuenta está bloqueada temporalmente');
      case 428:
        return CuentaPendienteActivacionException(mensaje ?? 'Debes activar tu cuenta');
      case 429:
        return LimiteIntentosException(mensaje ?? 'Demasiados intentos, espera un momento');
      default:
        return ErrorServidorException(mensaje ?? 'Ocurrió un error en el servidor');
    }
  }

  String? _mensajeDe(Response response) {
    final data = response.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }

  List<String> _detallesDe(Response response) {
    final data = response.data;
    if (data is Map && data['detalles'] is List) {
      return (data['detalles'] as List).whereType<String>().toList();
    }
    return const [];
  }
}
