import 'package:ccv_app/screens/activar_cuenta_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _envolver() {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ActivarCuentaScreen(numeroEmpleado: 'E100'),
            ),
          ),
          child: const Text('ir'),
        );
      },
    ),
  );
}

Future<void> _pump(WidgetTester tester, Widget widget) async {
  // Esta pantalla tiene más contenido (saludo, 3 campos, pista de la
  // política de password, checkbox) que cabe en el tamaño por defecto.
  await tester.binding.setSurfaceSize(const Size(400, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(widget);
}

void main() {
  testWidgets('usa el encabezado de AuthScaffold con el saludo y los campos', (tester) async {
    await _pump(tester, _envolver());
    await tester.tap(find.text('ir'));
    await tester.pumpAndSettle();

    expect(find.text('Define tu nueva contraseña'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Activar cuenta'), findsOneWidget);
    expect(find.textContaining('Hola E100'), findsOneWidget);
    expect(find.text('Contraseña temporal'), findsOneWidget);
    expect(find.text('Contraseña nueva'), findsOneWidget);
    expect(find.text('Confirmar contraseña nueva'), findsOneWidget);
  });

  testWidgets('la flecha de regresar del encabezado hace pop de la pantalla', (tester) async {
    await _pump(tester, _envolver());
    await tester.tap(find.text('ir'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivarCuentaScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(ActivarCuentaScreen), findsNothing);
    expect(find.text('ir'), findsOneWidget);
  });

  testWidgets('valida que no se pueda activar con campos vacios', (tester) async {
    await _pump(tester, _envolver());
    await tester.tap(find.text('ir'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Activar cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Completa todos los campos'), findsOneWidget);
  });
}
