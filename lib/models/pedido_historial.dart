/// Un pedido tal como lo devuelve el backend (PedidoRestResponse), con el
/// detalle de productos ya incluido: no hace falta una segunda llamada
/// para ver el detalle de un pedido del historial.
class PedidoHistorial {
  final String id;
  final String nombreTienda;
  final String? codigoTienda;
  final String? plaza;
  final String estatus;
  final DateTime fechaPedido;
  final int totalArticulos;
  final List<DetalleHistorial> detalles;

  const PedidoHistorial({
    required this.id,
    required this.nombreTienda,
    required this.codigoTienda,
    required this.plaza,
    required this.estatus,
    required this.fechaPedido,
    required this.totalArticulos,
    required this.detalles,
  });

  factory PedidoHistorial.fromJson(Map<String, dynamic> json) {
    return PedidoHistorial(
      id: json['id'] as String,
      nombreTienda: json['nombreTienda'] as String,
      codigoTienda: json['codigoTienda'] as String?,
      plaza: json['plaza'] as String?,
      estatus: json['estatus'] as String,
      fechaPedido: DateTime.parse(json['fechaPedido'] as String),
      totalArticulos: json['totalArticulos'] as int,
      detalles: (json['detalles'] as List)
          .map((d) => DetalleHistorial.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DetalleHistorial {
  final String? productoId;
  final String nombreProducto;
  final String? sku;
  final int cantidad;
  final String? unidad;
  final String? observaciones;

  const DetalleHistorial({
    required this.productoId,
    required this.nombreProducto,
    required this.sku,
    required this.cantidad,
    required this.unidad,
    required this.observaciones,
  });

  factory DetalleHistorial.fromJson(Map<String, dynamic> json) {
    return DetalleHistorial(
      productoId: json['productoId'] as String?,
      nombreProducto: json['nombreProducto'] as String,
      sku: json['sku'] as String?,
      cantidad: json['cantidad'] as int,
      unidad: json['unidad'] as String?,
      observaciones: json['observaciones'] as String?,
    );
  }
}
