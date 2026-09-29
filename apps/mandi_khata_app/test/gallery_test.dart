import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandi_khata_app/features/dev_gallery/presentation/gallery_screen.dart';
import 'package:mk_ui/mk_ui.dart';

void main() {
  // Renders every mk_ui widget at each shell breakpoint; any layout overflow
  // fails the test.
  for (final (name, width) in [
    ('desktop', 1440.0),
    ('tablet', 800.0),
    ('phone', 390.0),
  ]) {
    testWidgets('gallery renders without overflow on $name', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(theme: MkTheme.light(), home: const GalleryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MkAppShell), findsOneWidget);
      expect(find.text('Design gallery'), findsOneWidget);

      // Scroll to the last section so every section gets laid out.
      await tester.scrollUntilVisible(
        find.text('No farmers yet'),
        400,
        scrollable: find
            .descendant(
              of: find.byKey(GalleryScreen.listKey),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text('No farmers yet'), findsOneWidget);
    });
  }
}
