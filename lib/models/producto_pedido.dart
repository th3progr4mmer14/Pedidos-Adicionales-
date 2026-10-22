class ProductoPedido {
  final String? productoId;
  final String nombre;
  final String sku;
  final int cantidad;
  final String unidad;
  final String? observaciones;

  ProductoPedido({
    this.productoId,
    required this.nombre,
    required this.sku,
    required this.cantidad,
    required this.unidad,
    this.observaciones,
  });
}
