import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../services/api_exception.dart';
import '../services/politica_password.dart';
import 'select_store_screen.dart';

/// Pantalla de activación de cuenta: cambia la contraseña temporal que dio
/// el administrador por una propia. Se llega aquí cuando /auth/login
/// responde 428 (cuenta pendiente de activación).
class ActivarCuentaScreen extends StatefulWidget {
  final String numeroEmpleado;

  const ActivarCuentaScreen({super.key, required this.numeroEmpleado});

  @override
  State<ActivarCuentaScreen> createState() => _ActivarCuentaScreenState();
}

class _ActivarCuentaScreenState extends State<ActivarCuentaScreen> {
  final passwordTemporalController = TextEditingController();
  final passwordNuevaController = TextEditingController();
  final confirmarController = TextEditingController();

  bool cargando = false;
  String? error;
  String? mensajeEspera;
  Timer? _esperaTimer;

  @override
  void dispose() {
    passwordTemporalController.dispose();
    passwordNuevaController.dispose();
    confirmarController.dispose();
    _esperaTimer?.cancel();
    super.dispose();
  }

  Future<void> _activar() async {
    final passwordTemporal = passwordTemporalController.text;
    final passwordNueva = passwordNuevaController.text;
    final confirmar = confirmarController.text;

    if (passwordTemporal.isEmpty || passwordNueva.isEmpty) {
      setState(() => error = 'Completa todos los campos');
      return;
    }
    if (passwordNueva != confirmar) {
      setState(() => error = 'Las contraseñas nuevas no coinciden');
      return;
    }
    final errorPolitica = PoliticaPassword.validar(passwordNueva, widget.numeroEmpleado);
    if (errorPolitica != null) {
      setState(() => error = errorPolitica);
      return;
    }

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
      await context.read<AuthProvider>().activar(
            numeroEmpleado: widget.numeroEmpleado,
            passwordTemporal: passwordTemporal,
            passwordNueva: passwordNueva,
          );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SelectStoreScreen()),
        (route) => false,
      );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Activar cuenta'),
        backgroundColor: const Color(0xFF9b101a),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_open_rounded,
                size: 80,
                color: Color(0xFF9b101a),
              ),
              const SizedBox(height: 16),
              Text(
                'Hola ${widget.numeroEmpleado}, tu contraseña es temporal.\n'
                'Crea una nueva para activar tu cuenta.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: passwordTemporalController,
                enabled: !cargando,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Contraseña temporal",
                  prefixIcon: const Icon(Icons.lock_clock_outlined),
                  filled: true,
                  fillColor: Colors.white,
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
                  fillColor: Colors.white,
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
                onSubmitted: (_) => _activar(),
                decoration: InputDecoration(
                  hintText: "Confirmar contraseña nueva",
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
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
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 30),

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
                  onPressed: cargando ? null : _activar,
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
                          "Activar cuenta",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
