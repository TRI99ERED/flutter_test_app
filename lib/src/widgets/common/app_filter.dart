import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/widgets/common/app_accordion.dart';
import 'package:test_app/src/widgets/common/app_badge.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_tag.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AppFilter extends StatelessWidget {
  final bool showIcon;
  final int filteredItemCount;
  final VoidCallback? onPressed;

  const AppFilter({
    super.key,
    this.showIcon = true,
    this.filteredItemCount = 0,
    this.onPressed,
  }) : assert(
         filteredItemCount >= 0,
         'filteredItemCount must be greater than or equal to 0',
       );

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                Theme.of(
                  context,
                ).extension<AppTheme>()?.backgroundWeakestColor ??
                Color(0xFFC5C6CC),
            width: 0.5,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon)
            Icon(
              AppIcons.filter,
              size: 12,
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.backgroundWeakestColor,
            ),
          if (showIcon) SizedBox(width: spacing8),
          Text(
            context.l10n.filterTitle,
            style: TextStyle(
              fontSize: bSSize,
              fontWeight: bSWeight,
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.foregroundStrongestColor,
            ),
          ),
          SizedBox(width: spacing12),
          if (filteredItemCount == 0)
            Icon(
              AppIcons.arrowDown,
              size: 10,
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.backgroundWeakestColor,
            ),
          if (filteredItemCount > 0)
            AppBadgeSymbol(symbol: filteredItemCount.toString(), size: 20),
        ],
      ),
    );
  }
}

class AppFilterMenu extends StatefulWidget {
  final ValueNotifier<Map<String, Set<String>>> filters;
  final Map<MapEntry<String, String>, Map<String, String>> filterOptions;

  const AppFilterMenu({
    super.key,
    required this.filters,
    required this.filterOptions,
  });

  static void show(
    BuildContext context, {
    required ValueNotifier<Map<String, Set<String>>> filters,
    required Map<MapEntry<String, String>, Map<String, String>> filterOptions,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(216),
      builder: (context) {
        return AppFilterMenu(filters: filters, filterOptions: filterOptions);
      },
    );
  }

  @override
  State<AppFilterMenu> createState() => _AppFilterMenuState();
}

class _AppFilterMenuState extends State<AppFilterMenu> {
  final ValueNotifier<Map<String, Set<String>>> _internalFilters =
      ValueNotifier<Map<String, Set<String>>>({});

  @override
  void initState() {
    super.initState();
    _internalFilters.value = widget.filters.value.map(
      (k, v) => MapEntry(k, Set<String>.from(v)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(
        title: context.l10n.filterTitle,
        leftText: context.l10n.cancelLabel,
        rightText: context.l10n.clearAllLabel,
        onPressedLeft: () {
          context.pop();
        },
        onPressedRight: () {
          _internalFilters.value = widget.filterOptions.map(
            (k, v) => MapEntry(k.key, <String>{}),
          );
        },
      ),
      body: Container(
        color: Theme.of(
          context,
        ).extension<AppTheme>()?.backgroundStrongestColor,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing24,
        ),
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _internalFilters,
                builder: (context, value, child) {
                  return ListView.builder(
                    itemCount: widget.filterOptions.length,
                    itemBuilder: (context, index) {
                      MapEntry<String, String> entry = widget.filterOptions.keys
                          .elementAt(index);
                      String name = entry.value;
                      Set<String> options = widget.filterOptions[entry]!.keys
                          .toSet();
                      final labelMap = widget.filterOptions[entry];
                      return AppAccordion(
                        title: name,
                        selectedCount:
                            _internalFilters.value[name]?.length ?? 0,
                        children: [
                          Wrap(
                            spacing: spacing8,
                            runSpacing: spacing8,
                            children: options.map((option) {
                              final isSelected =
                                  _internalFilters.value[name]?.contains(
                                    option,
                                  ) ??
                                  false;
                              final displayText = labelMap != null
                                  ? (labelMap[option] ?? option)
                                  : option;
                              return AppTag(
                                text: displayText.toUpperCase(),
                                isSelected: isSelected,
                                onChanged: (selected) {
                                  final newFilters = _internalFilters.value.map(
                                    (k, v) => MapEntry(k, Set<String>.from(v)),
                                  );
                                  if (selected) {
                                    newFilters[name] = Set<String>.from(
                                      newFilters[name] ?? {},
                                    )..add(option);
                                  } else {
                                    final updatedSet = Set<String>.from(
                                      newFilters[name] ?? {},
                                    );
                                    updatedSet.remove(option);
                                    newFilters[name] = updatedSet;
                                  }
                                  _internalFilters.value = newFilters;
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(spacing24),
              child: SizedBox(
                width: double.infinity,
                child: AppButtonPrimary(
                  text: context.l10n.applyFiltersLabel,
                  onPressed: () {
                    // Deep copy to avoid mutating original sets
                    widget.filters.value = _internalFilters.value.map(
                      (k, v) => MapEntry(k, Set<String>.from(v)),
                    );
                    context.pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _internalFilters.dispose();
    super.dispose();
  }
}
