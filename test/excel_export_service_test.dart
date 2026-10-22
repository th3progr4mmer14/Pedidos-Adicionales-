import 'package:ccv_app/models/producto_pedido.dart';
import 'package:ccv_app/services/excel_export_service.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'genera exactamente una hoja llamada Pedido, marcada como activa, '
      'con los datos del pedido', () {
    final productos = [
      ProductoPedido(
        nombre: 'Agua 600ml',
        sku: 'SKU-1',
        cantidad: 3,
        unidad: 'Pieza',
        observaciones: 'Urgente',
      ),
      ProductoPedido(
        nombre: 'Refresco 2L',
        sku: 'SKU-2',
        cantidad: 5,
        unidad: 'Pieza',
      ),
    ];

    final bytes = ExcelExportService.construirBytesPedido(
      plaza: '10VHT Villahermosa',
      tienda: 'OXXO Centro',
      cr: 'CR001',
      productos: productos,
      fecha: DateTime(2026, 10, 22),
    );

    final leido = Excel.decodeBytes(bytes);

    // Una sola hoja, sin la "Sheet1" vacía que deja Excel.createExcel() por defecto.
    expect(leido.tables.keys.toList(), ['Pedido']);
    expect(leido.getDefaultSheet(), 'Pedido');

    final sheet = leido.tables['Pedido']!;
    expect(sheet.maxRows, 3); // encabezado + 2 productos

    final encabezado = sheet.row(0).map((c) => c?.value?.toString()).toList();
    expect(encabezado, [
      'Fecha',
      'Plaza',
      'Tienda',
      'CR',
      'SKU',
      'Item Descripción',
      'Piezas',
      'Unidad',
      'Observaciones',
    ]);

    final fila1 = sheet.row(1).map((c) => c?.value?.toString()).toList();
    expect(fila1, [
      '22/10/2026',
      '10VHT Villahermosa',
      'OXXO Centro',
      'CR001',
      'SKU-1',
      'Agua 600ml',
      '3',
      'Pieza',
      'Urgente',
    ]);

    final fila2 = sheet.row(2).map((c) => c?.value?.toString()).toList();
    expect(fila2, [
      '22/10/2026',
      '10VHT Villahermosa',
      'OXXO Centro',
      'CR001',
      'SKU-2',
      'Refresco 2L',
      '5',
      'Pieza',
      '',
    ]);
  });
}
