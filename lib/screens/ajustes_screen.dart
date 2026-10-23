import 'package:flutter/material.dart';

import '../models/legal_texts.dart';
import '../models/user_profile.dart';
import '../providers/theme_controller.dart';
import 'mis_datos_screen.dart';
import 'politica_screen.dart';

const _rojoOscuro = Color(0xFF9b101a);
const _rojoClaro = Color(0xFFde2924);

/// Pantalla de Ajustes: tema, mis datos, políticas y cerrar sesión.
class AjustesScreen extends StatelessWidget {
  const AjustesScreen({
    super.key,
    required this.user,
    required this.themeController,
    this.appVersion = '1.0.0',
    this.onLogout,
  });

  final UserProfile user;
  final ThemeController themeController;
  final String appVersion;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          _Encabezado(onBack: () => Navigator.maybePop(context)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                // ---------------- Cuenta ----------------
                const _SectionTitle('Cuenta'),
                _CardSeccion(
                  child: _FilaAjustes(
                    icono: Icons.person_outline_rounded,
                    titulo: user.fullName,
                    subtitulo: 'No. ${user.employeeNumber} · ${user.store}',
                    onTap: () => MisDatosScreen.open(context, user),
                  ),
                ),

                // ---------------- Apariencia ----------------
                const _SectionTitle('Apariencia'),
                _CardSeccion(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _CajaIcono(icono: Icons.dark_mode_outlined),
                            const SizedBox(width: 12),
                            Text('Tema', style: theme.textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: themeController,
                          builder: (context, mode, _) => SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<ThemeMode>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode_outlined),
                                  label: Text('Claro'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode_outlined),
                                  label: Text('Oscuro'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  icon: Icon(Icons.phone_android_outlined),
                                  label: Text('Sistema'),
                                ),
                              ],
                              selected: {mode},
                              onSelectionChanged: (s) =>
                                  themeController.setMode(s.first),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---------------- Legal ----------------
                const _SectionTitle('Privacidad y políticas'),
                _CardSeccion(
                  child: Column(
                    children: [
                      _FilaAjustes(
                        icono: Icons.privacy_tip_outlined,
                        titulo: 'Aviso de privacidad',
                        onTap: () => PoliticaScreen.open(
                          context,
                          LegalTexts.privacyNotice,
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 72,
                        color: scheme.outlineVariant,
                      ),
                      _FilaAjustes(
                        icono: Icons.description_outlined,
                        titulo: 'Términos y condiciones',
                        onTap: () =>
                            PoliticaScreen.open(context, LegalTexts.termsOfUse),
                      ),
                      Divider(
                        height: 1,
                        indent: 72,
                        color: scheme.outlineVariant,
                      ),
                      _FilaAjustes(
                        icono: Icons.badge_outlined,
                        titulo: 'Mis datos',
                        subtitulo: 'Ver la información de tu cuenta',
                        onTap: () => MisDatosScreen.open(context, user),
                      ),
                    ],
                  ),
                ),

                // ---------------- Sesión ----------------
                if (onLogout != null) ...[
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    onPressed: () => _confirmLogout(context),
                  ),
                ],

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'PedidosOXXO v$appVersion · Políticas v${LegalTexts.version}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
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

  Future<void> _confirmLogout(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tendrás que volver a ingresar con tu número de '
          'empleado y contraseña.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (ok == true) await onLogout!();
  }
}

/// Encabezado con el mismo degradado de marca y borde curvo que el resto
/// de la app (Gestión de Pedidos, Historial, etc), para que Ajustes no se
/// vea como una pantalla aparte.
class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_rojoOscuro, _rojoClaro],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack,
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
              const SizedBox(height: 16),
              const Text(
                "Ajustes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Tu cuenta y preferencias",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
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

class _CardSeccion extends StatelessWidget {
  const _CardSeccion({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _CajaIcono extends StatelessWidget {
  const _CajaIcono({required this.icono});

  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final acento = scheme.primary;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: acento.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icono, color: acento, size: 20),
    );
  }
}

class _FilaAjustes extends StatelessWidget {
  const _FilaAjustes({
    required this.icono,
    required this.titulo,
    this.subtitulo,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _CajaIcono(icono: icono),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitulo!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
