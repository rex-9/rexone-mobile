// test/design/app_dropdown_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rexone_mobile/design/design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return GetMaterialApp(
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }

  group('AppDropdown', () {
    testWidgets('renders options and selected value correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppDropdown<String>(
            options: const [
              AppDropdownOption(value: 'plan_a', label: 'Plan A'),
              AppDropdownOption(value: 'plan_b', label: 'Plan B'),
            ],
            value: 'plan_a',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Plan A'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });

    testWidgets('triggers onChanged when option is tapped', (tester) async {
      String? selected;

      await tester.pumpWidget(
        buildTestableWidget(
          AppDropdown<String>(
            options: const [
              AppDropdownOption(value: 'plan_a', label: 'Plan A'),
              AppDropdownOption(value: 'plan_b', label: 'Plan B'),
            ],
            value: 'plan_a',
            onChanged: (val) => selected = val,
          ),
        ),
      );

      await tester.tap(find.text('Plan A'));
      await tester.pumpAndSettle();

      expect(find.text('Plan B').last, findsOneWidget);
      await tester.tap(find.text('Plan B').last);
      await tester.pumpAndSettle();

      expect(selected, 'plan_b');
    });

    testWidgets('renders label and error message', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppDropdown<String>(
            label: 'Billing Cycle',
            error: 'Please choose an option',
            options: const [
              AppDropdownOption(value: 'monthly', label: 'Monthly'),
            ],
            value: 'monthly',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Billing Cycle'), findsOneWidget);
      expect(find.text('Please choose an option'), findsOneWidget);
    });

    testWidgets('renders placeholder hint when value is null', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppDropdown<String>(
            hint: 'Select a plan...',
            options: const [
              AppDropdownOption(value: 'monthly', label: 'Monthly'),
            ],
            value: null,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Select a plan...'), findsOneWidget);
    });
  });
}
