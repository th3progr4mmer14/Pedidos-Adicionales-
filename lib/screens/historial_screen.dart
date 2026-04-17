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
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFde2924)),
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
                                return Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Row(
                                      children: [
                                        // Ícono
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF9b101a),
                                                Color(0xFFde2924)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: const Icon(
                                              Icons.receipt_long_rounded,
                                              color: Colors.white,
                                              size: 26),
                                        ),
                                        const SizedBox(width: 16),
                                        // Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pedido['nombre_tienda'] ??
                                                    '—',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                  color: Color(0xFF1a1a1a),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${pedido['plaza'] ?? '—'}  ·  ${pedido['codigo_tienda'] ?? '—'}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  // Total artículos
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xFFde2924)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      "${pedido['total_articulos'] ?? 0} artículos",
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Color(0xFF9b101a),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Fecha
                                                  Text(
                                                    _formatearFecha(pedido[
                                                            'fecha_pedido']
                                                        ?.toString()),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  ),
                                                ],
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
          ),
        ],
      ),
    );
  }
}