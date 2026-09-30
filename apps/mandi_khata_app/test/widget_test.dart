import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/main.dart';

void main() {
  testWidgets('shows the app name and sync status', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MandiKhataApp()));
    await tester.pump();

    expect(find.text('Mandi Khata'), findsOneWidget);
    // Tests run without .env.dev, so sync is not configured.
    expect(find.text('Sync off'), findsOneWidget);
  });
}
