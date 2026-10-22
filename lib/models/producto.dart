/// Producto del catálogo (ProductoRestResponse en el backend).
class Producto {
  final String id;
  final String nombre;
  final String sku;
  final String? unidad;
  final String? supergrupo;

  const Producto({
    required this.id,
    required this.nombre,
    required this.sku,
    required this.unidad,
    required this.supergrupo,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      sku: json['sku'] as String,
      unidad: json['unidad'] as String?,
      supergrupo: json['supergrupo'] as String?,
    );
  }
}
