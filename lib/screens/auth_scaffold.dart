import 'package:flutter/material.dart';

/// Fondo y encabezado compartidos por las pantallas de autenticación
/// (Login, y más adelante Activar cuenta / Cambiar contraseña): el mismo
/// degradado rojo de marca con borde inferior curvo, el logo de la app en
/// un círculo blanco con aro amarillo, y una tarjeta que se encima sobre
/// el encabezado para el contenido (formulario).
///
/// Colores de marca (degradado rojo, aro amarillo) se mantienen como
/// constantes fijas a propósito: son identidad visual y no cambian entre
/// temas, igual que en el resto de encabezados de la app (Gestión de
/// Pedidos, Historial, etc). Todo lo demás (tarjeta, sombras, texto del
/// formulario) sale de [Theme.of(context).colorScheme] para funcionar en
/// modo oscuro.
class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBackButton = false,
    this.kicker,
  });

  final String title;
  final String subtitle;

  /// Línea pequeña en mayúsculas arriba del título (p. ej. "OXXO REGIÓN
  /// TABASCO"). Null para no mostrar nada ahí.
  final String? kicker;

  /// Contenido de la tarjeta (formulario).
  final Widget child;

  /// Muestra una flecha para regresar (Navigator.pop) sobre el encabezado,
  /// igual que el AppBar que reemplaza en pantallas a las que se llega
  /// navegando (Activar cuenta, Cambiar contraseña). Login no la usa
  /// porque no hay a dónde regresar.
  final bool showBackButton;

  static const _rojoOscuro = Color(0xFF9b101a);
  static const _rojoClaro = Color(0xFFde2924);
  static const _amarillo = Color(0xFFfde521);

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    children: [
                      _Header(
                        title: widget.title,
                        subtitle: widget.subtitle,
                        showBackButton: widget.showBackButton,
                        kicker: widget.kicker,
                      ),
                      // Transform.translate solo desplaza el pintado: la tarjeta
                      // visualmente se encima 40px sobre el encabezado, pero el
                      // Column sigue reservando su posición original, que queda
                      // como respiro inferior (Container no permite margin negativo).
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                            child: widget.child,
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
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.showBackButton,
    this.kicker,
  });

  final String title;
  final String subtitle;
  final bool showBackButton;
  final String? kicker;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AuthScaffold._rojoOscuro, AuthScaffold._rojoClaro],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
          child: Column(
            children: [
              if (showBackButton) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AuthScaffold._amarillo, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/oxxo-logo-circular.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (kicker != null) ...[
                Text(
                  kicker!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
