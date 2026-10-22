import 'package:ccv_app/models/perfil.dart';
import 'package:ccv_app/models/producto_pedido.dart';
import 'package:ccv_app/providers/pedido_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tienda = TiendaResumen(
    id: 'tienda-1',
    codigo: 'CR001',
    nombre: 'OXXO Centro',
    plaza: '10VHT Villahermosa',
  );

  group('pedidoGuardado', () {
    test('empieza en false al seleccionar una tienda', () {
      final provider = PedidoProvider();
      provider.seleccionarTienda(tienda);
      expect(provider.pedidoGuardado, isFalse);
    });

    test('marcarPedidoGuardado lo pone en true', () {
      final provider = PedidoProvider();
      provider.seleccionarTienda(tienda);
      provider.marcarPedidoGuardado();
      expect(provider.pedidoGuardado, isTrue);
    });

    test('limpiarPedido lo resetea a false', () {
      final provider = PedidoProvider();
      provider.seleccionarTienda(tienda);
      provider.marcarPedidoGuardado();
      provider.limpiarPedido();
      expect(provider.pedidoGuardado, isFalse);
    });

    test('seleccionar una nueva tienda resetea el flag del pedido anterior', () {
      final provider = PedidoProvider();
      provider.seleccionarTienda(tienda);
      provider.marcarPedidoGuardado();

      provider.seleccionarTienda(const TiendaResumen(
        id: 'tienda-2',
        codigo: 'CR002',
        nombre: 'OXXO Norte',
        plaza: '10VHT Villahermosa',
      ));

      expect(provider.pedidoGuardado, isFalse);
    });

    test('los items se conservan si el pedido ya se guardó pero no se ha limpiado', () {
      final provider = PedidoProvider();
      provider.seleccionarTienda(tienda);
      provider.agregarProducto(ProductoPedido(
        nombre: 'Agua 600ml',
        sku: 'SKU-1',
        cantidad: 3,
        unidad: 'Pieza',
      ));
      provider.marcarPedidoGuardado();

      expect(provider.pedidoGuardado, isTrue);
      expect(provider.items, hasLength(1));
    });
  });
}
