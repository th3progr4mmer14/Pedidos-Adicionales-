import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/legal_texts.dart';
import '../models/perfil.dart';
import '../providers/pedido_provider.dart';
import 'pedidos_screen.dart';
import 'reaceptar_politicas_screen.dart';
import 'tienda_screen.dart';

/// Decide a qué pantalla ir después de autenticarse. Si las políticas que
/// aceptó el usuario ya no son la versión vigente (p. ej. subió
/// LegalTexts.version después de que activó su cuenta), lo manda a una
/// pantalla bloqueante antes de dejarlo seguir. Si no, un colaborador con
/// una sola tienda se salta el selector y va directo a Pedidos; un asesor
/// (varias tiendas) o alguien sin tiendas asignadas pasa por el selector.
void irAPantallaSegunPerfil(BuildContext context, Perfil perfil) {
  if (perfil.politicasVersion != LegalTexts.version) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ReaceptarPoliticasScreen()),
      (route) => false,
    );
    return;
  }

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
