import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/legal_texts.dart';
import 'politica_screen.dart';

/// Checkbox "Acepto el aviso de privacidad y los términos" con links.
/// Úsalo en la vista de Activar cuenta y deshabilita el botón de
/// activar hasta que [value] sea true.
///
/// Al activar, manda al backend `politicasVersion: LegalTexts.version`
/// y el servidor guarda la fecha de aceptación con su propio reloj.
class ConsentimientoPoliticas extends StatefulWidget {
  const ConsentimientoPoliticas({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<ConsentimientoPoliticas> createState() => _ConsentimientoPoliticasState();
}

class _ConsentimientoPoliticasState extends State<ConsentimientoPoliticas> {
  late final TapGestureRecognizer _privacyTap;
  late final TapGestureRecognizer _termsTap;

  @override
  void initState() {
    super.initState();
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => PoliticaScreen.open(context, LegalTexts.privacyNotice);
    _termsTap = TapGestureRecognizer()
      ..onTap = () => PoliticaScreen.open(context, LegalTexts.termsOfUse);
  }

  @override
  void dispose() {
    _privacyTap.dispose();
    _termsTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final link = TextStyle(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: widget.value,
          onChanged: (v) => widget.onChanged(v ?? false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'He leído y acepto el '),
                  TextSpan(
                      text: 'Aviso de privacidad',
                      style: link,
                      recognizer: _privacyTap),
                  const TextSpan(text: ' y los '),
                  TextSpan(
                      text: 'Términos y condiciones',
                      style: link,
                      recognizer: _termsTap),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
