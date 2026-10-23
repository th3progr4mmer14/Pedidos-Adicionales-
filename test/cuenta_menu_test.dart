import 'package:ccv_app/models/perfil.dart';
import 'package:ccv_app/screens/cuenta_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Perfil _perfil({required List<TiendaResumen> tiendas}) {
  return Perfil(
    numeroEmpleado: 'E100',
    nombre: 'Ana Perez',
    rol: Rol.asesorTienda,
    tiendas: tiendas,
  );
}

const _tienda1 = TiendaResumen(id: 't1', codigo: 'CR001', nombre: 'OXXO Centro', plaza: 'Villahermosa');
const _tienda2 = TiendaResumen(id: 't2', codigo: 'CR002', nombre: 'OXXO Norte', plaza: 'Villahermosa');

Widget _envolver(
  Perfil perfil, {
  String? tiendaActual,
  VoidCallback? onCambiarTienda,
  VoidCallback? onCerrarSesion,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: CuentaMenuBoton(
          perfil: perfil,
          tiendaActual: tiendaActual,
          onAjustes: () {},
          onCambiarPassword: () {},
          onCambiarTienda: onCambiarTienda,
          onCerrarSesion: onCerrarSesion ?? () {},
        ),
      ),
    ),
  );
}

Future<void> _abrirMenu(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.tap(find.byIcon(Icons.more_vert_rounded));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el panel se abre y muestra nombre, rol y tienda actual', (tester) async {
    await tester.pumpWidget(_envolver(_perfil(tiendas: [_tienda1]), tiendaActual: 'OXXO Centro'));
    await _abrirMenu(tester);

    expect(find.text('Ana Perez'), findsOneWidget);
    expect(find.textContaining('Asesor de tienda'), findsOneWidget);
    expect(find.textContaining('OXXO Centro'), findsOneWidget);
    expect(find.text('No. E100'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Cambiar contraseña'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('"Cambiar de tienda" no aparece con una sola tienda', (tester) async {
    await tester.pumpWidget(_envolver(_perfil(tiendas: [_tienda1])));
    await _abrirMenu(tester);

    expect(find.text('Cambiar de tienda'), findsNothing);
  });

  testWidgets('"Cambiar de tienda" aparece con varias tiendas y lo dispara', (tester) async {
    var tocado = false;
    await tester.pumpWidget(
      _envolver(
        _perfil(tiendas: [_tienda1, _tienda2]),
        onCambiarTienda: () => tocado = true,
      ),
    );
    await _abrirMenu(tester);

    expect(find.text('Cambiar de tienda'), findsOneWidget);

    await tester.tap(find.text('Cambiar de tienda'));
    await tester.pumpAndSettle();

    expect(tocado, isTrue);
  });

  testWidgets('cerrar sesión pide confirmacion antes de disparar la accion', (tester) async {
    var cerrado = false;
    await tester.pumpWidget(
      _envolver(_perfil(tiendas: [_tienda1]), onCerrarSesion: () => cerrado = true),
    );
    await _abrirMenu(tester);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    // Pide confirmar: el callback real todavia no se dispara.
    expect(cerrado, isFalse);
    expect(find.text('¿Cerrar sesión?'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Cancelar'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(cerrado, isTrue);
  });

  testWidgets('cancelar en el dialogo no dispara el cierre de sesion', (tester) async {
    var cerrado = false;
    await tester.pumpWidget(
      _envolver(_perfil(tiendas: [_tienda1]), onCerrarSesion: () => cerrado = true),
    );
    await _abrirMenu(tester);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();

    expect(cerrado, isFalse);
  });
}
