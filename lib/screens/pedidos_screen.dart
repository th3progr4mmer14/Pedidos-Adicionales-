import 'package:flutter/material.dart';
import 'nuevo_pedido_screen.dart';
import 'historial_screen.dart';

class PedidosScreen extends StatelessWidget {
  final String storeName;

  const PedidosScreen({
    super.key,
    required this.storeName,
  });

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
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.store_rounded,
                                  color: Color(0xFFfde521), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                storeName,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Gestión de\nPedidos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Crea y gestiona tus pedidos fácilmente",
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // ── Card Nuevo Pedido ──
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NuevoPedidoScreen(storeName: storeName),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFde2924), Color(0xFFed5c32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFde2924).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nuevo Pedido",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Agrega productos del catálogo\ny genera tu pedido",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Card Historial ──
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistorialScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9b101a), Color(0xFFe8a042)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF9b101a).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Historial",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Consulta los pedidos\nanteriormente enviados",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.history_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Info card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfde521).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.info_outline_rounded,
                              color: Color(0xFFe8a042), size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            "Selecciona productos del catálogo, define cantidades y exporta tu pedido en Excel.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}