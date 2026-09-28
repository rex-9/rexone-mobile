// test/design/app_avatar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/design/design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return GetMaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('AppAvatar', () {
    testWidgets('renders user initials when name is provided without url', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppAvatar(
            name: 'Rex Naing',
            radius: 30,
          ),
        ),
      );

      expect(find.text('RN'), findsOneWidget);
    });

    testWidgets('renders single initial for single-word name', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppAvatar(
            name: 'Rex',
            radius: 30,
          ),
        ),
      );

      expect(find.text('R'), findsOneWidget);
    });

    testWidgets('renders person icon when name and url are null', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppAvatar(
            radius: 30,
          ),
        ),
      );

      expect(find.byIcon(Design.icons.person), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          AppAvatar(
            name: 'Rex Naing',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(AppAvatar));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
