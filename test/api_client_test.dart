import 'package:ccv_app/config/api_config.dart';
import 'package:ccv_app/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Cada interceptor se inserta antes del que lee el token (agregado en el
  // constructor) para no depender de flutter_secure_storage en estas
  // pruebas: solo nos interesa qué timeouts le llegan a Dio.
  test('post con timeout manda ese sendTimeout/receiveTimeout solo para esa peticion', () async {
    final client = ApiClient.instance;
    RequestOptions? capturado;
    final interceptor = InterceptorsWrapper(onRequest: (options, handler) {
      capturado = options;
      handler.reject(DioException(requestOptions: options, type: DioExceptionType.cancel));
    });
    client.dio.interceptors.insert(0, interceptor);
    addTearDown(() => client.dio.interceptors.remove(interceptor));

    try {
      await client.post('/ruta-de-prueba', data: const {}, timeout: const Duration(seconds: 180));
    } catch (_) {
      // Se espera que falle: el interceptor cancela la peticion a propósito.
    }

    expect(capturado, isNotNull);
    expect(capturado!.sendTimeout, const Duration(seconds: 180));
    expect(capturado!.receiveTimeout, const Duration(seconds: 180));
  });

  test('post sin timeout usa los valores globales de ApiConfig', () async {
    final client = ApiClient.instance;
    RequestOptions? capturado;
    final interceptor = InterceptorsWrapper(onRequest: (options, handler) {
      capturado = options;
      handler.reject(DioException(requestOptions: options, type: DioExceptionType.cancel));
    });
    client.dio.interceptors.insert(0, interceptor);
    addTearDown(() => client.dio.interceptors.remove(interceptor));

    try {
      await client.post('/ruta-de-prueba', data: const {});
    } catch (_) {
      // Se espera que falle: el interceptor cancela la peticion a propósito.
    }

    expect(capturado, isNotNull);
    expect(capturado!.sendTimeout, ApiConfig.sendTimeout);
    expect(capturado!.receiveTimeout, ApiConfig.receiveTimeout);
  });
}
