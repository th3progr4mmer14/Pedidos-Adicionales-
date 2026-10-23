import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../services/api_exception.dart';
import '../services/politica_password.dart';
import 'auth_scaffold.dart';

const _rojoMarca = Color(0xFF9b101a);

/// Cambio de contraseña voluntario (distinto de la activación de cuenta):
/// el usuario ya tiene sesión y conoce su contraseña actual.
class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final passwordActualController = TextEditingController();
  final passwordNuevaController = TextEditingController();
  final confirmarController = TextEditingController();

  bool cargando = false;
  String? error;
  String? exito;
  String? mensajeEspera;
  Timer? _esperaTimer;

  @override
  void dispose() {
    passwordActualController.dispose();
    passwordNuevaController.dispose();
    confirmarController.dispose();
    _esperaTimer?.cancel();
    super.dispose();
  }

  Future<void> _guardar() async {
    final passwordActual = passwordActualController.text;
    final passwordNueva = passwordNuevaController.text;
    final confirmar = confirmarController.text;

    if (passwordActual.isEmpty || passwordNueva.isEmpty) {
      setState(() {
        error = 'Completa todos los campos';
        exito = null;
      });
      return;
    }
    if (passwordNueva != confirmar) {
      setState(() {
        error = 'Las contraseñas nuevas no coinciden';
        exito = null;
      });
      return;
    }

    final numeroEmpleado =
        context.read<AuthProvider>().perfil?.numeroEmpleado ?? '';
    final errorPolitica = PoliticaPassword.validar(
      passwordNueva,
      numeroEmpleado,
    );
    if (errorPolitica != null) {
      setState(() {
        error = errorPolitica;
        exito = null;
      });
      return;
    }

    setState(() {
      cargando = true;
      error = null;
      exito = null;
      mensajeEspera = null;
    });

    _esperaTimer = Timer(ApiConfig.avisoServidorDormido, () {
      if (mounted) {
        setState(
          () => mensajeEspera =
              'Despertando el servidor, esto puede tardar hasta un minuto...',
        );
      }
    });

    try {
      await context.read<AuthProvider>().cambiarPassword(
        passwordActual: passwordActual,
        passwordNueva: passwordNueva,
      );
      if (!mounted) return;
      setState(() {
        exito = 'Contraseña actualizada';
        passwordActualController.clear();
        passwordNuevaController.clear();
        confirmarController.clear();
      });
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AuthScaffold(
      title: "Cambiar contraseña",
      subtitle: "Actualiza tu acceso",
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: passwordActualController,
            enabled: !cargando,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Contraseña actual",
              prefixIcon: const Icon(Icons.lock_outline),
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordNuevaController,
            enabled: !cargando,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Contraseña nueva",
              prefixIcon: const Icon(Icons.lock_outline),
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: confirmarController,
            enabled: !cargando,
            obscureText: true,
            onSubmitted: (_) => _guardar(),
            decoration: InputDecoration(
              hintText: "Confirmar contraseña nueva",
              prefixIcon: const Icon(Icons.lock_outline),
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            'Mínimo 10 caracteres, con mayúscula, minúscula y número. '
            'No puede contener tu número de empleado.',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),

          if (error != null) ...[
            const SizedBox(height: 16),
            Text(
              error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],

          if (exito != null) ...[
            const SizedBox(height: 16),
            Text(
              exito!,
              style: const TextStyle(color: Colors.green, fontSize: 13),
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

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _rojoMarca,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: cargando ? null : _guardar,
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
                      "Guardar",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
