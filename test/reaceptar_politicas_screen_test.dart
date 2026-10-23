import 'package:ccv_app/models/legal_texts.dart';
import 'package:ccv_app/models/perfil.dart';
import 'package:ccv_app/providers/auth_provider.dart';
import 'package:ccv_app/providers/pedido_provider.dart';
import 'package:ccv_app/screens/pantalla_post_login.dart';
import 'package:ccv_app/screens/pedidos_screen.dart';
import 'package:ccv_app/screens/reaceptar_politicas_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Perfil _perfilConUnaTienda({String? politicasVersion}) {
  return Perfil(
    numeroEmpleado: 'E100',
    nombre: 'Ana Perez',
    rol: Rol.colaborador,
    tiendas: const [
      TiendaResumen(id: 't1', codigo: 'CR001', nombre: 'OXXO Centro', plaza: '10VHT Villahermosa'),
    ],
    politicasVersion: politicasVersion,
  );
}

Widget _envolver(Widget home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => PedidoProvider()),
    ],
    child: MaterialApp(home: home),
  );
}

void main() {
  group('irAPantallaSegunPerfil respeta la version de politicas', () {
    testWidgets('si politicasVersion no coincide con LegalTexts.version, manda a la pantalla bloqueante',
        (tester) async {
      await tester.pumpWidget(_envolver(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => irAPantallaSegunPerfil(
              context,
              _perfilConUnaTienda(politicasVersion: '0.9'),
            ),
            child: const Text('ir'),
          );
        }),
      ));

      await tester.tap(find.text('ir'));
      await tester.pumpAndSettle();

      expect(find.byType(ReaceptarPoliticasScreen), findsOneWidget);
      expect(find.byType(PedidosScreen), findsNothing);
    });

    testWidgets('si politicasVersion ya es la vigente, pasa directo a Pedidos (colaborador con 1 tienda)',
        (tester) async {
      // PedidosScreen asume una pantalla de telefono; el tamaño de prueba por
      // defecto es mas chico y hace que desborde sin que sea un bug real.
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_envolver(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => irAPantallaSegunPerfil(
              context,
              _perfilConUnaTienda(politicasVersion: LegalTexts.version),
            ),
            child: const Text('ir'),
          );
        }),
      ));

      await tester.tap(find.text('ir'));
      await tester.pumpAndSettle();

      expect(find.byType(PedidosScreen), findsOneWidget);
      expect(find.byType(ReaceptarPoliticasScreen), findsNothing);
    });
  });

  group('ReaceptarPoliticasScreen', () {
    testWidgets('no deja aceptar hasta marcar el checkbox, y no tiene boton de regresar',
        (tester) async {
      await tester.pumpWidget(_envolver(const ReaceptarPoliticasScreen()));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Aceptar y continuar'), findsOneWidget);
      final boton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Aceptar y continuar'),
      );
      expect(boton.onPressed, isNull);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final botonTrasMarcar = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Aceptar y continuar'),
      );
      expect(botonTrasMarcar.onPressed, isNotNull);

      // La unica salida sin aceptar es "Cerrar sesión"
      expect(find.widgetWithText(TextButton, 'Cerrar sesión'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(find.byType(AppBar), findsNothing);
    });
  });
}
