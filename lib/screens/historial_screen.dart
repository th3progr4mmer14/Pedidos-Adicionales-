import 'package:flutter/material.dart';
import '../supabase_config.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<Map<String, dynamic>> pedidos = [];
  bool cargando = true;
  String? errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    try {
      final response = await supabase
          .from('pedidos')
          .select(
              'id_pedido, fecha_pedido, nombre_tienda, codigo_tienda, plaza, total_articulos, estatus')
          .order('fecha_pedido', ascending: false)
          .limit(100);

      setState(() {
        pedidos = List<Map<String, dynamic>>.from(response);
        cargando = false;
      });
    } catch (e) {
      setState(() {
        errorCarga = 'Error al cargar el historial';
        cargando = false;
      });
    }
  }

  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null) return '—';
    final fecha = DateTime.tryParse(fechaStr);
    if (fecha == null) return '—';
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}  ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
  }

  void _verDetalle(BuildContext context, Map<String, dynamic> pedido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetallePedidoScreen(pedido: pedido),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                          color: Colors.white.withOpacity(0.2),
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
                        color: Colors.white.withOpacity(0.75),
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
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFde2924)),
                        SizedBox(height: 16),
                        Text("Cargando historial...",
                            style: TextStyle(color: Color(0xFF666666))),
                      ],
                    ),
                  )
                : errorCarga != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off_rounded,
                                color: Colors.grey, size: 56),
                            const SizedBox(height: 12),
                            Text(errorCarga!,
                                style:
                                    const TextStyle(color: Colors.grey)),
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
                                    color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                const Text(
                                  "Sin pedidos aún",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF444444),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Los pedidos enviados aparecerán aquí",
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
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
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.05),
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
                                                  pedido[
                                                          'nombre_tienda'] ??
                                                      '—',
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    fontSize: 15,
                                                    color:
                                                        Color(0xFF1a1a1a),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "${pedido['plaza']?.toString().replaceAll('10VHT ', '') ?? '—'}  ·  ${pedido['codigo_tienda'] ?? '—'}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors
                                                        .grey.shade500,
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
                                                            .withOpacity(
                                                                0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        "${pedido['total_articulos'] ?? 0} artículos",
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
                                                      _formatearFecha(pedido[
                                                              'fecha_pedido']
                                                          ?.toString()),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .grey.shade400,
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
                                            color: Colors.grey.shade400,
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
class DetallePedidoScreen extends StatefulWidget {
  final Map<String, dynamic> pedido;

  const DetallePedidoScreen({super.key, required this.pedido});

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  List<Map<String, dynamic>> detalle = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    try {
      final response = await supabase
          .from('detalle_pedido')
          .select('nombre_producto, sku, cantidad, unidad, observaciones')
          .eq('id_pedido', widget.pedido['id_pedido']);

      setState(() {
        detalle = List<Map<String, dynamic>>.from(response);
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null) return '—';
    final fecha = DateTime.tryParse(fechaStr);
    if (fecha == null) return '—';
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}  ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pedido['nombre_tienda'] ?? '—',
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
                          _formatearFecha(
                              pedido['fecha_pedido']?.toString()),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
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
                            "${pedido['total_articulos'] ?? 0} artículos",
                            style: const TextStyle(
                              color: Color(0xFF9b101a),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${pedido['plaza']?.toString().replaceAll('10VHT ', '') ?? '—'}  ·  ${pedido['codigo_tienda'] ?? '—'}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
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
            child: cargando
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFde2924)),
                  )
                : detalle.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 56, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              "Sin detalle disponible",
                              style: TextStyle(
                                  color: Colors.grey.shade400,
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
                                          item['nombre_producto'] ?? '—',
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                        0xFFed5c32)
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                "${item['cantidad']} ${item['unidad']}",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFFed5c32),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              item['sku'] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (item['observaciones'] != null &&
                                            item['observaciones']
                                                .toString()
                                                .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4),
                                            child: Text(
                                              item['observaciones'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
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
