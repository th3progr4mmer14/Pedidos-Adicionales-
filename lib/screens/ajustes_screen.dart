import 'package:flutter/material.dart';

import '../models/legal_texts.dart';
import '../models/user_profile.dart';
import '../providers/theme_controller.dart';
import 'mis_datos_screen.dart';
import 'politica_screen.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ---------------- Cuenta ----------------
          const _SectionTitle('Cuenta'),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: const Icon(Icons.person_outline),
              ),
              title: Text(user.fullName,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('No. ${user.employeeNumber} · ${user.store}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => MisDatosScreen.open(context, user),
            ),
          ),

          // ---------------- Apariencia ----------------
          const _SectionTitle('Apariencia'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tema', style: theme.textTheme.titleSmall),
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
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Aviso de privacidad'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      PoliticaScreen.open(context, LegalTexts.privacyNotice),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Términos y condiciones'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => PoliticaScreen.open(context, LegalTexts.termsOfUse),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Mis datos'),
                  subtitle: const Text('Ver la información de tu cuenta'),
                  trailing: const Icon(Icons.chevron_right),
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
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                minimumSize: const Size.fromHeight(48),
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
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a ingresar con tu número de '
            'empleado y contraseña.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (ok == true) await onLogout!();
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
      child: Text(text,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.primary)),
    );
  }
}
