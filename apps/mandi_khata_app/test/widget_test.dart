import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/main.dart';

void main() {
  testWidgets('shows the app name', (tester) async {
    await tester.pumpWidget(const MandiKhataApp());

    expect(find.text('Mandi Khata'), findsOneWidget);
  });
}
