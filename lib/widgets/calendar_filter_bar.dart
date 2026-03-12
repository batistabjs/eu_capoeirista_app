import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../theme/app_theme.dart';

class CalendarFilterBar extends StatelessWidget {
  final List<CalendarInfo> calendars;
  final String? selectedCalendarId;
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<String?> onCalendarChanged;
  final Function(DateTime start, DateTime end) onDateRangeChanged;

  const CalendarFilterBar({
    super.key,
    required this.calendars,
    required this.selectedCalendarId,
    required this.startDate,
    required this.endDate,
    required this.onCalendarChanged,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Row(
        children: [
          // Calendar selector
          Expanded(
            child: _CalendarDropdown(
              calendars: calendars,
              selectedCalendarId: selectedCalendarId,
              onChanged: onCalendarChanged,
            ),
          ),
          const SizedBox(width: 12),
          // Date range presets
          _DateRangeSelector(
            startDate: startDate,
            endDate: endDate,
            onChanged: onDateRangeChanged,
          ),
        ],
      ),
    );
  }
}

class _CalendarDropdown extends StatelessWidget {
  final List<CalendarInfo> calendars;
  final String? selectedCalendarId;
  final ValueChanged<String?> onChanged;

  const _CalendarDropdown({
    required this.calendars,
    required this.selectedCalendarId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (calendars.isEmpty) {
      return const SizedBox(
        height: 36,
        child: Center(
          child: Text(
            'Carregando calendários...',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ),
      );
    }

    final selectedCalendar = calendars.firstWhere(
      (c) => c.id == selectedCalendarId,
      orElse: () => calendars.first,
    );

    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: AppTheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.border),
      ),
      offset: const Offset(0, 40),
      itemBuilder: (context) => calendars
          .map(
            (c) => PopupMenuItem<String>(
              value: c.id,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: c.backgroundColor != null
                          ? Color(int.parse(
                              '0xFF${c.backgroundColor!.replaceAll('#', '')}'))
                          : AppTheme.accentBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c.summary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (c.primary == true)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'Principal',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.accentBlue),
                      ),
                    ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: selectedCalendar.backgroundColor != null
                    ? Color(int.parse(
                        '0xFF${selectedCalendar.backgroundColor!.replaceAll('#', '')}'))
                    : AppTheme.accentBlue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedCalendar.summary,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.expand_more,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime, DateTime) onChanged;

  const _DateRangeSelector({
    required this.startDate,
    required this.endDate,
    required this.onChanged,
  });

  void _showPresets(BuildContext context) {
    final now = DateTime.now();

    final presets = [
      {
        'label': 'Este mês',
        'start': DateTime(now.year, now.month, 1),
        'end': DateTime(now.year, now.month + 1, 0),
      },
      {
        'label': 'Próximos 7 dias',
        'start': now,
        'end': now.add(const Duration(days: 7)),
      },
      {
        'label': 'Próximos 30 dias',
        'start': now,
        'end': now.add(const Duration(days: 30)),
      },
      {
        'label': 'Próximo trimestre',
        'start': DateTime(now.year, now.month, 1),
        'end': DateTime(now.year, now.month + 3, 0),
      },
      {
        'label': 'Este ano',
        'start': DateTime(now.year, 1, 1),
        'end': DateTime(now.year, 12, 31),
      },
    ];

    showMenu<Map<String, dynamic>>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width,
        100,
        16,
        0,
      ),
      color: AppTheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.border),
      ),
      items: presets
          .map(
            (p) => PopupMenuItem<Map<String, dynamic>>(
              value: p,
              child: Text(
                p['label'] as String,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textPrimary),
              ),
            ),
          )
          .toList(),
    ).then((value) {
      if (value != null) {
        onChanged(value['start'] as DateTime, value['end'] as DateTime);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${DateFormat('d MMM', 'pt_BR').format(startDate)} – ${DateFormat('d MMM', 'pt_BR').format(endDate)}';

    return GestureDetector(
      onTap: () => _showPresets(context),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.date_range_outlined,
              size: 14,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              dateText,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.expand_more,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
