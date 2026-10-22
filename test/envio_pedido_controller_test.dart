import 'package:ccv_app/models/producto_pedido.dart';
import 'package:ccv_app/services/api_client.dart';
import 'package:ccv_app/services/api_exception.dart';
import 'package:ccv_app/services/compartir_pedido_service.dart';
import 'package:ccv_app/services/envio_pedido_controller.dart';
import 'package:ccv_app/services/pedido_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _PedidoServiceFalso extends PedidoService {
  _PedidoServiceFalso({this.error}) : super(ApiClient.instance);

  final Object? error;
  int llamadas = 0;

  @override
  Future<void> crear({
    required String? tiendaId,
    required List<ProductoPedido> productos,
  }) async {
    llamadas++;
    if (error != null) throw error!;
  }
}

List<ProductoPedido> _unProducto() => [
      ProductoPedido(nombre: 'Agua 600ml', sku: 'SKU-1', cantidad: 2, unidad: 'Pieza'),
    ];

void main() {
  group('EnvioPedidoController.enviar', () {
    test('si el guardado en el backend falla, no exporta ni comparte nada', () async {
      final pedidoService = _PedidoServiceFalso(error: const ErrorConexionException());
      var exportarLlamado = false;

      final controller = EnvioPedidoController(
        pedidoService: pedidoService,
        exportarExcel: ({required plaza, required tienda, required cr, required productos}) async {
          exportarLlamado = true;
          return '/tmp/pedido.xlsx';
        },
        compartirOGuardar: (ruta, {required storeName, required totalArticulos}) async {
          return const CompartirResultado(ResultadoCompartir.compartido);
        },
      );

      final outcome = await controller.enviar(
        yaGuardado: false,
        tiendaId: 'tienda-1',
        productos: _unProducto(),
        storeName: 'OXXO Centro',
        plaza: '10VHT Villahermosa',
        cr: 'CR001',
        totalArticulos: 2,
      );

      expect(outcome.resultado, EnvioPedidoResultado.errorGuardando);
      expect(outcome.mensaje, 'No hay conexión con el servidor');
      expect(pedidoService.llamadas, 1);
      expect(exportarLlamado, isFalse);
    });

    test('un error que no es ApiException tambien se reporta sin tronar', () async {
      final pedidoService = _PedidoServiceFalso(error: Exception('boom'));

      final controller = EnvioPedidoController(
        pedidoService: pedidoService,
        exportarExcel: ({required plaza, required tienda, required cr, required productos}) async =>
            '/tmp/pedido.xlsx',
        compartirOGuardar: (ruta, {required storeName, required totalArticulos}) async =>
            const CompartirResultado(ResultadoCompartir.compartido),
      );

      final outcome = await controller.enviar(
        yaGuardado: false,
        tiendaId: 'tienda-1',
        productos: _unProducto(),
        storeName: 'OXXO Centro',
        plaza: '10VHT Villahermosa',
        cr: 'CR001',
        totalArticulos: 2,
      );

      expect(outcome.resultado, EnvioPedidoResultado.errorGuardando);
      expect(outcome.mensaje, isNotNull);
    });

    test('si ya estaba guardado, no vuelve a llamar a crear (evita duplicados)', () async {
      final pedidoService = _PedidoServiceFalso();

      final controller = EnvioPedidoController(
        pedidoService: pedidoService,
        exportarExcel: ({required plaza, required tienda, required cr, required productos}) async =>
            '/tmp/pedido.xlsx',
        compartirOGuardar: (ruta, {required storeName, required totalArticulos}) async =>
            const CompartirResultado(ResultadoCompartir.compartido),
      );

      final outcome = await controller.enviar(
        yaGuardado: true,
        tiendaId: 'tienda-1',
        productos: _unProducto(),
        storeName: 'OXXO Centro',
        plaza: '10VHT Villahermosa',
        cr: 'CR001',
        totalArticulos: 2,
      );

      expect(outcome.resultado, EnvioPedidoResultado.guardadoYCompartido);
      expect(pedidoService.llamadas, 0);
    });

    test(
        'flujo completo: falla exportar la primera vez, el reintento con yaGuardado=true '
        'no repite el guardado del pedido', () async {
      final pedidoService = _PedidoServiceFalso();
      var intentoExportar = 0;

      Future<String> exportarExcel({
        required String plaza,
        required String tienda,
        required String cr,
        required List<ProductoPedido> productos,
      }) async {
        intentoExportar++;
        if (intentoExportar == 1) {
          throw Exception('no se pudo generar el excel');
        }
        return '/tmp/pedido.xlsx';
      }

      final controller = EnvioPedidoController(
        pedidoService: pedidoService,
        exportarExcel: exportarExcel,
        compartirOGuardar: (ruta, {required storeName, required totalArticulos}) async =>
            const CompartirResultado(ResultadoCompartir.compartido),
      );

      final primerIntento = await controller.enviar(
        yaGuardado: false,
        tiendaId: 'tienda-1',
        productos: _unProducto(),
        storeName: 'OXXO Centro',
        plaza: '10VHT Villahermosa',
        cr: 'CR001',
        totalArticulos: 2,
      );
      expect(primerIntento.resultado, EnvioPedidoResultado.guardadoSinExportar);
      expect(pedidoService.llamadas, 1);

      // La pantalla, al ver que el guardado sí funcionó, pasaría yaGuardado=true aquí.
      final segundoIntento = await controller.enviar(
        yaGuardado: true,
        tiendaId: 'tienda-1',
        productos: _unProducto(),
        storeName: 'OXXO Centro',
        plaza: '10VHT Villahermosa',
        cr: 'CR001',
        totalArticulos: 2,
      );
      expect(segundoIntento.resultado, EnvioPedidoResultado.guardadoYCompartido);
      expect(pedidoService.llamadas, 1, reason: 'no debe crear un segundo pedido');
    });

    test('si el usuario cancela el cuadro de compartir, el pedido queda guardado', () async {
      final pedidoService = _PedidoServiceFalso();

      final controller = EnvioPedidoController(
        pedidoService: pedidoService,
        exportarExcel: ({required plaza, required tienda, required cr, required productos}) async =>
            '/tmp/pedido.xlsx',
        compartirOGuardar: (ruta, {required storeName, required totalArticulos}) async =>
            const CompartirResultado(ResultadoCompartir.cancelado),
      );

      final outcome = await controller.enviar(
        yaGuardado: false,
        tiendaId: 'tienda-1',
        productos: _unProducto(),
        storeName: 'OXXO Centro',
        plaza: '10VHT Villahermosa',
        cr: 'CR001',
        totalArticulos: 2,
      );

      expect(outcome.resultado, EnvioPedidoResultado.guardadoSinCompartir);
      expect(pedidoService.llamadas, 1);
    });

    test('si compartir cae a guardar en Descargas, informa la ruta', () async {
      final pedidoService = _PedidoServiceFalso();

      final controller = EnvioPedidoController(
        pedidoService: pedidoService,
        exportarExcel: ({required plaza, required tienda, required cr, required productos}) async =>
            '/tmp/pedido.xlsx',
        compartirOGuardar: (ruta, {required storeName, required totalArticulos}) async =>
            const CompartirResultado(
          ResultadoCompartir.guardadoEnDescargas,
          '/home/usuario/Descargas/pedido.xlsx',
        ),
      );

      final outcome = await controller.enviar(
        yaGuardado: false,
        tiendaId: 'tienda-1',
        productos: _unProducto(),
        storeName: 'OXXO Centro',
        plaza: '10VHT Villahermosa',
        cr: 'CR001',
        totalArticulos: 2,
      );

      expect(outcome.resultado, EnvioPedidoResultado.guardadoYArchivado);
      expect(outcome.rutaArchivo, '/home/usuario/Descargas/pedido.xlsx');
    });

    test('si no se puede compartir ni archivar, el pedido sigue guardado con error claro', () async {
      final pedidoService = _PedidoServiceFalso();

      final controller = EnvioPedidoController(
        pedidoService: pedidoService,
        exportarExcel: ({required plaza, required tienda, required cr, required productos}) async =>
            '/tmp/pedido.xlsx',
        compartirOGuardar: (ruta, {required storeName, required totalArticulos}) async =>
            const CompartirResultado(ResultadoCompartir.noDisponible),
      );

      final outcome = await controller.enviar(
        yaGuardado: false,
        tiendaId: 'tienda-1',
        productos: _unProducto(),
        storeName: 'OXXO Centro',
        plaza: '10VHT Villahermosa',
        cr: 'CR001',
        totalArticulos: 2,
      );

      expect(outcome.resultado, EnvioPedidoResultado.guardadoSinExportar);
      expect(pedidoService.llamadas, 1);
      expect(outcome.mensaje, isNotNull);
    });
  });
}
