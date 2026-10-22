import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../providers/pedido_provider.dart';
import '../services/envio_pedido_controller.dart';
import 'nuevo_pedido_screen.dart';
import 'pedido_enviado_screen.dart';

class ResumenPedidoScreen extends StatefulWidget {
  final String storeName;
  final EnvioPedidoController? controller;

  ResumenPedidoScreen({
    super.key,
    required this.storeName,
    this.controller,
  });

  @override
  State<ResumenPedidoScreen> createState() => _ResumenPedidoScreenState();
}

class _ResumenPedidoScreenState extends State<ResumenPedidoScreen> {
  late final EnvioPedidoController _controller =
      widget.controller ?? EnvioPedidoController();

  bool procesando = false;
  String? fase;
  String? error;
  String? info;
  Timer? _esperaTimer;

  @override
  void dispose() {
    _esperaTimer?.cancel();
    super.dispose();
  }

  Future<void> _enviarPedido(PedidoProvider pedidoProvider) async {
    final yaGuardado = pedidoProvider.pedidoGuardado;

    setState(() {
      procesando = true;
      error = null;
      info = null;
      fase = yaGuardado ? 'Generando Excel...' : 'Guardando pedido...';
    });

    if (!yaGuardado) {
      _esperaTimer = Timer(ApiConfig.avisoServidorDormido, () {
        if (mounted) {
          setState(() => fase =
              'Despertando el servidor, esto puede tardar hasta un minuto...');
        }
      });
    }

    final outcome = await _controller.enviar(
      yaGuardado: yaGuardado,
      tiendaId: pedidoProvider.tiendaId,
      productos: pedidoProvider.items,
      storeName: widget.storeName,
      plaza: pedidoProvider.plaza ?? "",
      cr: pedidoProvider.cr ?? "",
      totalArticulos: pedidoProvider.totalProductos,
    );

    _esperaTimer?.cancel();
    _esperaTimer = null;

    if (outcome.resultado == EnvioPedidoResultado.errorGuardando) {
      if (mounted) {
        setState(() {
          procesando = false;
          fase = null;
          error = outcome.mensaje;
        });
      }
      return;
    }

    // A partir de aquí el pedido ya quedó guardado en el backend (recién o
    // en un intento anterior): no hay que volver a crearlo.
    if (!pedidoProvider.pedidoGuardado) {
      pedidoProvider.marcarPedidoGuardado();
    }

    switch (outcome.resultado) {
      case EnvioPedidoResultado.guardadoYCompartido:
        pedidoProvider.limpiarPedido();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PedidoEnviadoScreen()),
            (route) => false,
          );
        }
        return;
      case EnvioPedidoResultado.guardadoYArchivado:
        pedidoProvider.limpiarPedido();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => PedidoEnviadoScreen(
                mensaje: 'Pedido guardado. El Excel se guardó en:\n${outcome.rutaArchivo}',
              ),
            ),
            (route) => false,
          );
        }
        return;
      case EnvioPedidoResultado.guardadoSinCompartir:
        if (mounted) {
          setState(() {
            procesando = false;
            fase = null;
            info = outcome.mensaje;
          });
        }
        return;
      case EnvioPedidoResultado.guardadoSinExportar:
        if (mounted) {
          setState(() {
            procesando = false;
            fase = null;
            error = outcome.mensaje;
          });
        }
        return;
      case EnvioPedidoResultado.errorGuardando:
        return; // ya manejado arriba
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>();
    final items = pedidoProvider.items;
    final guardado = pedidoProvider.pedidoGuardado;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: items.isEmpty
          ? Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF9b101a), Color(0xFFde2924)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            "Resumen del Pedido",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 72, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Tu pedido está vacío",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF444444)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Agrega productos desde el catálogo",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // ── Header ──
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF9b101a), Color(0xFFde2924)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Resumen del Pedido",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.store_rounded,
                                  color: Color(0xFFfde521), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                widget.storeName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFfde521),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${items.length} productos",
                                  style: const TextStyle(
                                    color: Color(0xFF9b101a),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Lista ──
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final producto = items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF9b101a),
                                      Color(0xFFde2924)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      producto.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Color(0xFF1a1a1a),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFed5c32)
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            "${producto.cantidad} ${producto.unidad}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFed5c32),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (producto.observaciones != null &&
                                            producto.observaciones!
                                                .isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              producto.observaciones!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                                fontStyle: FontStyle.italic,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: guardado
                                    ? null
                                    : () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            title:
                                                const Text("Eliminar producto"),
                                            content: Text(
                                                "¿Eliminar \"${producto.nombre}\"?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Cancelar"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  pedidoProvider
                                                      .eliminarProducto(index);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Eliminar",
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (guardado ? Colors.grey : Colors.red)
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: guardado ? Colors.grey : Colors.red,
                                      size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Panel inferior ──
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total de artículos",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF444444),
                              ),
                            ),
                            Text(
                              "${pedidoProvider.totalProductos}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                color: Color(0xFF9b101a),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (guardado) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "Pedido guardado. Termina de generar o compartir el Excel para continuar.",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (procesando) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                fase ?? '',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (!procesando && error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          error!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      if (!procesando && info != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          info!,
                          style: const TextStyle(color: Color(0xFF9b101a), fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add_rounded),
                          label: const Text("Agregar otro producto"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF9b101a),
                            side: const BorderSide(
                                color: Color(0xFF9b101a), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: guardado
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NuevoPedidoScreen(
                                          storeName: widget.storeName),
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          icon: Icon(
                              guardado
                                  ? Icons.refresh_rounded
                                  : Icons.share_rounded,
                              color: Colors.white),
                          label: Text(
                            guardado
                                ? "Reintentar exportar y compartir"
                                : "Exportar y compartir",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9b101a),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            shadowColor:
                                const Color(0xFF9b101a).withOpacity(0.4),
                          ),
                          onPressed: procesando
                              ? null
                              : () => _enviarPedido(pedidoProvider),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton.icon(
                          icon: Icon(Icons.delete_sweep_rounded,
                              color: guardado ? Colors.grey.shade300 : Colors.grey,
                              size: 18),
                          label: Text("Limpiar pedido",
                              style: TextStyle(
                                  color: guardado ? Colors.grey.shade300 : Colors.grey,
                                  fontSize: 14)),
                          onPressed: guardado
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      title: const Text("Limpiar pedido"),
                                      content: const Text(
                                          "¿Eliminar todos los productos del pedido?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            pedidoProvider.limpiarPedido();
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Limpiar",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
