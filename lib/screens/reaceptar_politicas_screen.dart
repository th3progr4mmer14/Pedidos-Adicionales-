import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../models/legal_texts.dart';
import '../providers/auth_provider.dart';
import '../services/api_exception.dart';
import 'consentimiento_politicas.dart';
import 'login_screen.dart';
import 'pantalla_post_login.dart';

/// Pantalla bloqueante: se muestra cuando LegalTexts.version subió después
/// de que el usuario ya había activado su cuenta. No se puede saltar — la
/// única salida sin aceptar es cerrar sesión.
class ReaceptarPoliticasScreen extends StatefulWidget {
  const ReaceptarPoliticasScreen({super.key});

  @override
  State<ReaceptarPoliticasScreen> createState() => _ReaceptarPoliticasScreenState();
}

class _ReaceptarPoliticasScreenState extends State<ReaceptarPoliticasScreen> {
  bool acepto = false;
  bool cargando = false;
  String? error;
  String? mensajeEspera;
  Timer? _esperaTimer;

  @override
  void dispose() {
    _esperaTimer?.cancel();
    super.dispose();
  }

  Future<void> _aceptar() async {
    setState(() {
      cargando = true;
      error = null;
      mensajeEspera = null;
    });

    _esperaTimer = Timer(ApiConfig.avisoServidorDormido, () {
      if (mounted) {
        setState(() => mensajeEspera =
            'Despertando el servidor, esto puede tardar hasta un minuto...');
      }
    });

    try {
      final auth = context.read<AuthProvider>();
      await auth.aceptarPoliticas(LegalTexts.version);
      if (!mounted) return;
      irAPantallaSegunPerfil(context, auth.perfil!);
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.mensaje);
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

  Future<void> _cerrarSesion() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.gavel_rounded,
                    size: 72,
                    color: Color(0xFF9b101a),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Actualizamos nuestro aviso de privacidad',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para seguir usando la app necesitas aceptar la versión '
                    'más reciente del aviso de privacidad y los términos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  ConsentimientoPoliticas(
                    value: acepto,
                    onChanged: cargando ? (_) {} : (v) => setState(() => acepto = v),
                  ),

                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  if (mensajeEspera != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      mensajeEspera!,
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9b101a),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (cargando || !acepto) ? null : _aceptar,
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
                              "Aceptar y continuar",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: cargando ? null : _cerrarSesion,
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
