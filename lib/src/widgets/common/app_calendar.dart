import 'package:flutter/material.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AppCalendarMonthly extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateSelected;
  final bool immutable;

  const AppCalendarMonthly({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.immutable = false,
  });

  @override
  State<AppCalendarMonthly> createState() => _AppCalendarMonthlyState();
}

class _AppCalendarMonthlyState extends State<AppCalendarMonthly> {
  late final ValueNotifier<DateTime?> _selectedDate;
  late final ValueNotifier<DateTime> _displayedMonth;

  late final List<String> _monthLabels = <String>[
    context.l10n.janLabel,
    context.l10n.febLabel,
    context.l10n.marLabel,
    context.l10n.aprLabel,
    context.l10n.mayLabel,
    context.l10n.junLabel,
    context.l10n.julLabel,
    context.l10n.augLabel,
    context.l10n.sepLabel,
    context.l10n.octLabel,
    context.l10n.novLabel,
    context.l10n.decLabel,
  ];

  late final List<String> _weekdayLabels = <String>[
    context.l10n.moLabel,
    context.l10n.tuLabel,
    context.l10n.weLabel,
    context.l10n.thLabel,
    context.l10n.frLabel,
    context.l10n.saLabel,
    context.l10n.suLabel,
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = ValueNotifier<DateTime?>(widget.initialDate);
    final now = DateTime.now();
    _displayedMonth = ValueNotifier<DateTime>(
      widget.initialDate != null
          ? DateTime(widget.initialDate!.year, widget.initialDate!.month)
          : DateTime(now.year, now.month),
    );
  }

  @override
  void didUpdateWidget(covariant AppCalendarMonthly oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _selectedDate.value = widget.initialDate;
      if (widget.initialDate != null) {
        _displayedMonth.value = DateTime(
          widget.initialDate!.year,
          widget.initialDate!.month,
        );
      }
    }
  }

  @override
  void dispose() {
    _selectedDate.dispose();
    _displayedMonth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _displayedMonth,
      builder: (context, currentDate, _) {
        return ValueListenableBuilder<DateTime?>(
          valueListenable: _selectedDate,
          builder: (context, selectedDate, _) {
            return Container(
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.backgroundStrongestColor,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: spacing16),
                    child: Row(
                      children: [
                        Text(
                          _monthLabels[currentDate.month - 1],
                          style: TextStyle(
                            fontSize: h4Size,
                            fontWeight: h4Weight,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
                          ),
                        ),
                        const SizedBox(width: spacing4),
                        Text(
                          currentDate.year.toString(),
                          style: TextStyle(
                            fontSize: h4Size,
                            fontWeight: h4Weight,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundStrongestColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed:
                              currentDate.month == 1 && currentDate.year == 1
                              ? null
                              : () {
                                  int newMonth = currentDate.month - 1;
                                  int newYear = currentDate.year;
                                  if (newMonth < 1) {
                                    newMonth = 12;
                                    newYear -= 1;
                                  }
                                  _displayedMonth.value = DateTime(
                                    newYear,
                                    newMonth,
                                  );
                                },
                          icon: Icon(
                            AppIcons.arrowLeft,
                            size: 12,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundWeakestColor,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            int newMonth = currentDate.month + 1;
                            int newYear = currentDate.year;
                            if (newMonth > 12) {
                              newMonth = 1;
                              newYear += 1;
                            }
                            _displayedMonth.value = DateTime(newYear, newMonth);
                          },
                          icon: Icon(
                            AppIcons.arrowRight,
                            size: 12,
                            color: Theme.of(
                              context,
                            ).extension<AppTheme>()?.foregroundWeakestColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) {
                      return Text(
                        _weekdayLabels[index],
                        style: TextStyle(
                          fontSize: cMSize,
                          fontWeight: cMWeight,
                          color: Theme.of(
                            context,
                          ).extension<AppTheme>()?.foregroundWeakestColor,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: spacing9),
                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 42,
                    itemBuilder: (context, index) {
                      final firstWeekday = DateTime(
                        currentDate.year,
                        currentDate.month,
                        1,
                      ).weekday;

                      final daysInMonth = DateTime(
                        currentDate.year,
                        currentDate.month + 1,
                        0,
                      ).day;

                      final firstDayOffset = firstWeekday - 1;

                      final dayNumber = index - firstDayOffset + 1;

                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return Container(
                          width: 10,
                          height: 10,
                          color: Theme.of(
                            context,
                          ).extension<AppTheme>()?.backgroundStrongestColor,
                        );
                      }

                      final now = DateTime.now();
                      final isToday =
                          currentDate.year == now.year &&
                          currentDate.month == now.month &&
                          dayNumber == now.day;
                      final isSelected =
                          selectedDate != null &&
                          selectedDate.year == currentDate.year &&
                          selectedDate.month == currentDate.month &&
                          selectedDate.day == dayNumber;

                      return TextButton(
                        onPressed:
                            widget.onDateSelected != null && !widget.immutable
                            ? () {
                                final selected = DateTime(
                                  currentDate.year,
                                  currentDate.month,
                                  dayNumber,
                                );
                                _selectedDate.value = selected;
                                widget.onDateSelected!(selected);
                              }
                            : null,
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.all(0),
                          ),
                          shape: WidgetStateProperty.all(const CircleBorder()),
                          backgroundColor: WidgetStateProperty.fromMap(
                            <WidgetStatesConstraint, Color?>{
                              WidgetState.hovered: Theme.of(
                                context,
                              ).extension<AppTheme>()?.highlightDarkestColor,
                              WidgetState.pressed: Theme.of(
                                context,
                              ).extension<AppTheme>()?.highlightDarkestColor,
                              WidgetState.any: isSelected
                                  ? Theme.of(context)
                                        .extension<AppTheme>()
                                        ?.highlightDarkestColor
                                  : isToday
                                  ? Theme.of(context)
                                        .extension<AppTheme>()
                                        ?.backgroundStrongColor
                                  : null,
                            },
                          ),
                          foregroundColor: WidgetStateProperty.fromMap(
                            <WidgetStatesConstraint, Color?>{
                              WidgetState.hovered: Theme.of(
                                context,
                              ).extension<AppTheme>()?.backgroundStrongestColor,
                              WidgetState.pressed: Theme.of(
                                context,
                              ).extension<AppTheme>()?.backgroundStrongestColor,
                              WidgetState.any: isSelected
                                  ? Theme.of(context)
                                        .extension<AppTheme>()
                                        ?.backgroundStrongestColor
                                  : Theme.of(context)
                                        .extension<AppTheme>()
                                        ?.foregroundMediumColor,
                            },
                          ),
                        ),
                        child: Text(
                          '$dayNumber',
                          style: const TextStyle(
                            fontSize: h5Size,
                            fontWeight: h5Weight,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AppCalendarWeekly extends StatelessWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateSelected;
  final bool immutable;

  const AppCalendarWeekly({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.immutable = false,
  });

  @override
  Widget build(BuildContext context) {
    final referenceDate = initialDate ?? DateTime.now();

    late final List<String> weekdayLabels = <String>[
      context.l10n.moLabel,
      context.l10n.tuLabel,
      context.l10n.weLabel,
      context.l10n.thLabel,
      context.l10n.frLabel,
      context.l10n.saLabel,
      context.l10n.suLabel,
    ];

    final monday = referenceDate.subtract(
      Duration(days: referenceDate.weekday - 1),
    );

    final now = DateTime.now();

    return Container(
      color: Theme.of(context).extension<AppTheme>()?.backgroundStrongestColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final dayDate = monday.add(Duration(days: index));

          final isToday =
              dayDate.year == now.year &&
              dayDate.month == now.month &&
              dayDate.day == now.day;

          return Expanded(
            child: TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                backgroundColor: WidgetStateProperty.fromMap(
                  <WidgetStatesConstraint, Color?>{
                    WidgetState.hovered: Theme.of(
                      context,
                    ).extension<AppTheme>()?.highlightDarkestColor,
                    WidgetState.pressed: Theme.of(
                      context,
                    ).extension<AppTheme>()?.highlightDarkestColor,
                    WidgetState.any: isToday
                        ? Theme.of(
                            context,
                          ).extension<AppTheme>()?.backgroundStrongColor
                        : null,
                  },
                ),
                foregroundColor: WidgetStateProperty.fromMap(
                  <WidgetStatesConstraint, Color?>{
                    WidgetState.hovered: Theme.of(
                      context,
                    ).extension<AppTheme>()?.backgroundStrongestColor,
                    WidgetState.pressed: Theme.of(
                      context,
                    ).extension<AppTheme>()?.backgroundStrongestColor,
                    WidgetState.any: Theme.of(
                      context,
                    ).extension<AppTheme>()?.foregroundMediumColor,
                  },
                ),
              ),
              onPressed: (onDateSelected != null && !immutable)
                  ? () => onDateSelected!(dayDate)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 0,
                ),
                child: Column(
                  children: [
                    Text(
                      weekdayLabels[index],
                      style: const TextStyle(
                        fontSize: cMSize,
                        fontWeight: cMWeight,
                      ),
                    ),
                    const SizedBox(height: spacing4),
                    Text(
                      '${dayDate.day}',
                      style: const TextStyle(
                        fontSize: h5Size,
                        fontWeight: h5Weight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
