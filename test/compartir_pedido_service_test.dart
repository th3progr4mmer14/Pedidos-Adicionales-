import 'dart:io';

import 'package:ccv_app/services/compartir_pedido_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  late Directory tempDir;
  late String rutaArchivoOrigen;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('compartir_pedido_test_');
    rutaArchivoOrigen = '${tempDir.path}${Platform.pathSeparator}pedido.xlsx';
    await File(rutaArchivoOrigen).writeAsBytes([1, 2, 3, 4]);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('si compartir tiene éxito, devuelve compartido', () async {
    final resultado = await compartirOGuardarArchivo(
      rutaArchivoOrigen,
      storeName: 'OXXO Centro',
      totalArticulos: 3,
      compartirArchivos: (files, {subject, text}) async =>
          const ShareResult('ok', ShareResultStatus.success),
    );

    expect(resultado.tipo, ResultadoCompartir.compartido);
  });

  test('si el usuario cierra el cuadro de compartir, devuelve cancelado', () async {
    final resultado = await compartirOGuardarArchivo(
      rutaArchivoOrigen,
      storeName: 'OXXO Centro',
      totalArticulos: 3,
      compartirArchivos: (files, {subject, text}) async =>
          const ShareResult('dismissed', ShareResultStatus.dismissed),
    );

    expect(resultado.tipo, ResultadoCompartir.cancelado);
  });

  test(
      'si compartir no está implementado en la plataforma (como en Linux de escritorio), '
      'guarda el archivo en la carpeta de Descargas', () async {
    final descargasDir = await Directory.systemTemp.createTemp('descargas_test_');
    addTearDown(() => descargasDir.delete(recursive: true));

    final resultado = await compartirOGuardarArchivo(
      rutaArchivoOrigen,
      storeName: 'OXXO Centro',
      totalArticulos: 3,
      compartirArchivos: (files, {subject, text}) {
        throw UnimplementedError('shareXFiles() has not been implemented on Linux.');
      },
      obtenerDirectorioDescargas: () async => descargasDir,
    );

    expect(resultado.tipo, ResultadoCompartir.guardadoEnDescargas);
    expect(resultado.rutaDestino, isNotNull);
    expect(await File(resultado.rutaDestino!).exists(), isTrue);
    expect(await File(resultado.rutaDestino!).readAsBytes(), [1, 2, 3, 4]);
  });

  test('si no se puede compartir ni encontrar carpeta de Descargas, devuelve noDisponible', () async {
    final resultado = await compartirOGuardarArchivo(
      rutaArchivoOrigen,
      storeName: 'OXXO Centro',
      totalArticulos: 3,
      compartirArchivos: (files, {subject, text}) {
        throw UnimplementedError('no soportado');
      },
      obtenerDirectorioDescargas: () async => null,
    );

    expect(resultado.tipo, ResultadoCompartir.noDisponible);
    expect(resultado.rutaDestino, isNull);
  });
}
