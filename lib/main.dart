import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/pedido_provider.dart';
import 'screens/InicioScreen.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final authProvider = AuthProvider();
  await authProvider.restaurarSesion();

  FlutterNativeSplash.remove();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: InicioScreen(),
      ),
    );
  }
}
