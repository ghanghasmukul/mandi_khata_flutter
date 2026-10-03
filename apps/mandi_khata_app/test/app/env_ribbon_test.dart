import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/app/env.dart';
import 'package:mandi_khata_app/app/env_ribbon.dart';

void main() {
  const body = Text('body', textDirection: TextDirection.ltr);

  testWidgets('shows a DEV banner and keeps the child when show is true', (
    tester,
  ) async {
    await tester.pumpWidget(const EnvRibbon(show: true, child: body));
    expect(find.byType(Banner), findsOneWidget);
    expect(tester.widget<Banner>(find.byType(Banner)).message, 'DEV');
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('adds nothing when show is false', (tester) async {
    await tester.pumpWidget(const EnvRibbon(show: false, child: body));
    expect(find.byType(Banner), findsNothing);
    expect(find.text('body'), findsOneWidget);
  });

  test('an unconfigured build (no APP_ENV) is not treated as dev', () {
    // Tests run without --dart-define, so appEnv is empty.
    expect(Env.isDev, isFalse);
  });
}
