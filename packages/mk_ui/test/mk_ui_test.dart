import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mk_ui/mk_ui.dart';

Widget _app(Widget child) => MaterialApp(
  theme: MkTheme.light(),
  home: Scaffold(body: child),
);

Future<void> _setWidth(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

const _sections = [
  MkNavSection(
    id: 'mandi',
    title: 'Mandi',
    items: [
      MkNavItem(id: 'dashboard', icon: Icons.dashboard, label: 'Dashboard'),
      MkNavItem(id: 'khata', icon: Icons.book, label: 'Khata', badge: '3'),
    ],
  ),
  MkNavSection(
    id: 'admin',
    title: 'Admin',
    items: [MkNavItem(id: 'settings', icon: Icons.settings, label: 'Settings')],
  ),
];

void main() {
  test('theme carries the brand tokens', () {
    final theme = MkTheme.light();
    expect(theme.colorScheme.primary, MkColors.brand);
    expect(theme.scaffoldBackgroundColor, MkColors.background);
    expect(theme.extension<MkTokens>()!.udhaar, MkColors.udhaar);
    expect(MkTheme.dark().extension<MkTokens>(), isNotNull);
  });

  group('MkMoneyText', () {
    testWidgets('balance shows the amount without sign, coloured by side', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const Column(
            children: [
              MkMoneyText.balance(Money(-15558000)),
              MkMoneyText.balance(Money(110959)),
              MkMoneyText(Money(132800000), compact: true),
            ],
          ),
        ),
      );
      final owes = tester.widget<Text>(find.text('₹1,55,580'));
      final owed = tester.widget<Text>(find.text('₹1,109.59'));
      expect(owes.style!.color, MkColors.udhaar);
      expect(owed.style!.color, MkColors.jama);
      expect(find.text('₹13.28 L'), findsOneWidget);
    });

    testWidgets('balance chip names the side', (tester) async {
      await tester.pumpWidget(
        _app(
          const MkBalanceChip(
            balance: Money(-240000),
            jamaLabel: 'Jama',
            udhaarLabel: 'Udhaar',
          ),
        ),
      );
      expect(find.textContaining('Udhaar'), findsOneWidget);
      expect(find.textContaining('₹2,400'), findsOneWidget);
    });
  });

  group('MkNumberField', () {
    testWidgets('reports paise without going through double', (tester) async {
      int? value;
      await tester.pumpWidget(_app(MkNumberField(onChanged: (v) => value = v)));
      await tester.enterText(find.byType(TextField), '1109.59');
      expect(value, 110959);
      await tester.enterText(find.byType(TextField), '0.1');
      expect(value, 10);
    });

    testWidgets('integer kind reports whole numbers', (tester) async {
      int? value;
      await tester.pumpWidget(
        _app(
          MkNumberField(
            kind: MkNumberKind.integer,
            onChanged: (v) => value = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '42');
      expect(value, 42);
    });

    test('formatter blocks a third decimal and letters', () {
      const f = MkNumberInputFormatter(MkNumberKind.money);
      const old = TextEditingValue(text: '12.34');
      TextEditingValue type(String text) => f.formatEditUpdate(
        old,
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
      );
      expect(type('12.345').text, '12.34');
      expect(type('12.3a').text, '12.34');
      expect(type('12..3').text, '12.34');
      expect(type('1,234.5').text, '1234.5');
    });

    test('integer formatter rejects a decimal point', () {
      const f = MkNumberInputFormatter(MkNumberKind.integer);
      final result = f.formatEditUpdate(
        const TextEditingValue(text: '12'),
        const TextEditingValue(text: '12.'),
      );
      expect(result.text, '12');
    });
  });

  group('MkButton', () {
    testWidgets('fires when enabled, not when busy', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(MkButton(label: 'Save', onPressed: () => taps++)),
      );
      await tester.tap(find.text('Save'));
      expect(taps, 1);

      await tester.pumpWidget(
        _app(MkButton(label: 'Save', busy: true, onPressed: () => taps++)),
      );
      await tester.tap(find.byType(MkButton));
      expect(taps, 1);
    });
  });

  group('MkDataTable', () {
    testWidgets('sorts by a column when its header is tapped', (tester) async {
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            child: MkDataTable<(String, int)>(
              rows: const [('Balwinder', 30), ('Amrik', 10), ('Charan', 20)],
              columns: [
                MkColumn(
                  label: 'Name',
                  cell: (r) => Text(r.$1),
                  sortKey: (r) => r.$1,
                ),
                MkColumn(
                  label: 'Bags',
                  numeric: true,
                  cell: (r) => Text('${r.$2}'),
                  sortKey: (r) => r.$2,
                ),
              ],
            ),
          ),
        ),
      );
      double y(String text) => tester.getTopLeft(find.text(text)).dy;

      // Unsorted: original order.
      expect(y('Balwinder') < y('Amrik'), isTrue);

      await tester.tap(find.text('NAME'));
      await tester.pump();
      expect(y('Amrik') < y('Balwinder'), isTrue);
      expect(y('Balwinder') < y('Charan'), isTrue);

      await tester.tap(find.text('NAME'));
      await tester.pump();
      expect(y('Charan') < y('Amrik'), isTrue);
    });

    testWidgets('shows the empty widget when there are no rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const MkDataTable<String>(
            rows: [],
            columns: [MkColumn(label: 'Name', cell: Text.new)],
            empty: MkEmptyState(title: 'Nothing yet'),
          ),
        ),
      );
      expect(find.text('Nothing yet'), findsOneWidget);
    });
  });

  group('MkAppShell', () {
    Widget shell({VoidCallback? onSearch}) => MaterialApp(
      theme: MkTheme.light(),
      home: MkAppShell(
        appName: 'Mandi Khata',
        sections: _sections,
        selectedId: 'dashboard',
        onSelect: (_) {},
        onSearch: onSearch,
        body: const SizedBox.expand(),
      ),
    );

    testWidgets('full sidebar at 1000 px and above', (tester) async {
      await _setWidth(tester, 1280);
      await tester.pumpWidget(shell());
      expect(find.byType(MkSidebar), findsOneWidget);
      expect(tester.getSize(find.byType(MkSidebar)).width, MkSidebar.width);
      expect(find.text('Khata'), findsOneWidget);
      expect(find.byType(MkBottomNav), findsNothing);
    });

    testWidgets('icon rail between 600 and 999 px', (tester) async {
      await _setWidth(tester, 800);
      await tester.pumpWidget(shell());
      expect(
        tester.getSize(find.byType(MkSidebar)).width,
        MkSidebar.compactWidth,
      );
      expect(find.text('Khata'), findsNothing);
      expect(find.byType(MkBottomNav), findsNothing);
    });

    testWidgets('bottom navigation below 600 px', (tester) async {
      await _setWidth(tester, 400);
      await tester.pumpWidget(shell());
      expect(find.byType(MkSidebar), findsNothing);
      expect(find.byType(MkBottomNav), findsOneWidget);
    });

    testWidgets('sidebar sections collapse', (tester) async {
      await _setWidth(tester, 1280);
      await tester.pumpWidget(shell());
      await tester.tap(find.text('MANDI'));
      await tester.pump();
      expect(find.text('Khata'), findsNothing);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Ctrl+K and Cmd+K open search', (tester) async {
      await _setWidth(tester, 1280);
      var opened = 0;
      await tester.pumpWidget(shell(onSearch: () => opened++));
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(opened, 1);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      expect(opened, 2);
    });
  });

  test('top bar shows the platform shortcut', () {
    expect(MkTopBar.shortcutHint(TargetPlatform.macOS), '⌘K');
    expect(MkTopBar.shortcutHint(TargetPlatform.windows), 'Ctrl K');
  });
}
