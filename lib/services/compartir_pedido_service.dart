import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Resultado de intentar compartir (o archivar) el Excel de un pedido.
enum ResultadoCompartir {
  /// El usuario completó el share con éxito.
  compartido,

  /// El usuario cerró/canceló el cuadro de compartir sin elegir nada.
  cancelado,

  /// La plataforma no soporta compartir archivos (p. ej. Linux de
  /// escritorio): el Excel se guardó en la carpeta de Descargas.
  guardadoEnDescargas,

  /// No se pudo compartir ni encontrar una carpeta de Descargas donde
  /// guardar el archivo.
  noDisponible,
}

class CompartirResultado {
  final ResultadoCompartir tipo;
  final String? rutaDestino;

  const CompartirResultado(this.tipo, [this.rutaDestino]);
}

typedef CompartirArchivosFn = Future<ShareResult> Function(
  List<XFile> files, {
  String? subject,
  String? text,
});

typedef ObtenerDirectorioFn = Future<Directory?> Function();

/// Comparte el Excel del pedido usando el share nativo de la plataforma.
/// Si compartir no está soportado ahí (lanza una excepción, como pasa hoy
/// con share_plus en Linux de escritorio) cae a guardar el archivo en la
/// carpeta de Descargas en vez de mostrar un error técnico.
Future<CompartirResultado> compartirOGuardarArchivo(
  String rutaArchivo, {
  required String storeName,
  required int totalArticulos,
  CompartirArchivosFn? compartirArchivos,
  ObtenerDirectorioFn? obtenerDirectorioDescargas,
}) async {
  final compartir = compartirArchivos ?? Share.shareXFiles;
  final obtenerDirectorio = obtenerDirectorioDescargas ?? getDownloadsDirectory;

  try {
    final resultado = await compartir(
      [XFile(rutaArchivo)],
      subject: "Pedido - $storeName",
      text: "Pedido de $storeName — $totalArticulos artículos",
    );
    if (resultado.status == ShareResultStatus.success) {
      return const CompartirResultado(ResultadoCompartir.compartido);
    }
    return const CompartirResultado(ResultadoCompartir.cancelado);
  } catch (_) {
    final destino = await _guardarEnDescargas(rutaArchivo, obtenerDirectorio);
    if (destino == null) {
      return const CompartirResultado(ResultadoCompartir.noDisponible);
    }
    return CompartirResultado(ResultadoCompartir.guardadoEnDescargas, destino);
  }
}

Future<String?> _guardarEnDescargas(
  String rutaArchivoTemporal,
  ObtenerDirectorioFn obtenerDirectorio,
) async {
  final descargas = await obtenerDirectorio();
  if (descargas == null) return null;

  final nombreArchivo = rutaArchivoTemporal.split(Platform.pathSeparator).last;
  final destino = File('${descargas.path}${Platform.pathSeparator}$nombreArchivo');
  await File(rutaArchivoTemporal).copy(destino.path);
  return destino.path;
}
