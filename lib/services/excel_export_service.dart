import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../models/producto_pedido.dart';

class ExcelExportService {
  static Future<String> exportarPedido({
    required String plaza,
    required String tienda,
    required String cr,
    required List<ProductoPedido> productos,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Pedido'];

    // Encabezados
    sheet.appendRow([
      TextCellValue("Fecha"),
      TextCellValue("Plaza"),
      TextCellValue("Tienda"),
      TextCellValue("CR"),
      TextCellValue("SKU"),
      TextCellValue("Item Descripción"),
      TextCellValue("Piezas"),
      TextCellValue("Unidad"),
      TextCellValue("Observaciones"),
    ]);

    final fecha = DateTime.now();
    final fechaStr =
        "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";

    for (var producto in productos) {
      sheet.appendRow([
        TextCellValue(fechaStr),
        TextCellValue(plaza),
        TextCellValue(tienda),
        TextCellValue(cr),
        TextCellValue(producto.sku),
        TextCellValue(producto.nombre),
        IntCellValue(producto.cantidad),
        TextCellValue(producto.unidad),
        TextCellValue(producto.observaciones ?? ""),
      ]);
    }

    final dir = await getTemporaryDirectory();
    final nombreArchivo =
        "pedido_${tienda.replaceAll(' ', '_')}_${fecha.day}${fecha.month}${fecha.year}.xlsx";
    final file = File("${dir.path}/$nombreArchivo");
    final bytes = excel.encode();
    await file.writeAsBytes(bytes!);

    return file.path;
  }
}
