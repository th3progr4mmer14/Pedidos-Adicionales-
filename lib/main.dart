import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/pedido_provider.dart';
import 'providers/theme_controller.dart';
import 'screens/InicioScreen.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final authProvider = AuthProvider();
  await authProvider.restaurarSesion();
  final themeController = await ThemeController.load();

  FlutterNativeSplash.remove();

  runApp(MyApp(authProvider: authProvider, themeController: themeController));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final ThemeController themeController;

  const MyApp({super.key, required this.authProvider, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeController,
        builder: (context, mode, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const InicioScreen(),
        ),
      ),
    );
  }
}
