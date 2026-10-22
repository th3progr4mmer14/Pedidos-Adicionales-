import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../models/producto_pedido.dart';

class ExcelExportService {
  /// Construye el workbook del pedido y devuelve sus bytes (.xlsx) ya
  /// codificados, sin tocar el sistema de archivos. Separado de
  /// [exportarPedido] para poder probarlo generando el archivo en memoria
  /// y volviendo a leerlo, sin depender de path_provider.
  static List<int> construirBytesPedido({
    required String plaza,
    required String tienda,
    required String cr,
    required List<ProductoPedido> productos,
    DateTime? fecha,
  }) {
    final ahora = fecha ?? DateTime.now();
    final excel = Excel.createExcel();

    // Excel.createExcel() ya trae una hoja por defecto (normalmente
    // "Sheet1"); en vez de crear una hoja "Pedido" aparte -lo que deja dos
    // hojas, una vacía- se renombra esa hoja por defecto y se marca como la
    // hoja activa al abrir el archivo.
    const nombreHoja = 'Pedido';
    final hojaPorDefecto = excel.getDefaultSheet();
    if (hojaPorDefecto != null && hojaPorDefecto != nombreHoja) {
      excel.rename(hojaPorDefecto, nombreHoja);
    }
    excel.setDefaultSheet(nombreHoja);
    final sheet = excel[nombreHoja];

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

    final fechaStr =
        "${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}";

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

    return excel.encode()!;
  }

  static Future<String> exportarPedido({
    required String plaza,
    required String tienda,
    required String cr,
    required List<ProductoPedido> productos,
  }) async {
    final fecha = DateTime.now();
    final bytes = construirBytesPedido(
      plaza: plaza,
      tienda: tienda,
      cr: cr,
      productos: productos,
      fecha: fecha,
    );

    final dir = await getTemporaryDirectory();
    final nombreArchivo =
        "pedido_${tienda.replaceAll(' ', '_')}_${fecha.day}${fecha.month}${fecha.year}.xlsx";
    final file = File("${dir.path}/$nombreArchivo");
    await file.writeAsBytes(bytes);

    return file.path;
  }
}
