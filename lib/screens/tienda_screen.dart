import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/perfil.dart';
import '../providers/auth_provider.dart';
import '../providers/pedido_provider.dart';
import 'login_screen.dart';
import 'pedidos_screen.dart';

/// Selector de tienda para cuentas con más de una asignada (asesores de
/// tienda). Las tiendas vienen del perfil autenticado, nunca de una
/// consulta aparte: un asesor solo puede elegir entre las suyas.
class TiendaScreen extends StatefulWidget {
  const TiendaScreen({super.key});

  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> {
  final searchController = TextEditingController();
  String? plazaSeleccionada;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<TiendaResumen> _filtrar(List<TiendaResumen> tiendas) {
    final query = searchController.text.toLowerCase();
    return tiendas.where((t) {
      final coincideTexto = query.isEmpty ||
          t.nombre.toLowerCase().contains(query) ||
          (t.codigo ?? '').toLowerCase().contains(query) ||
          (t.plaza ?? '').toLowerCase().contains(query);
      final coincidePlaza = plazaSeleccionada == null || t.plaza == plazaSeleccionada;
      return coincideTexto && coincidePlaza;
    }).toList();
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _elegir(BuildContext context, TiendaResumen tienda) {
    context.read<PedidoProvider>().seleccionarTienda(tienda);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PedidosScreen(storeName: tienda.nombre)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<AuthProvider>().perfil;
    final tiendas = perfil?.tiendas ?? const <TiendaResumen>[];
    final filtradas = _filtrar(tiendas);
    final plazas = tiendas.map((t) => t.plaza).whereType<String>().toSet().toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          perfil?.nombre ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _cerrarSesion(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.logout_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "¿En qué tienda\nestás hoy?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${filtradas.length} de ${tiendas.length} tiendas",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 14,
                      ),
                    ),
                    if (tiendas.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Buscar tienda o plaza...",
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Color(0xFFde2924), size: 20),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                          ),
                        ),
                      ),
                      if (plazas.length > 1) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 32,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: plazas.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final plaza = plazas[index];
                              final seleccionada = plazaSeleccionada == plaza;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  plazaSeleccionada = seleccionada ? null : plaza;
                                }),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: seleccionada
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    plaza.replaceAll('10VHT ', '').trim(),
                                    style: TextStyle(
                                      color: seleccionada
                                          ? const Color(0xFF9b101a)
                                          : Colors.white,
                                      fontWeight: seleccionada ? FontWeight.w800 : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: tiendas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined, size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          "No tienes tiendas asignadas",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Pide a un administrador que te asigne una",
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : filtradas.isEmpty
                    ? Center(
                        child: Text(
                          "No se encontró ninguna tienda",
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: filtradas.length,
                        itemBuilder: (context, index) {
                          final tienda = filtradas[index];
                          return GestureDetector(
                            onTap: () => _elegir(context, tienda),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFde2924).withOpacity(0.1),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
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
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFde2924), Color(0xFFed5c32)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.store_mall_directory_rounded,
                                          color: Colors.white, size: 26),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tienda.nombre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                              color: Color(0xFF1a1a1a),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${(tienda.plaza ?? '—').replaceAll('10VHT ', '')}  ·  ${tienda.codigo ?? '—'}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded,
                                        size: 15, color: Colors.grey.shade400),
                                  ],
                                ),
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
