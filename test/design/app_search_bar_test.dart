// test/design/app_search_filter_bar_test.dart
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

  group('AppSearchBar', () {
    testWidgets('renders search input with hint and search icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppSearchBar(hint: 'Search products...', onSearchChanged: (_) {}),
        ),
      );

      expect(find.text('Search products...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('debounces search input changes', (tester) async {
      String lastQuery = '';

      await tester.pumpWidget(
        buildTestableWidget(
          AppSearchBar(
            debounceDuration: const Duration(milliseconds: 200),
            onSearchChanged: (query) => lastQuery = query,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Pro');
      // Before debounce duration: callback should not have fired yet
      await tester.pump(const Duration(milliseconds: 100));
      expect(lastQuery, '');

      // After debounce duration: callback should fire
      await tester.pump(const Duration(milliseconds: 150));
      expect(lastQuery, 'Pro');
    });

    testWidgets('clears text and notifies when clear icon is pressed', (
      tester,
    ) async {
      String lastQuery = '';

      await tester.pumpWidget(
        buildTestableWidget(
          AppSearchBar(
            initialQuery: 'Initial',
            onSearchChanged: (query) => lastQuery = query,
          ),
        ),
      );

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(find.text('Initial'), findsNothing);
      expect(lastQuery, '');
    });

    testWidgets(
      'renders filter button with badge and triggers callback on tap',
      (tester) async {
        bool filterTapped = false;

        await tester.pumpWidget(
          buildTestableWidget(
            AppSearchBar(
              onSearchChanged: (_) {},
              onFilterTap: () => filterTapped = true,
              activeFilterCount: 3,
            ),
          ),
        );

        expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
        expect(find.text('3'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.tune_rounded));
        await tester.pump();

        expect(filterTapped, isTrue);
      },
    );

    testWidgets('renders dropdown filter and triggers onFilterChanged', (
      tester,
    ) async {
      String? selectedId;

      await tester.pumpWidget(
        buildTestableWidget(
          AppSearchBar(
            onSearchChanged: (_) {},
            selectedFilterId: 'monthly',
            filterOptions: const [
              AppDropdownOption(value: 'all', label: 'All Plans'),
              AppDropdownOption(value: 'monthly', label: 'Monthly'),
              AppDropdownOption(value: 'yearly', label: 'Yearly'),
            ],
            onFilterChanged: (id) => selectedId = id,
          ),
        ),
      );

      expect(find.byType(AppDropdown<String>), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);

      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      expect(find.text('Yearly').last, findsOneWidget);
      await tester.tap(find.text('Yearly').last);
      await tester.pumpAndSettle();

      expect(selectedId, 'yearly');
    });

    testWidgets('shows loading spinner when isSearching is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppSearchBar(isSearching: true, onSearchChanged: (_) {}),
        ),
      );

      expect(find.byType(AppLoading), findsOneWidget);
    });
  });
}
