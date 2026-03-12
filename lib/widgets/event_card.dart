import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../theme/app_theme.dart';

class EventCard extends StatefulWidget {
  final CalendarEvent event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isHovered = false;

  Color get _eventColor {
    final colorMap = {
      '1': const Color(0xFF7986CB),
      '2': const Color(0xFF33B679),
      '3': const Color(0xFF8E24AA),
      '4': const Color(0xFFE67C73),
      '5': const Color(0xFFF6C026),
      '6': const Color(0xFFFF8A65),
      '7': const Color(0xFF039BE5),
      '8': const Color(0xFF616161),
      '9': const Color(0xFF3F51B5),
      '10': const Color(0xFF0B8043),
      '11': const Color(0xFFD50000),
    };
    return colorMap[widget.event.colorId] ?? AppTheme.accentBlue;
  }

  String _formatTime() {
    if (widget.event.allDay == true) return 'Dia inteiro';
    final start = widget.event.start?.effectiveDateTime;
    final end = widget.event.end?.effectiveDateTime;
    if (start == null) return '';
    if (end != null) {
      return '${DateFormat('HH:mm').format(start)} – ${DateFormat('HH:mm').format(end)}';
    }
    return DateFormat('HH:mm').format(start);
  }

  bool get _isNow {
    final now = DateTime.now();
    final start = widget.event.start?.effectiveDateTime;
    final end = widget.event.end?.effectiveDateTime;
    if (start == null || end == null) return false;
    return now.isAfter(start) && now.isBefore(end);
  }

  bool get _isPast {
    final now = DateTime.now();
    final end = widget.event.end?.effectiveDateTime;
    if (end == null) return false;
    return now.isAfter(end);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: _isHovered ? AppTheme.surfaceVariant : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isNow
                ? _eventColor.withOpacity(0.5)
                : _isHovered
                    ? AppTheme.border.withOpacity(0.8)
                    : AppTheme.border,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color bar
                Container(
                  width: 3,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isPast
                        ? _eventColor.withOpacity(0.4)
                        : _eventColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (_isNow)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: _eventColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                'AGORA',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              widget.event.summary,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _isPast
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                                decoration: widget.event.status == 'cancelled'
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            widget.event.allDay == true
                                ? Icons.wb_sunny_outlined
                                : Icons.access_time,
                            size: 11,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (widget.event.location != null) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.place_outlined,
                                size: 11, color: AppTheme.textMuted),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                widget.event.location!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Right side indicators
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.event.hasVideoConference)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.videocam_outlined,
                              size: 14,
                              color: AppTheme.accentBlue.withOpacity(0.8),
                            ),
                          ),
                        if (widget.event.attendees != null &&
                            widget.event.attendees!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 13,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${widget.event.attendees!.length}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.event.isRecurring)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.repeat,
                              size: 13,
                              color: AppTheme.textMuted,
                            ),
                          ),
                      ],
                    ),
                    if (_isHovered)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
