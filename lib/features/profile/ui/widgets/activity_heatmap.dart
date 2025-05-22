import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/activity_data.dart';
import '../../../../core/theme/theme_provider.dart';

class ActivityHeatmap extends StatelessWidget {
  final List<ActivityData> activityData;
  final int months;
  final Function(DateTime)? onDayTapped;

  const ActivityHeatmap({
    super.key,
    required this.activityData,
    this.months = 5,
    this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month - months + 1, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Activity Heatmap',
            style: theme.textStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [ _HeatmapLegend(isDark: theme.isDarkMode) ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _buildMonthsGrid(startDate, today, theme),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMonthsGrid(DateTime start, DateTime end, ThemeProvider theme) {
    final monthsWidgets = <Widget>[];
    DateTime cursor = DateTime(start.year, start.month, 1);

    while (cursor.isBefore(DateTime(end.year, end.month + 1, 1))) {
      monthsWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  DateFormat('MMM yyyy').format(cursor),
                  style: theme.textStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              _MonthGrid(
                month: cursor.month,
                year: cursor.year,
                activityData: activityData,
                onDayTapped: onDayTapped,
                isDark: theme.isDarkMode,
              ),
            ],
          ),
        ),
      );
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }

    return monthsWidgets;
  }
}

class _MonthGrid extends StatelessWidget {
  final int month;
  final int year;
  final List<ActivityData> activityData;
  final Function(DateTime)? onDayTapped;
  final bool isDark;

  const _MonthGrid({
    required this.month,
    required this.year,
    required this.activityData,
    required this.isDark,
    this.onDayTapped,
  });

  String _unicodeSuffix(int day) {
    if (day >= 11 && day <= 13) return 'ᵗʰ';
    switch (day % 10) {
      case 1:
        return 'ˢᵗ';
      case 2:
        return 'ⁿᵈ';
      case 3:
        return 'ʳᵈ';
      default:
        return 'ᵗʰ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday;
    final rows = ((daysInMonth + firstWeekday - 1) / 7).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _WeekdayLabel(label: 'M'),
            _WeekdayLabel(label: 'T'),
            _WeekdayLabel(label: 'W'),
            _WeekdayLabel(label: 'T'),
            _WeekdayLabel(label: 'F'),
            _WeekdayLabel(label: 'S'),
            _WeekdayLabel(label: 'S'),
          ],
        ),
        for (int week = 0; week < rows; week++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int weekday = 1; weekday <= 7; weekday++)
                _buildDayCell(week, weekday, firstWeekday, daysInMonth),
            ],
          ),
      ],
    );
  }

  Widget _buildDayCell(int week, int weekday, int firstWeekday, int daysInMonth) {
    final day = week * 7 + weekday - (firstWeekday - 1);
    final isValid = day > 0 && day <= daysInMonth;

    if (!isValid) {
      return Container(width: 18, height: 18, margin: const EdgeInsets.all(1));
    }

    final date = DateTime(year, month, day);
    final level = _getLevelForDate(date);
    final isToday = _isToday(date);

    return GestureDetector(
      onTap: () => onDayTapped?.call(date),
      child: Container(
        width: 18,
        height: 18,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _colorForLevel(level),
          borderRadius: BorderRadius.circular(3),
          border: isToday ? Border.all(color: Colors.blueAccent, width: 1) : null,
        ),
        child: level == 0
            ? null
            : Center(
                child: Text.rich(
                  TextSpan(
                    text: '$day',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: level > 2
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    children: [
                      TextSpan(text: _unicodeSuffix(day)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  int _getLevelForDate(DateTime date) {
    var count = 0;
    for (var act in activityData) {
      if (act.date.year == date.year &&
          act.date.month == date.month &&
          act.date.day == date.day) {
        count += act.count;
      }
    }
    if (count == 0) return 0;
    if (count <= 2) return 1;
    if (count <= 5) return 2;
    if (count <= 10) return 3;
    return 4;
  }

  Color _colorForLevel(int level) {
    final darkPalette = [Colors.white10, Color(0xFF2F3E46), Color(0xFF52796F), Color(0xFF84A98C), Color(0xFFA8DADC)];
    final lightPalette = [Colors.grey.shade200, Color(0xFFD6ECD2), Color(0xFF99D492), Color(0xFF529471), Color(0xFF256D46)];
    final palette = isDark ? darkPalette : lightPalette;
    return palette[level];
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return SizedBox(
      width: 20,
      height: 18,
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 10, color: theme.isDarkMode ? Colors.white54 : Colors.grey.shade600),
        ),
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  final bool isDark;
  const _HeatmapLegend({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final colors = isDark
        ? [Color(0xFF2F3E46), Color(0xFF52796F), Color(0xFF84A98C), Color(0xFFA8DADC)]
        : [Color(0xFFD6ECD2), Color(0xFF99D492), Color(0xFF529471), Color(0xFF256D46)];

    return Row(
      children: [
        Text('Less', style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.grey)),
        const SizedBox(width: 4),
        for (final c in colors) _legendBox(c),
        const SizedBox(width: 4),
        Text('More', style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.grey)),
      ],
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }
}
