import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/perfil.dart';

const _rojoOscuro = Color(0xFF9b101a);
const _rojoClaro = Color(0xFFde2924);

/// Botón de "..." que abre el panel de cuenta ([_mostrarMenuCuenta]): mismo
/// ícono/caja que usaban los encabezados antes de tener este menú, para que
/// el punto de entrada se vea igual en todas las pantallas que lo usan.
class CuentaMenuBoton extends StatelessWidget {
  const CuentaMenuBoton({
    super.key,
    required this.perfil,
    this.tiendaActual,
    required this.onAjustes,
    required this.onCambiarPassword,
    this.onCambiarTienda,
    required this.onCerrarSesion,
  });

  final Perfil perfil;

  /// Tienda sobre la que se está trabajando ahora, si aplica (por ejemplo,
  /// no hay una "tienda actual" mientras el usuario todavía está eligiendo
  /// una en [TiendaScreen]).
  final String? tiendaActual;

  final VoidCallback onAjustes;
  final VoidCallback onCambiarPassword;

  /// Null si el usuario solo tiene una tienda (o ninguna): no tiene sentido
  /// ofrecer "Cambiar de tienda" en ese caso.
  final VoidCallback? onCambiarTienda;

  final VoidCallback onCerrarSesion;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarMenuCuenta(
        context,
        perfil: perfil,
        tiendaActual: tiendaActual,
        onAjustes: onAjustes,
        onCambiarPassword: onCambiarPassword,
        onCambiarTienda: onCambiarTienda,
        onCerrarSesion: onCerrarSesion,
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

/// Punto de quiebre entre el bottom sheet (celular) y el panel flotante
/// anclado al botón (tablet/escritorio), siguiendo el breakpoint "compact"
/// de Material (< 600dp).
const _anchoPantallaAmplia = 600.0;

Future<void> _mostrarMenuCuenta(
  BuildContext context, {
  required Perfil perfil,
  String? tiendaActual,
  required VoidCallback onAjustes,
  required VoidCallback onCambiarPassword,
  VoidCallback? onCambiarTienda,
  required VoidCallback onCerrarSesion,
}) async {
  final scheme = Theme.of(context).colorScheme;

  void elegir(VoidCallback accion) {
    HapticFeedback.selectionClick();
    accion();
  }

  Future<void> confirmarCerrarSesion() async {
    HapticFeedback.selectionClick();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tendrás que volver a ingresar con tu número de empleado y contraseña.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmar == true) onCerrarSesion();
  }

  Widget contenido(BorderRadius radius) {
    return _ContenidoMenuCuenta(
      perfil: perfil,
      tiendaActual: tiendaActual,
      radius: radius,
      onAjustes: () => elegir(onAjustes),
      onCambiarPassword: () => elegir(onCambiarPassword),
      onCambiarTienda: onCambiarTienda == null
          ? null
          : () => elegir(onCambiarTienda),
      onCerrarSesion: confirmarCerrarSesion,
    );
  }

  final anchoPantalla = MediaQuery.sizeOf(context).width;

  if (anchoPantalla >= _anchoPantallaAmplia) {
    final boton = context.findRenderObject() as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final posicion = RelativeRect.fromRect(
      Rect.fromPoints(
        boton.localToGlobal(
          Offset(0, boton.size.height + 8),
          ancestor: overlay,
        ),
        boton.localToGlobal(
          boton.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    await showMenu<void>(
      context: context,
      position: posicion,
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      constraints: const BoxConstraints(maxWidth: 360, minWidth: 320),
      items: [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: contenido(BorderRadius.circular(28)),
        ),
      ],
    );
  } else {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (_) => contenido(
        const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
    );
  }
}

class _ContenidoMenuCuenta extends StatelessWidget {
  const _ContenidoMenuCuenta({
    required this.perfil,
    required this.tiendaActual,
    required this.radius,
    required this.onAjustes,
    required this.onCambiarPassword,
    required this.onCambiarTienda,
    required this.onCerrarSesion,
  });

  final Perfil perfil;
  final String? tiendaActual;
  final BorderRadius radius;
  final VoidCallback onAjustes;
  final VoidCallback onCambiarPassword;
  final VoidCallback? onCambiarTienda;
  final VoidCallback onCerrarSesion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: radius,
      child: Material(
        color: scheme.surface,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CabeceraCuenta(perfil: perfil, tiendaActual: tiendaActual),
              const SizedBox(height: 4),
              _FilaMenuCuenta(
                icono: Icons.settings_outlined,
                titulo: 'Ajustes',
                subtitulo: 'Tema, mis datos y políticas',
                onTap: () {
                  Navigator.pop(context);
                  onAjustes();
                },
              ),
              _FilaMenuCuenta(
                icono: Icons.password_rounded,
                titulo: 'Cambiar contraseña',
                subtitulo: 'Actualiza tu acceso',
                onTap: () {
                  Navigator.pop(context);
                  onCambiarPassword();
                },
              ),
              if (onCambiarTienda != null)
                _FilaMenuCuenta(
                  icono: Icons.storefront_outlined,
                  titulo: 'Cambiar de tienda',
                  subtitulo: 'Elige otra de tus tiendas asignadas',
                  onTap: () {
                    Navigator.pop(context);
                    onCambiarTienda!();
                  },
                ),
              const Divider(height: 1),
              _FilaMenuCuenta(
                icono: Icons.logout_rounded,
                titulo: 'Cerrar sesión',
                colorAcento: scheme.error,
                onTap: () {
                  Navigator.pop(context);
                  onCerrarSesion();
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _CabeceraCuenta extends StatelessWidget {
  const _CabeceraCuenta({required this.perfil, required this.tiendaActual});

  final Perfil perfil;
  final String? tiendaActual;

  String get _iniciales {
    final partes = perfil.nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }

  String get _rolLabel => switch (perfil.rol) {
    Rol.colaborador => 'Colaborador',
    Rol.asesorTienda => 'Asesor de tienda',
    Rol.admin => 'Administrador',
  };

  @override
  Widget build(BuildContext context) {
    final subtitulo = tiendaActual == null || tiendaActual!.isEmpty
        ? _rolLabel
        : '$_rolLabel · $tiendaActual';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_rojoOscuro, _rojoClaro],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(
              _iniciales,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  perfil.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'No. ${perfil.numeroEmpleado}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
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

class _FilaMenuCuenta extends StatelessWidget {
  const _FilaMenuCuenta({
    required this.icono,
    required this.titulo,
    this.subtitulo,
    required this.onTap,
    this.colorAcento,
  });

  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;
  final Color? colorAcento;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final acento = colorAcento ?? scheme.primary;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: acento.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: acento, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: colorAcento ?? scheme.onSurface,
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitulo!,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
