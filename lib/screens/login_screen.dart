import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../services/api_exception.dart';
import 'activar_cuenta_screen.dart';
import 'select_store_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final numeroEmpleadoController = TextEditingController();
  final passwordController = TextEditingController();

  bool cargando = false;
  String? error;
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
      setState(() => error = 'Ingresa tu número de empleado y contraseña');
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
      await context.read<AuthProvider>().login(numeroEmpleado, password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelectStoreScreen()),
      );
    } on CuentaPendienteActivacionException {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActivarCuentaScreen(numeroEmpleado: numeroEmpleado),
        ),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.store,
                size: 90,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                "Pedidos Regional Tabasco",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              TextField(
                controller: numeroEmpleadoController,
                enabled: !cargando,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Número de empleado",
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                enabled: !cargando,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _ingresar(),
                decoration: InputDecoration(
                  hintText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
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
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                          style: TextStyle(fontSize: 16),
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
