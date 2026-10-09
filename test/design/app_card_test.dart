// test/design/app_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rexone_mobile/design/design.dart';

void main() {
  group('AppSpacing Border Radius Tokens', () {
    test('radiusPill and radiusFull are defined distinctly', () {
      expect(Design.spacing.radiusPill, 50.0);
      expect(Design.spacing.radiusFull, 9999.0);
      expect(Design.spacing.radiusLarge, 16.0);
      expect(Design.spacing.radiusMedium, 12.0);
      expect(Design.spacing.radiusSmall, 8.0);
    });
  });

  group('AppCard Component', () {
    testWidgets('renders basic AppCard with child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: AppCard(
              child: const Text('Basic Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Basic Card Content'), findsOneWidget);
      expect(find.byType(AppCard), findsOneWidget);
    });

    testWidgets('renders AppCard with onTap and handles taps', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: const Text('Tappable Card'),
            ),
          ),
        ),
      );

      expect(find.text('Tappable Card'), findsOneWidget);
      await tester.tap(find.text('Tappable Card'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders AppCard.grouped with dividers between items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: AppCard.grouped(
              children: const [
                Text('Item 1'),
                Text('Item 2'),
                Text('Item 3'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);

      // 3 items should have 2 dividers between them
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('renders AppSectionCard with uppercase header and grouped card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: AppSectionCard(
              title: 'Account Settings',
              children: const [
                Text('Profile'),
                Text('Security'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('ACCOUNT SETTINGS'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('renders lit AppCard with glowing accent border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: AppCard(
              isLit: true,
              child: const Text('Lit Card'),
            ),
          ),
        ),
      );

      expect(find.text('Lit Card'), findsOneWidget);
    });
  });
}
