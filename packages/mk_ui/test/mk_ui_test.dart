import 'package:flutter_test/flutter_test.dart';
import 'package:mk_ui/mk_ui.dart';

void main() {
  test('brand colours are defined', () {
    expect(MkColors.brand, isNot(MkColors.gold));
  });
}
