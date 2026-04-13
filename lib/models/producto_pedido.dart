class ProductoPedido {
  final String nombre;
  final String sku;
  final int cantidad;
  final String unidad;
  final String? observaciones;

  ProductoPedido({
    required this.nombre,
    required this.sku,
    required this.cantidad,
    required this.unidad,
    this.observaciones,
  });
}
