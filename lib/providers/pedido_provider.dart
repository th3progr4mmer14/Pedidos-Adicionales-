import 'package:flutter/material.dart';
import '../models/producto_pedido.dart';

class PedidoProvider extends ChangeNotifier {

  final List<ProductoPedido> _items = [];

  String? _storeName;
  String? _plaza;
  String? _cr;

  List<ProductoPedido> get items => _items;
  String? get storeName => _storeName;
  String? get plaza => _plaza;
  String? get cr => _cr;

  void seleccionarTienda(String nombre, {String? plaza, String? cr}) {
    _storeName = nombre;
    _plaza = plaza;
    _cr = cr;
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
