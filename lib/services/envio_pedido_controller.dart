import '../models/producto_pedido.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'compartir_pedido_service.dart';
import 'excel_export_service.dart';
import 'pedido_service.dart';

enum EnvioPedidoResultado {
  /// El pedido se guardó (o ya estaba guardado) y el Excel se compartió.
  guardadoYCompartido,

  /// El pedido se guardó y, como compartir no está soportado aquí, el
  /// Excel se guardó en la carpeta de Descargas.
  guardadoYArchivado,

  /// El pedido se guardó pero el usuario canceló el cuadro de compartir.
  guardadoSinCompartir,

  /// El pedido se guardó pero no se pudo generar o compartir el Excel.
  guardadoSinExportar,

  /// No se pudo guardar el pedido en el backend: no quedó nada guardado.
  errorGuardando,
}

class EnvioPedidoOutcome {
  final EnvioPedidoResultado resultado;
  final String? mensaje;
  final String? rutaArchivo;

  const EnvioPedidoOutcome(this.resultado, {this.mensaje, this.rutaArchivo});
}

typedef ExportarExcelFn = Future<String> Function({
  required String plaza,
  required String tienda,
  required String cr,
  required List<ProductoPedido> productos,
});

typedef CompartirOGuardarFn = Future<CompartirResultado> Function(
  String rutaArchivo, {
  required String storeName,
  required int totalArticulos,
});

/// Orquesta el envío de un pedido: primero lo guarda en el backend (si no
/// se había guardado ya) y solo después genera el Excel y lo comparte o lo
/// archiva. Si el guardado falla, nunca llega a tocar el Excel; si el
/// Excel/compartir falla, no vuelve a crear el pedido.
class EnvioPedidoController {
  EnvioPedidoController({
    PedidoService? pedidoService,
    ExportarExcelFn? exportarExcel,
    CompartirOGuardarFn? compartirOGuardar,
  })  : pedidoService = pedidoService ?? PedidoService(ApiClient.instance),
        exportarExcel = exportarExcel ?? ExcelExportService.exportarPedido,
        compartirOGuardar = compartirOGuardar ?? compartirOGuardarArchivo;

  final PedidoService pedidoService;
  final ExportarExcelFn exportarExcel;
  final CompartirOGuardarFn compartirOGuardar;

  Future<EnvioPedidoOutcome> enviar({
    required bool yaGuardado,
    required String? tiendaId,
    required List<ProductoPedido> productos,
    required String storeName,
    required String plaza,
    required String cr,
    required int totalArticulos,
  }) async {
    if (!yaGuardado) {
      try {
        await pedidoService.crear(tiendaId: tiendaId, productos: productos);
      } on ApiException catch (e) {
        return EnvioPedidoOutcome(EnvioPedidoResultado.errorGuardando, mensaje: e.mensaje);
      } catch (_) {
        return const EnvioPedidoOutcome(
          EnvioPedidoResultado.errorGuardando,
          mensaje: 'No se pudo guardar el pedido. Revisa tu conexión e intenta de nuevo.',
        );
      }
    }

    String ruta;
    try {
      ruta = await exportarExcel(plaza: plaza, tienda: storeName, cr: cr, productos: productos);
    } catch (_) {
      return const EnvioPedidoOutcome(
        EnvioPedidoResultado.guardadoSinExportar,
        mensaje: 'El pedido ya se guardó, pero no se pudo generar el Excel. Intenta de nuevo.',
      );
    }

    CompartirResultado resultado;
    try {
      resultado = await compartirOGuardar(ruta, storeName: storeName, totalArticulos: totalArticulos);
    } catch (_) {
      return const EnvioPedidoOutcome(
        EnvioPedidoResultado.guardadoSinExportar,
        mensaje: 'El pedido ya se guardó, pero no se pudo compartir el Excel. Intenta de nuevo.',
      );
    }

    switch (resultado.tipo) {
      case ResultadoCompartir.compartido:
        return const EnvioPedidoOutcome(EnvioPedidoResultado.guardadoYCompartido);
      case ResultadoCompartir.guardadoEnDescargas:
        return EnvioPedidoOutcome(
          EnvioPedidoResultado.guardadoYArchivado,
          rutaArchivo: resultado.rutaDestino,
        );
      case ResultadoCompartir.cancelado:
        return const EnvioPedidoOutcome(
          EnvioPedidoResultado.guardadoSinCompartir,
          mensaje: 'El pedido ya quedó guardado. Puedes compartir el Excel cuando quieras.',
        );
      case ResultadoCompartir.noDisponible:
        return const EnvioPedidoOutcome(
          EnvioPedidoResultado.guardadoSinExportar,
          mensaje: 'El pedido ya se guardó, pero no se pudo generar ni guardar el Excel. Intenta de nuevo.',
        );
    }
  }
}
