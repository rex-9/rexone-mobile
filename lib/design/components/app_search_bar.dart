// lib/design/components/app_search_bar.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rexone_mobile/design/design.dart';

/// Reusable search input and filter bar component.
///
/// Features:
/// - Search input with search icon, clear button, and optional trailing loading indicator
/// - Built-in debouncing timer (default 350ms) to avoid spamming the backend
/// - Filter trigger button with optional active filter count badge
/// - Universal dropdown filter selector powered by [AppDropdown]
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.hint = 'Search...',
    this.initialQuery = '',
    required this.onSearchChanged,
    this.debounceDuration = const Duration(milliseconds: 350),
    this.isSearching = false,
    this.filterOptions = const [],
    this.selectedFilterId,
    this.onFilterChanged,
    this.filterHint,
    this.onFilterTap,
    this.activeFilterCount = 0,
    this.searchController,
  });

  /// Placeholder hint text for the search input.
  final String hint;

  /// Initial query string.
  final String initialQuery;

  /// Callback invoked when debounced search query changes.
  final Function(String query) onSearchChanged;

  /// Duration to wait after keystrokes before calling [onSearchChanged].
  final Duration debounceDuration;

  /// Whether a search request is actively in-flight (shows trailing spinner).
  final bool isSearching;

  /// Optional list of dropdown options for filtering.
  final List<AppDropdownOption<String>> filterOptions;

  /// The currently selected filter option id, if any.
  final String? selectedFilterId;

  /// Callback invoked when a filter option is selected from dropdown.
  final ValueChanged<String?>? onFilterChanged;

  /// Optional placeholder hint for the filter dropdown.
  final String? filterHint;

  /// Optional callback to open a filter bottom sheet or dialog.
  final VoidCallback? onFilterTap;

  /// Number of active filters to indicate on the filter button badge.
  final int activeFilterCount;

  /// Optional external [TextEditingController].
  final TextEditingController? searchController;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.searchController ??
        TextEditingController(text: widget.initialQuery);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery &&
        _controller.text != widget.initialQuery) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.searchController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearchChanged(_controller.text.trim());
    });
    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasFilterButton = widget.onFilterTap != null;
    final hasDropdown = widget.filterOptions.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row: Search Input + Optional Filter Action Button
        Row(
          children: [
            Expanded(
              child: AppInputField(
                controller: _controller,
                hint: widget.hint,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: colors.textMuted,
                ),
                suffixIcon: widget.isSearching
                    ? Padding(
                        padding: EdgeInsets.all(Design.spacing.sm),
                        child: AppLoading(
                          size: LoadingSize.small,
                          color: colors.primary,
                        ),
                      )
                    : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: colors.textMuted,
                        ),
                        onPressed: _clearSearch,
                        splashRadius: 16,
                      )
                    : null,
              ),
            ),
            if (hasFilterButton) ...[
              SizedBox(width: Design.spacing.sm),
              _buildFilterButton(context),
            ],
          ],
        ),

        // Dropdown Filter Selector
        if (hasDropdown) ...[
          SizedBox(height: Design.spacing.sm),
          AppDropdown<String>(
            options: widget.filterOptions,
            value: widget.selectedFilterId,
            hint: widget.filterHint,
            onChanged: widget.onFilterChanged,
            size: AppDropdownSize.medium,
            fullWidth: true,
          ),
        ],
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    final colors = context.colors;
    final hasActive = widget.activeFilterCount > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: hasActive
                ? colors.primary.withValues(alpha: 0.12)
                : colors.surface,
            borderRadius: BorderRadius.circular(Design.spacing.radiusMedium),
            border: Border.all(
              color: hasActive ? colors.primary : colors.border,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(Design.spacing.radiusMedium),
              onTap: widget.onFilterTap,
              child: Center(
                child: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: hasActive ? colors.primary : colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        if (hasActive)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '${widget.activeFilterCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
