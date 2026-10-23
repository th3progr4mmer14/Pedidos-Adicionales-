import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../models/legal_texts.dart';
import '../providers/auth_provider.dart';
import '../services/api_exception.dart';
import 'activar_cuenta_screen.dart';
import 'auth_scaffold.dart';
import 'pantalla_post_login.dart';
import 'politica_screen.dart';

const _appVersion = '1.0.0';
const _rojoMarca = Color(0xFF9b101a);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final numeroEmpleadoController = TextEditingController();
  final passwordController = TextEditingController();

  bool cargando = false;
  bool mostrarPassword = false;
  String? error;
  ApiException? errorException;
  String? mensajeEspera;
  Timer? _esperaTimer;

  @override
  void dispose() {
    numeroEmpleadoController.dispose();
    passwordController.dispose();
    _esperaTimer?.cancel();
    super.dispose();
  }

  Future<void> _ingresar() async {
    final numeroEmpleado = numeroEmpleadoController.text.trim();
    final password = passwordController.text;

    if (numeroEmpleado.isEmpty || password.isEmpty) {
      setState(() {
        error = 'Ingresa tu número de empleado y contraseña';
        errorException = null;
      });
      return;
    }

    setState(() {
      cargando = true;
      error = null;
      errorException = null;
      mensajeEspera = null;
    });

    _esperaTimer = Timer(ApiConfig.avisoServidorDormido, () {
      if (mounted) {
        setState(
          () => mensajeEspera =
              'Despertando el servidor, esto puede tardar hasta un par de minutos...',
        );
      }
    });

    try {
      final auth = context.read<AuthProvider>();
      await auth.login(numeroEmpleado, password);
      if (!mounted) return;
      irAPantallaSegunPerfil(context, auth.perfil!);
    } on CuentaPendienteActivacionException {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActivarCuentaScreen(numeroEmpleado: numeroEmpleado),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          error = e.mensaje;
          errorException = e;
        });
      }
    } finally {
      _esperaTimer?.cancel();
      if (mounted) {
        setState(() {
          cargando = false;
          mensajeEspera = null;
        });
      }
    }
  }

  void _irAActivarCuenta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivarCuentaScreen(
          numeroEmpleado: numeroEmpleadoController.text.trim(),
        ),
      ),
    );
  }

  void _verAvisoPrivacidad() {
    PoliticaScreen.open(context, LegalTexts.privacyNotice);
  }

  IconData get _iconoError {
    final e = errorException;
    if (e is CuentaBloqueadaException) return Icons.lock_clock_rounded;
    if (e is LimiteIntentosException) return Icons.hourglass_bottom_rounded;
    return Icons.error_outline_rounded;
  }

  InputDecoration _decoracion(
    ColorScheme scheme, {
    required String hint,
    required IconData icono,
    Widget? sufijo,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icono),
      suffixIcon: sufijo,
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _rojoMarca, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AuthScaffold(
      title: "OXXO Región Tabasco",
      subtitle: "Área de Abasto",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: numeroEmpleadoController,
            enabled: !cargando,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: _decoracion(
              scheme,
              hint: "Número de empleado",
              icono: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            enabled: !cargando,
            obscureText: !mostrarPassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _ingresar(),
            decoration: _decoracion(
              scheme,
              hint: "Contraseña",
              icono: Icons.lock_outline_rounded,
              sufijo: IconButton(
                tooltip: mostrarPassword
                    ? 'Ocultar contraseña'
                    : 'Mostrar contraseña',
                icon: Icon(
                  mostrarPassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
                onPressed: cargando
                    ? null
                    : () => setState(() => mostrarPassword = !mostrarPassword),
              ),
            ),
          ),

          if (error != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_iconoError, color: scheme.onErrorContainer, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: scheme.onErrorContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _rojoMarca,
                foregroundColor: Colors.white,
                disabledBackgroundColor: scheme.onSurface.withValues(
                  alpha: 0.12,
                ),
                disabledForegroundColor: scheme.onSurface.withValues(
                  alpha: 0.38,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                shadowColor: _rojoMarca.withValues(alpha: 0.4),
              ),
              onPressed: cargando ? null : _ingresar,
              child: cargando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      "Ingresar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          if (mensajeEspera != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      mensajeEspera!,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          Center(
            child: TextButton(
              onPressed: cargando ? null : _irAActivarCuenta,
              child: const Text(
                "¿Primera vez? Activa tu cuenta",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Column(
              children: [
                Text(
                  "v$_appVersion",
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                TextButton(
                  onPressed: _verAvisoPrivacidad,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Aviso de privacidad",
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
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
