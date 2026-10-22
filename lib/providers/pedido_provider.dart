import 'package:flutter/material.dart';
import '../models/perfil.dart';
import '../models/producto_pedido.dart';

class PedidoProvider extends ChangeNotifier {

  final List<ProductoPedido> _items = [];

  String? _tiendaId;
  String? _storeName;
  String? _plaza;
  String? _cr;

  List<ProductoPedido> get items => _items;
  String? get tiendaId => _tiendaId;
  String? get storeName => _storeName;
  String? get plaza => _plaza;
  String? get cr => _cr;

  /// La tienda y la plaza vienen del perfil autenticado, no de una selección
  /// libre: un colaborador solo ve la suya y un asesor solo las que le
  /// asignaron.
  void seleccionarTienda(TiendaResumen tienda) {
    _tiendaId = tienda.id;
    _storeName = tienda.nombre;
    _plaza = tienda.plaza;
    _cr = tienda.codigo;
    _items.clear();
    notifyListeners();
  }

  void agregarProducto(ProductoPedido producto) {
    _items.add(producto);
    notifyListeners();
  }

  void eliminarProducto(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  int get totalProductos {
    int total = 0;
    for (var item in _items) {
      total += item.cantidad;
    }
    return total;
  }

  void limpiarPedido() {
    _items.clear();
    notifyListeners();
  }
}
