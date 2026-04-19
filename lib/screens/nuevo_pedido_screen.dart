import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pedido_provider.dart';
import '../models/producto_pedido.dart';
import '../supabase_config.dart';
import 'resumen_pedido_screen.dart';

class NuevoPedidoScreen extends StatefulWidget {
  final String storeName;

  const NuevoPedidoScreen({
    super.key,
    required this.storeName,
  });

  @override
  State<NuevoPedidoScreen> createState() => _NuevoPedidoScreenState();
}

class _NuevoPedidoScreenState extends State<NuevoPedidoScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

  String? productoSeleccionado;
  String? skuSeleccionado;
  String unidadSeleccionada = "Pieza";
  String? supergrupoSeleccionado;

  List<Map<String, dynamic>> catalogo = [];
  List<Map<String, dynamic>> productosFiltrados = [];
  List<String> supergrupos = [];
  bool cargando = true;
  String? errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
    searchController.addListener(_aplicarFiltros);
  }

  Future<void> _cargarCatalogo() async {
    try {
      List<Map<String, dynamic>> todos = [];
      int desde = 0;
      const int bloque = 1000;

      while (true) {
        final response = await supabase
            .from('productos')
            .select('nombre_producto, sku, unidad, supergrupo')
            .eq('activo', true)
            .order('nombre_producto')
            .range(desde, desde + bloque - 1);

        todos.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < bloque) break;
        desde += bloque;
      }

      // Extraer supergrupos únicos
      final Set<String> supergruposSet = {};
      for (var p in todos) {
        if (p['supergrupo'] != null &&
            p['supergrupo'].toString().isNotEmpty) {
          supergruposSet.add(p['supergrupo'].toString());
        }
      }
      final listaSupergrupos = supergruposSet.toList()..sort();

      setState(() {
        catalogo = todos;
        productosFiltrados = todos;
        supergrupos = listaSupergrupos;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        errorCarga = 'Error al cargar el catálogo';
        cargando = false;
      });
    }
  }

  void _aplicarFiltros() {
    final query = searchController.text.toLowerCase();
    setState(() {
      productosFiltrados = catalogo.where((p) {
        final coincideTexto = query.isEmpty ||
            p['nombre_producto'].toString().toLowerCase().contains(query) ||
            p['sku'].toString().toLowerCase().contains(query);

        final coincideSupergrupo = supergrupoSeleccionado == null ||
            p['supergrupo'].toString() == supergrupoSeleccionado;

        return coincideTexto && coincideSupergrupo;
      }).toList();
    });
  }

  void _seleccionarSupergrupo(String supergrupo) {
    setState(() {
      supergrupoSeleccionado =
          supergrupoSeleccionado == supergrupo ? null : supergrupo;
    });
    _aplicarFiltros();
  }

  void agregarProducto() {
    final pedidoProvider = context.read<PedidoProvider>();

    if (productoSeleccionado == null ||
        cantidadController.text.isEmpty ||
        int.tryParse(cantidadController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Completa los campos obligatorios"),
          backgroundColor: const Color(0xFF9b101a),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    pedidoProvider.agregarProducto(ProductoPedido(
      nombre: productoSeleccionado!,
      sku: skuSeleccionado ?? '',
      cantidad: int.parse(cantidadController.text),
      unidad: unidadSeleccionada,
      observaciones: observacionesController.text,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("✓ Producto agregado al pedido"),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    setState(() {
      productoSeleccionado = null;
      skuSeleccionado = null;
      cantidadController.clear();
      observacionesController.clear();
      searchController.clear();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    cantidadController.dispose();
    observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeName = context.watch<PedidoProvider>().storeName ?? "";
    final totalItems = context.watch<PedidoProvider>().items.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: cargando
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFde2924)),
                  SizedBox(height: 16),
                  Text("Cargando catálogo...",
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
                          _cargarCatalogo();
                        },
                        child: const Text("Reintentar",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : Column(
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
                          padding:
                              const EdgeInsets.fromLTRB(24, 16, 24, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: Colors.white,
                                          size: 16),
                                    ),
                                  ),
                                  if (totalItems > 0)
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ResumenPedidoScreen(
                                                  storeName: storeName),
                                        ),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFfde521),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.shopping_cart_rounded,
                                                size: 16,
                                                color: Color(0xFF9b101a)),
                                            const SizedBox(width: 4),
                                            Text(
                                              "$totalItems en pedido",
                                              style: const TextStyle(
                                                color: Color(0xFF9b101a),
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Agregar Producto",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                storeName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Chips de supergrupo ──
                              SizedBox(
                                height: 34,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: supergrupos.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final sg = supergrupos[index];
                                    final seleccionado =
                                        supergrupoSeleccionado == sg;

                                    return GestureDetector(
                                      onTap: () =>
                                          _seleccionarSupergrupo(sg),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: seleccionado
                                              ? Colors.white
                                              : Colors.white
                                                  .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          sg,
                                          style: TextStyle(
                                            color: seleccionado
                                                ? const Color(0xFF9b101a)
                                                : Colors.white,
                                            fontWeight: seleccionado
                                                ? FontWeight.w800
                                                : FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Formulario ──
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Buscador
                            _SectionLabel(label: "Buscar producto"),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  hintText: "Nombre o SKU...",
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade400),
                                  prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      color: Color(0xFFde2924)),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              child: Text(
                                "${productosFiltrados.length} productos${supergrupoSeleccionado != null ? ' en $supergrupoSeleccionado' : ''}",
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Lista productos
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ListView.separated(
                                  itemCount: productosFiltrados.length,
                                  separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      color: Colors.grey.shade100),
                                  itemBuilder: (context, index) {
                                    final producto =
                                        productosFiltrados[index];
                                    final seleccionado =
                                        productoSeleccionado ==
                                            producto['nombre_producto'];

                                    return ListTile(
                                      selected: seleccionado,
                                      selectedTileColor:
                                          const Color(0xFFde2924)
                                              .withOpacity(0.06),
                                      title: Text(
                                        producto['nombre_producto'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: seleccionado
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          color: seleccionado
                                              ? const Color(0xFF9b101a)
                                              : const Color(0xFF1a1a1a),
                                        ),
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Text(
                                            producto['sku'],
                                            style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    Colors.grey.shade500),
                                          ),
                                          if (producto['supergrupo'] !=
                                                  null &&
                                              producto['supergrupo']
                                                  .toString()
                                                  .isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 1),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                        0xFFe8a042)
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        4),
                                              ),
                                              child: Text(
                                                producto['supergrupo'],
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFFe8a042),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      trailing: seleccionado
                                          ? const CircleAvatar(
                                              radius: 12,
                                              backgroundColor:
                                                  Color(0xFFde2924),
                                              child: Icon(Icons.check,
                                                  color: Colors.white,
                                                  size: 14),
                                            )
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          productoSeleccionado =
                                              producto['nombre_producto'];
                                          skuSeleccionado = producto['sku'];
                                          if (producto['unidad'] != null &&
                                              producto['unidad']
                                                  .toString()
                                                  .isNotEmpty) {
                                            unidadSeleccionada =
                                                producto['unidad'];
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Chip producto seleccionado
                            if (productoSeleccionado != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFde2924)
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFde2924)
                                          .withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: Color(0xFFde2924), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        productoSeleccionado!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF9b101a),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Cantidad y Unidad en fila
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _SectionLabel(
                                          label: "Cantidad *"),
                                      const SizedBox(height: 8),
                                      _InputBox(
                                        child: TextField(
                                          controller: cantidadController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            hintText: "0",
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _SectionLabel(label: "Unidad *"),
                                      const SizedBox(height: 8),
                                      _InputBox(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: unidadSeleccionada,
                                            isExpanded: true,
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16),
                                            items: [
                                              "Pieza",
                                              "Caja",
                                              "Kg",
                                              "Litro"
                                            ]
                                                .map((u) => DropdownMenuItem(
                                                    value: u,
                                                    child: Text(u)))
                                                .toList(),
                                            onChanged: (value) =>
                                                setState(() =>
                                                    unidadSeleccionada =
                                                        value!),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            const _SectionLabel(
                                label: "Observaciones (opcional)"),
                            const SizedBox(height: 8),
                            _InputBox(
                              child: TextField(
                                controller: observacionesController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  hintText: "Escribe una nota...",
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFde2924),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  shadowColor: const Color(0xFFde2924)
                                      .withOpacity(0.4),
                                ),
                                onPressed: agregarProducto,
                                icon: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    color: Colors.white),
                                label: const Text(
                                  "Agregar al pedido",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF9b101a),
                                  side: const BorderSide(
                                      color: Color(0xFF9b101a), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ResumenPedidoScreen(
                                        storeName: storeName),
                                  ),
                                ),
                                icon: const Icon(Icons.receipt_long_rounded),
                                label: Text(
                                  totalItems > 0
                                      ? "Ver resumen ($totalItems productos)"
                                      : "Ver resumen del pedido",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: Color(0xFF444444),
        letterSpacing: 0.3,
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final Widget child;
  const _InputBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
