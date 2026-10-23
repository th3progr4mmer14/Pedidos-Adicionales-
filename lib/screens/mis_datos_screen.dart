import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/legal_texts.dart';
import '../models/user_profile.dart';
import 'politica_screen.dart';

/// "Mis datos": muestra al colaborador qué datos suyos tiene la app
/// y cómo pedir que se corrijan (derecho de acceso/rectificación).
class MisDatosScreen extends StatelessWidget {
  const MisDatosScreen({super.key, required this.user});

  final UserProfile user;

  static Future<void> open(BuildContext context, UserProfile user) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MisDatosScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis datos')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Header(user: user),
          const SizedBox(height: 16),
          _Group(
            title: 'Datos laborales',
            children: [
              _Row(Icons.badge_outlined, 'Número de empleado', user.employeeNumber),
              _Row(Icons.person_outline, 'Nombre', user.fullName),
              _Row(Icons.verified_user_outlined, 'Rol', user.roleLabel),
              _Row(Icons.map_outlined, 'Plaza', user.plaza),
              _Row(Icons.storefront_outlined, 'Tienda', user.store),
              if (user.email != null)
                _Row(Icons.mail_outline, 'Correo', user.email!),
            ],
          ),
          const SizedBox(height: 16),
          _Group(
            title: 'Cuenta',
            children: [
              _Row(Icons.event_available_outlined, 'Cuenta activada',
                  _fmt(user.activatedAt)),
              _Row(
                Icons.gavel_outlined,
                'Políticas aceptadas',
                user.policiesAcceptedVersion == null
                    ? 'Pendiente'
                    : 'Versión ${user.policiesAcceptedVersion} · '
                        '${_fmt(user.policiesAcceptedAt)}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '¿Algún dato está mal?',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Tus datos los carga la empresa. Para corregirlos o ejercer tus '
            'derechos ARCO, escribe a ${LegalTexts.contactEmail} con tu número '
            'de empleado y lo que necesitas cambiar.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copiar correo'),
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: LegalTexts.contactEmail),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Correo copiado')),
                    );
                  }
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                label: const Text('Ver aviso de privacidad'),
                onPressed: () =>
                    PoliticaScreen.open(context, LegalTexts.privacyNotice),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime? d) {
    if (d == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});
  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initials = user.fullName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Text(initials.isEmpty ? '?' : initials,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('${user.roleLabel} · ${user.store}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.primary)),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value.isEmpty ? '—' : value),
      dense: true,
    );
  }
}
