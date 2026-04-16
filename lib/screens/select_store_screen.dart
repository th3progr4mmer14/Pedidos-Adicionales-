import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pedido_provider.dart';
import '../supabase_config.dart';
import 'pedidos_screen.dart';

class SelectStoreScreen extends StatefulWidget {
  const SelectStoreScreen({super.key});

  @override
  State<SelectStoreScreen> createState() => _SelectStoreScreenState();
}

class _SelectStoreScreenState extends State<SelectStoreScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();
  bool buscando = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  List<Map<String, dynamic>> stores = [];
  List<Map<String, dynamic>> storesFiltradas = [];
  bool cargando = true;
  String? errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarTiendas();
    searchController.addListener(_filtrar);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _cargarTiendas() async {
    try {
      List<Map<String, dynamic>> todas = [];
      int desde = 0;
      const int bloque = 1000;

      while (true) {
        final response = await supabase
            .from('tiendas')
            .select('nombre_tienda, codigo_tienda, plaza')
            .eq('activa', true)
            .order('nombre_tienda')
            .range(desde, desde + bloque - 1);

        todas.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < bloque) break;
        desde += bloque;
      }

      setState(() {
        stores = todas;
        storesFiltradas = todas;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        errorCarga = 'Error al cargar las tiendas';
        cargando = false;
      });
    }
  }

  void _abrirBuscador() {
    setState(() => buscando = true);
    _animController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      searchFocus.requestFocus();
    });
  }

  void _cerrarBuscador() {
    searchFocus.unfocus();
    _animController.reverse().then((_) {
      setState(() {
        buscando = false;
        searchController.clear();
      });
    });
  }

  void _filtrar() {
    final query = searchController.text.toLowerCase();
    setState(() {
      storesFiltradas = stores.where((s) {
        return s['nombre_tienda'].toString().toLowerCase().contains(query) ||
            s['codigo_tienda'].toString().toLowerCase().contains(query) ||
            s['plaza'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFde2924),
      const Color(0xFFed5c32),
      const Color(0xFFe8a042),
    ];

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
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: buscando
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,

                // ── Vista normal ──
                firstChild: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on,
                                    color: Color(0xFFfde521), size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "Región Tabasco",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // Lupa
                          GestureDetector(
                            onTap: cargando ? null : _abrirBuscador,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.search_rounded,
                                  color: Colors.white, size: 22),
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
                        cargando
                            ? "Cargando tiendas..."
                            : "${stores.length} tiendas disponibles",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Vista búsqueda ──
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _cerrarBuscador,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: searchController,
                                focusNode: searchFocus,
                                decoration: InputDecoration(
                                  hintText: "Buscar tienda o distrito...",
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14),
                                  prefixIcon: const Icon(Icons.search_rounded,
                                      color: Color(0xFFde2924), size: 20),
                                  suffixIcon: searchController.text.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () =>
                                              searchController.clear(),
                                          child: Icon(Icons.close_rounded,
                                              color: Colors.grey.shade400,
                                              size: 18),
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Contador ──
          if (buscando)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Row(
                children: [
                  Text(
                    storesFiltradas.isEmpty
                        ? "Sin resultados"
                        : "${storesFiltradas.length} tienda${storesFiltradas.length != 1 ? 's' : ''} encontrada${storesFiltradas.length != 1 ? 's' : ''}",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
                        Text("Cargando tiendas...",
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
                                  backgroundColor: const Color(0xFFde2924)),
                              onPressed: () {
                                setState(() {
                                  cargando = true;
                                  errorCarga = null;
                                });
                                _cargarTiendas();
                              },
                              child: const Text("Reintentar",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : () {
                        final lista =
                            buscando ? storesFiltradas : stores;

                        if (buscando && lista.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.store_outlined,
                                    size: 56,
                                    color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  "No se encontró ninguna tienda",
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          itemCount: lista.length,
                          itemBuilder: (context, index) {
                            final store = lista[index];

                            return GestureDetector(
                              onTap: () {
                                context
                                    .read<PedidoProvider>()
                                    .seleccionarTienda(
                                      store["nombre_tienda"],
                                      plaza: store["plaza"],
                                      cr: store["codigo_tienda"],
                                    );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PedidosScreen(
                                      storeName: store["nombre_tienda"],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors[index % colors.length]
                                          .withOpacity(0.1),
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
                                          gradient: LinearGradient(
                                            colors: [
                                              colors[
                                                  index % colors.length],
                                              colors[index % colors.length]
                                                  .withOpacity(0.7),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                            Icons
                                                .store_mall_directory_rounded,
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
                                              store["nombre_tienda"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                                color: Color(0xFF1a1a1a),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${store['plaza']}  ·  ${store['codigo_tienda']}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color:
                                              colors[index % colors.length]
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 15,
                                          color:
                                              colors[index % colors.length],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }(),
          ),
        ],
      ),
    );
  }
}
