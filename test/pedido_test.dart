import 'package:flutter_test/flutter_test.dart';
import 'package:ccv_app/services/pedido_utils.dart';

void main() {

  test('Lista vacía', () {
    expect(calcularTotalPiezas([]), 0);
  });

  test('Un solo elemento', () {
    expect(calcularTotalPiezas([5]), 5);
  });

  test('Varios elementos', () {
    expect(calcularTotalPiezas([5,3,2]), 10);
  });

  test('Tres elementos grandes', () {
    expect(calcularTotalPiezas([10,10,10]), 30);
  });

}