import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

const List<String> _monthLabels = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _weekdayLabels = <String>[
  'MO',
  'TU',
  'WE',
  'TH',
  'FR',
  'SA',
  'SU',
];

class AppCalendarMonthly extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDatePressed;

  const AppCalendarMonthly({super.key, this.initialDate, this.onDatePressed});

  //

  @override
  State<AppCalendarMonthly> createState() => _AppCalendarMonthlyState();
}

class _AppCalendarMonthlyState extends State<AppCalendarMonthly> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(covariant AppCalendarMonthly oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate &&
        widget.initialDate != null) {
      _currentDate = widget.initialDate!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LightColor.lightest.color,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: spacing16),
            child: Row(
              children: [
                Text(
                  _monthLabels[_currentDate.month - 1],
                  style: TextStyle(
                    fontSize: h4Size,
                    fontWeight: h4Weight,
                    color: DarkColor.darkest.color,
                  ),
                ),
                const SizedBox(width: spacing4),
                Text(
                  _currentDate.year.toString(),
                  style: TextStyle(
                    fontSize: h4Size,
                    fontWeight: h4Weight,
                    color: DarkColor.darkest.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentDate = DateTime(
                        _currentDate.year,
                        _currentDate.month - 1,
                      );
                    });
                  },
                  icon: Icon(
                    AppIcons.arrowLeft,
                    size: 12,
                    color: DarkColor.lightest.color,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentDate = DateTime(
                        _currentDate.year,
                        _currentDate.month + 1,
                      );
                    });
                  },
                  icon: Icon(
                    AppIcons.arrowRight,
                    size: 12,
                    color: DarkColor.lightest.color,
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
                  color: DarkColor.lightest.color,
                ),
              );
            }),
          ),
          const SizedBox(height: spacing9),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            itemBuilder: (context, index) {
              final firstWeekday = DateTime(
                _currentDate.year,
                _currentDate.month,
                1,
              ).weekday;

              final daysInMonth = DateTime(
                _currentDate.year,
                _currentDate.month + 1,
                0,
              ).day;

              final firstDayOffset = firstWeekday - 1;

              final dayNumber = index - firstDayOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Container(
                  width: 10,
                  height: 10,
                  color: LightColor.lightest.color,
                );
              }

              final now = DateTime.now();
              final isToday =
                  _currentDate.year == now.year &&
                  _currentDate.month == now.month &&
                  dayNumber == now.day;

              return TextButton(
                onPressed: widget.onDatePressed != null
                    ? () {
                        final selectedDate = DateTime(
                          _currentDate.year,
                          _currentDate.month,
                          dayNumber,
                        );
                        widget.onDatePressed!(selectedDate);
                      }
                    : null,
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
                  shape: WidgetStateProperty.all(const CircleBorder()),
                  backgroundColor: WidgetStateProperty.fromMap(
                    <WidgetStatesConstraint, Color?>{
                      WidgetState.hovered: HighlightColor.darkest.color,
                      WidgetState.pressed: HighlightColor.darkest.color,
                      WidgetState.any: isToday ? LightColor.light.color : null,
                    },
                  ),
                  foregroundColor: WidgetStateProperty.fromMap(
                    <WidgetStatesConstraint, Color?>{
                      WidgetState.hovered: LightColor.lightest.color,
                      WidgetState.pressed: LightColor.lightest.color,
                      WidgetState.any: DarkColor.medium.color,
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
  }
}

class AppCalendarWeekly extends StatelessWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDatePressed;

  const AppCalendarWeekly({super.key, this.initialDate, this.onDatePressed});

  @override
  Widget build(BuildContext context) {
    final referenceDate = initialDate ?? DateTime.now();

    final monday = referenceDate.subtract(
      Duration(days: referenceDate.weekday - 1),
    );

    final now = DateTime.now();

    return Container(
      color: LightColor.lightest.color,
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
                    WidgetState.hovered: HighlightColor.darkest.color,
                    WidgetState.pressed: HighlightColor.darkest.color,
                    WidgetState.any: isToday ? LightColor.light.color : null,
                  },
                ),
                foregroundColor: WidgetStateProperty.fromMap(
                  <WidgetStatesConstraint, Color?>{
                    WidgetState.hovered: LightColor.lightest.color,
                    WidgetState.pressed: LightColor.lightest.color,
                    WidgetState.any: DarkColor.medium.color,
                  },
                ),
              ),
              onPressed: onDatePressed != null
                  ? () => onDatePressed!(dayDate)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 0,
                ),
                child: Column(
                  children: [
                    Text(
                      _weekdayLabels[index],
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
