import 'dart:async';

import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/pedido_historial.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/pedido_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final PedidoService _pedidoService = PedidoService(ApiClient.instance);

  List<PedidoHistorial> pedidos = [];
  bool cargando = true;
  String? errorCarga;
  String? mensajeEspera;
  Timer? _esperaTimer;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  @override
  void dispose() {
    _esperaTimer?.cancel();
    super.dispose();
  }

  Future<void> _cargarHistorial() async {
    _esperaTimer = Timer(ApiConfig.avisoServidorDormido, () {
      if (mounted) {
        setState(() => mensajeEspera =
            'Despertando el servidor, esto puede tardar hasta un minuto...');
      }
    });

    try {
      final resultado = await _pedidoService.listarRecientes(limite: 100);
      setState(() {
        pedidos = resultado;
        cargando = false;
      });
    } on ApiException catch (e) {
      setState(() {
        errorCarga = e.mensaje;
        cargando = false;
      });
    } finally {
      _esperaTimer?.cancel();
      if (mounted) setState(() => mensajeEspera = null);
    }
  }

  String _formatearFecha(DateTime fecha) {
    final local = fecha.toLocal();
    return "${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}  ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }

  void _verDetalle(BuildContext context, PedidoHistorial pedido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetallePedidoScreen(pedido: pedido),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9b101a), Color(0xFFde2924)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Historial de\nPedidos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cargando
                          ? "Cargando..."
                          : "${pedidos.length} pedidos registrados",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenido ──
          Expanded(
            child: cargando
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFFde2924)),
                        const SizedBox(height: 16),
                        Text(mensajeEspera ?? "Cargando historial...",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : errorCarga != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off_rounded,
                                color: scheme.onSurfaceVariant, size: 56),
                            const SizedBox(height: 12),
                            Text(errorCarga!,
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: scheme.onSurfaceVariant)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFde2924)),
                              onPressed: () {
                                setState(() {
                                  cargando = true;
                                  errorCarga = null;
                                });
                                _cargarHistorial();
                              },
                              child: const Text("Reintentar",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : pedidos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_rounded,
                                    size: 72,
                                    color: scheme.onSurfaceVariant),
                                const SizedBox(height: 16),
                                Text(
                                  "Sin pedidos aún",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Los pedidos enviados aparecerán aquí",
                                  style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: const Color(0xFFde2924),
                            onRefresh: _cargarHistorial,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 20, 16, 16),
                              itemCount: pedidos.length,
                              itemBuilder: (context, index) {
                                final pedido = pedidos[index];
                                return GestureDetector(
                                  onTap: () =>
                                      _verDetalle(context, pedido),
                                  child: Container(
                                    margin:
                                        const EdgeInsets.only(bottom: 14),
                                    decoration: BoxDecoration(
                                      color: scheme.surfaceContainerHighest,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              gradient:
                                                  const LinearGradient(
                                                colors: [
                                                  Color(0xFF9b101a),
                                                  Color(0xFFde2924)
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14),
                                            ),
                                            child: const Icon(
                                                Icons.receipt_long_rounded,
                                                color: Colors.white,
                                                size: 26),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  pedido.nombreTienda,
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    fontSize: 15,
                                                    color: scheme.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "${(pedido.plaza ?? '—').replaceAll('10VHT ', '')}  ·  ${pedido.codigoTienda ?? '—'}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: scheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 3),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: const Color(
                                                                0xFFde2924)
                                                            .withValues(
                                                                alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        "${pedido.totalArticulos} artículos",
                                                        style:
                                                            const TextStyle(
                                                          fontSize: 11,
                                                          color: Color(
                                                              0xFF9b101a),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _formatearFecha(
                                                          pedido.fechaPedido),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: scheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 14,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Pantalla de detalle ──
class DetallePedidoScreen extends StatelessWidget {
  final PedidoHistorial pedido;

  const DetallePedidoScreen({super.key, required this.pedido});

  String _formatearFecha(DateTime fecha) {
    final local = fecha.toLocal();
    return "${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}  ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final detalle = pedido.detalles;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9b101a), Color(0xFFde2924)],
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pedido.nombreTienda,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: Color(0xFFfde521), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _formatearFecha(pedido.fechaPedido),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfde521),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${pedido.totalArticulos} artículos",
                            style: const TextStyle(
                              color: Color(0xFF9b101a),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${(pedido.plaza ?? '—').replaceAll('10VHT ', '')}  ·  ${pedido.codigoTienda ?? '—'}",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Lista productos ──
          Expanded(
            child: detalle.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 56, color: scheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          "Sin detalle disponible",
                          style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    itemCount: detalle.length,
                    itemBuilder: (context, index) {
                      final item = detalle[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
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
                                      item.nombreProducto,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                                    0xFFed5c32)
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            "${item.cantidad} ${item.unidad ?? ''}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFed5c32),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          item.sku ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item.observaciones != null &&
                                        item.observaciones!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4),
                                        child: Text(
                                          item.observaciones!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: scheme.onSurfaceVariant,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
