import 'package:ccv_app/screens/cambiar_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _envolver() {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CambiarPasswordScreen()),
          ),
          child: const Text('ir'),
        );
      },
    ),
  );
}

Future<void> _pump(WidgetTester tester, Widget widget) async {
  await tester.binding.setSurfaceSize(const Size(400, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(widget);
}

void main() {
  testWidgets('usa el encabezado de AuthScaffold con los campos de contraseña', (tester) async {
    await _pump(tester, _envolver());
    await tester.tap(find.text('ir'));
    await tester.pumpAndSettle();

    expect(find.text('Cambiar contraseña'), findsOneWidget);
    expect(find.text('Contraseña actual'), findsOneWidget);
    expect(find.text('Contraseña nueva'), findsOneWidget);
    expect(find.text('Confirmar contraseña nueva'), findsOneWidget);
  });

  testWidgets('la flecha de regresar del encabezado hace pop de la pantalla', (tester) async {
    await _pump(tester, _envolver());
    await tester.tap(find.text('ir'));
    await tester.pumpAndSettle();

    expect(find.byType(CambiarPasswordScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(CambiarPasswordScreen), findsNothing);
    expect(find.text('ir'), findsOneWidget);
  });

  testWidgets('valida que no se pueda guardar con campos vacios', (tester) async {
    await _pump(tester, _envolver());
    await tester.tap(find.text('ir'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Completa todos los campos'), findsOneWidget);
  });
}
