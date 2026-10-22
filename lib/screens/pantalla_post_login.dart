import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/perfil.dart';
import '../providers/pedido_provider.dart';
import 'pedidos_screen.dart';
import 'tienda_screen.dart';

/// Decide a qué pantalla ir después de autenticarse. Un colaborador solo
/// tiene una tienda asignada: se salta el selector y se va directo a
/// Pedidos. Un asesor (varias tiendas) o alguien sin tiendas asignadas
/// (por ejemplo un admin) pasa por el selector.
void irAPantallaSegunPerfil(BuildContext context, Perfil perfil) {
  final tiendas = perfil.tiendas;

  if (tiendas.length == 1) {
    final tienda = tiendas.first;
    context.read<PedidoProvider>().seleccionarTienda(tienda);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => PedidosScreen(storeName: tienda.nombre)),
      (route) => false,
    );
    return;
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const TiendaScreen()),
    (route) => false,
  );
}
