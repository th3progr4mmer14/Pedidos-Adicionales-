import '../models/pedido_historial.dart';
import '../models/producto_pedido.dart';
import 'api_client.dart';

/// Pedidos (/api/v1/pedidos): crear y listar. No hay un endpoint de
/// historial separado; "historial" es listar los pedidos recientes de tu
/// alcance, que ya vienen con su detalle de productos incluido.
class PedidoService {
  PedidoService(this._api);

  final ApiClient _api;

  Future<void> crear({
    required String? tiendaId,
    required List<ProductoPedido> productos,
  }) async {
    await _api.post('/pedidos', data: {
      'tiendaId': tiendaId,
      'detalles': productos
          .map((p) => {
                'productoId': p.productoId,
                'nombreProducto': p.nombre,
                'sku': p.sku,
                'cantidad': p.cantidad,
                'unidad': p.unidad,
                'observaciones': p.observaciones ?? '',
              })
          .toList(),
    });
  }

  Future<List<PedidoHistorial>> listarRecientes({int limite = 100}) async {
    final response = await _api.get('/pedidos', queryParameters: {'limite': limite});
    return (response.data as List)
        .map((p) => PedidoHistorial.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
