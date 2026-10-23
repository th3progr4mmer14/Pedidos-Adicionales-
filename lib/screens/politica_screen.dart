import 'package:flutter/material.dart';

import '../models/legal_texts.dart';

/// Muestra un documento legal (aviso de privacidad o términos).
class PoliticaScreen extends StatelessWidget {
  const PoliticaScreen({super.key, required this.document});

  final LegalDocument document;

  static Future<void> open(BuildContext context, LegalDocument document) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PoliticaScreen(document: document)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'Última actualización: ${document.updatedAt} · '
              'versión ${LegalTexts.version}',
              style: text.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(document.intro, style: text.bodyLarge),
            for (final section in document.sections) ...[
              const SizedBox(height: 24),
              Text(
                section.title,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              for (final p in section.paragraphs)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 8,
                    left: p.startsWith('•') ? 8 : 0,
                  ),
                  child: Text(p, style: text.bodyMedium?.copyWith(height: 1.45)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
