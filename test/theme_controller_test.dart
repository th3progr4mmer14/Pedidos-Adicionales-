import 'package:ccv_app/main.dart';
import 'package:ccv_app/providers/auth_provider.dart';
import 'package:ccv_app/providers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'cambiar el ThemeController de claro a oscuro cambia el Theme de MyApp '
      '(regresion del crash de Provider con ThemeController)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final themeController = await ThemeController.load();
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      MyApp(authProvider: authProvider, themeController: themeController),
    );
    await tester.pumpAndSettle();

    // Theme.of necesita un context DENTRO del árbol de MaterialApp (donde
    // vive el widget Theme que arma con theme/darkTheme/themeMode), no el
    // propio Element de MaterialApp.
    Brightness brilloActual() => Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

    await themeController.setMode(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(brilloActual(), Brightness.light);

    await themeController.setMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(brilloActual(), Brightness.dark);
  });
}
