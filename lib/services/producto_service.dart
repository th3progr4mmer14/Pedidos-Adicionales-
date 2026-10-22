import '../models/producto.dart';
import 'api_client.dart';

/// Catálogo de productos (/api/v1/productos). El backend pagina con un
/// tamaño máximo de 200 por página, así que para reproducir el catálogo
/// completo (como antes hacía el bloque de Supabase) se recorren todas
/// las páginas.
class ProductoService {
  ProductoService(this._api);

  static const int _tamanoPagina = 200;

  final ApiClient _api;

  Future<List<Producto>> listarTodosActivos() async {
    final productos = <Producto>[];
    int pagina = 0;

    while (true) {
      final response = await _api.get('/productos', queryParameters: {
        'pagina': pagina,
        'tamano': _tamanoPagina,
      });
      final data = response.data as Map<String, dynamic>;
      final contenido = (data['contenido'] as List)
          .map((p) => Producto.fromJson(p as Map<String, dynamic>))
          .toList();
      productos.addAll(contenido);
      if (contenido.length < _tamanoPagina) break;
      pagina++;
    }

    return productos;
  }
}
