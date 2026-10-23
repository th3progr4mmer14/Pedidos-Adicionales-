import 'package:ccv_app/models/perfil.dart';
import 'package:ccv_app/models/sesion.dart';
import 'package:ccv_app/providers/auth_provider.dart';
import 'package:ccv_app/screens/login_screen.dart';
import 'package:ccv_app/services/api_client.dart';
import 'package:ccv_app/services/api_exception.dart';
import 'package:ccv_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeAuthService extends AuthService {
  _FakeAuthService({Future<Sesion> Function(String, String)? login})
      : _login = login,
        super(ApiClient.instance);

  final Future<Sesion> Function(String, String)? _login;

  @override
  Future<Sesion> login(String numeroEmpleado, String password) {
    if (_login != null) return _login(numeroEmpleado, password);
    return Future.value(
      Sesion(
        accessToken: 'token',
        perfil: const Perfil(
          numeroEmpleado: 'E100',
          nombre: 'Ana Perez',
          rol: Rol.colaborador,
          tiendas: [],
        ),
      ),
    );
  }
}

Widget _envolver({AuthService? authService}) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(authService: authService ?? _FakeAuthService()),
    child: const MaterialApp(home: LoginScreen()),
  );
}

Future<void> _pump(WidgetTester tester, Widget widget) async {
  await tester.binding.setSurfaceSize(const Size(400, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(widget);
}

void main() {
  testWidgets('se ve el formulario con los campos y el boton Ingresar', (tester) async {
    await _pump(tester, _envolver());
    await tester.pumpAndSettle();

    expect(find.text('Número de empleado'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Ingresar'), findsOneWidget);
    expect(find.text('Pedidos Regional Tabasco'), findsOneWidget);
    expect(find.text('¿Primera vez? Activa tu cuenta'), findsOneWidget);
  });

  testWidgets('valida que no se pueda entrar con campos vacios', (tester) async {
    await _pump(tester, _envolver());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu número de empleado y contraseña'), findsOneWidget);
  });

  testWidgets('el boton de ojo alterna mostrar/ocultar la contraseña', (tester) async {
    await _pump(tester, _envolver());
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Contraseña'), 'miClave123');

    TextField campoPassword() =>
        tester.widget<TextField>(find.widgetWithText(TextField, 'Contraseña'));

    expect(campoPassword().obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_rounded));
    await tester.pump();

    expect(campoPassword().obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
  });

  testWidgets('muestra el mensaje de error que manda el backend (cuenta bloqueada)', (tester) async {
    await _pump(tester, _envolver(
      authService: _FakeAuthService(
        login: (_, _) async => throw const CuentaBloqueadaException(),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Número de empleado'), 'E100');
    await tester.enterText(find.widgetWithText(TextField, 'Contraseña'), 'miClave123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
    await tester.pumpAndSettle();

    expect(find.text('Tu cuenta está bloqueada temporalmente'), findsOneWidget);
    expect(find.byIcon(Icons.lock_clock_rounded), findsOneWidget);
  });
}
