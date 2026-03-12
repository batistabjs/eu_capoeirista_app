import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../theme/app_theme.dart';

class EventDetailScreen extends StatelessWidget {
  final CalendarEvent event;
  final String calendarId;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.calendarId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildTimeCard(),
                if (event.location != null) ...[
                  const SizedBox(height: 12),
                  _buildLocationCard(),
                ],
                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDescriptionCard(),
                ],
                if (event.hasVideoConference) ...[
                  const SizedBox(height: 12),
                  _buildVideoConferenceCard(context),
                ],
                if (event.attendees != null &&
                    event.attendees!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildAttendeesCard(),
                ],
                const SizedBox(height: 12),
                _buildMetaCard(),
                if (event.reminders != null) ...[
                  const SizedBox(height: 12),
                  _buildRemindersCard(),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Detalhes do Evento',
        style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppTheme.border),
      ),
      actions: [
        if (event.htmlLink != null)
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 18, color: AppTheme.textSecondary),
            tooltip: 'Abrir no Google Calendar',
            onPressed: () {
              // URL launcher
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color indicator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: _getEventColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.summary,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontFamily: 'Georgia',
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _StatusBadge(status: event.status ?? 'confirmed'),
                        if (event.isRecurring)
                          _TagBadge(
                            icon: Icons.repeat,
                            label: 'Recorrente',
                          ),
                        if (event.allDay == true)
                          _TagBadge(
                            icon: Icons.wb_sunny_outlined,
                            label: 'Dia inteiro',
                          ),
                        if (event.hasVideoConference)
                          _TagBadge(
                            icon: Icons.videocam_outlined,
                            label: 'Google Meet',
                            color: AppTheme.accentBlue,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    final start = event.start?.effectiveDateTime;
    final end = event.end?.effectiveDateTime;

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(icon: Icons.schedule_outlined, label: 'Horário'),
          const SizedBox(height: 12),
          if (event.allDay == true)
            _buildAllDayTime()
          else
            _buildTimedEvent(start, end),
          if (event.start?.timeZone != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.language, size: 13, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  event.start!.timeZone!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllDayTime() {
    final start = event.start?.effectiveDateTime;
    final end = event.end?.effectiveDateTime;

    if (start == null) return const SizedBox();

    String dateText;
    if (end != null && !_isSameDay(start, end.subtract(const Duration(days: 1)))) {
      final endDisplay = end.subtract(const Duration(days: 1));
      dateText =
          '${DateFormat('EEEE, d MMMM yyyy', 'pt_BR').format(start)} → ${DateFormat('EEEE, d MMMM yyyy', 'pt_BR').format(endDisplay)}';
    } else {
      dateText = DateFormat('EEEE, d MMMM yyyy', 'pt_BR').format(start);
    }

    return Row(
      children: [
        const Icon(Icons.wb_sunny_outlined, size: 16, color: AppTheme.accentOrange),
        const SizedBox(width: 8),
        Text(
          dateText,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimedEvent(DateTime? start, DateTime? end) {
    if (start == null) return const SizedBox();

    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'pt_BR').format(start);
    final startTime = DateFormat('HH:mm').format(start);
    final endTime = end != null ? DateFormat('HH:mm').format(end) : null;

    Duration? duration;
    if (end != null) {
      duration = end.difference(start);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateStr[0].toUpperCase() + dateStr.substring(1),
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: AppTheme.accentBlue),
            const SizedBox(width: 8),
            Text(
              endTime != null ? '$startTime → $endTime' : startTime,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (duration != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(icon: Icons.place_outlined, label: 'Local'),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.location!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 15, color: AppTheme.textSecondary),
                tooltip: 'Copiar endereço',
                onPressed: () => Clipboard.setData(ClipboardData(text: event.location!)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(icon: Icons.notes_outlined, label: 'Descrição'),
          const SizedBox(height: 10),
          Text(
            event.description!,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoConferenceCard(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(icon: Icons.videocam_outlined, label: 'Videoconferência'),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.video_call_outlined,
                  color: AppTheme.accentBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.conferenceData?.conferenceSolution ?? 'Google Meet',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (event.videoLink.isNotEmpty)
                      Text(
                        event.videoLink,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.accentBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  if (event.videoLink.isNotEmpty) {
                    // Launch URL
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('Entrar', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentBlue,
                  side: BorderSide(color: AppTheme.accentBlue.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeesCard() {
    final attendees = event.attendees!;
    final accepted = attendees.where((a) => a.responseStatus == 'accepted').length;
    final declined = attendees.where((a) => a.responseStatus == 'declined').length;
    final pending = attendees.where((a) =>
        a.responseStatus == 'needsAction' || a.responseStatus == 'tentative').length;

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SectionLabel(
                  icon: Icons.people_outline, label: 'Participantes'),
              const Spacer(),
              Text(
                '${attendees.length} total',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Summary row
          Row(
            children: [
              _AttendeeCount(
                  count: accepted, label: 'Aceitaram', color: AppTheme.accent),
              const SizedBox(width: 12),
              _AttendeeCount(
                  count: declined, label: 'Recusaram', color: AppTheme.danger),
              const SizedBox(width: 12),
              _AttendeeCount(
                  count: pending, label: 'Pendente', color: AppTheme.warning),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.border, height: 1),
          const SizedBox(height: 12),
          // Attendee list
          ...attendees.map((attendee) => _AttendeeRow(attendee: attendee)),
        ],
      ),
    );
  }

  Widget _buildMetaCard() {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(icon: Icons.info_outline, label: 'Informações'),
          const SizedBox(height: 12),
          if (event.organizer != null)
            _MetaRow(
              icon: Icons.person_outline,
              label: 'Organizador',
              value: event.organizer!.name,
            ),
          if (event.creator != null)
            _MetaRow(
              icon: Icons.create_outlined,
              label: 'Criado por',
              value: event.creator!.name,
            ),
          if (event.created != null)
            _MetaRow(
              icon: Icons.calendar_today_outlined,
              label: 'Criado em',
              value: DateFormat('d MMM yyyy, HH:mm', 'pt_BR')
                  .format(event.created!),
            ),
          if (event.updated != null)
            _MetaRow(
              icon: Icons.update_outlined,
              label: 'Atualizado em',
              value: DateFormat('d MMM yyyy, HH:mm', 'pt_BR')
                  .format(event.updated!),
            ),
          _MetaRow(
            icon: Icons.tag,
            label: 'ID do evento',
            value: event.id,
            monospace: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersCard() {
    final reminders = event.reminders!;
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(icon: Icons.notifications_outlined, label: 'Lembretes'),
          const SizedBox(height: 10),
          if (reminders.useDefault == true)
            const Text(
              'Usando lembretes padrão do calendário',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            )
          else if (reminders.overrides != null &&
              reminders.overrides!.isNotEmpty)
            ...reminders.overrides!.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      r.method == 'email'
                          ? Icons.email_outlined
                          : Icons.notifications_outlined,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${r.method == 'email' ? 'E-mail' : 'Notificação'} — ${r.formattedTime} antes',
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            )
          else
            const Text(
              'Nenhum lembrete configurado',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
        ],
      ),
    );
  }

  Color _getEventColor() {
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
    return colorMap[event.colorId] ?? AppTheme.accentBlue;
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    if (d.inMinutes % 60 == 0) return '${d.inHours}h';
    return '${d.inHours}h ${d.inMinutes % 60}min';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Shared Widgets ──────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'confirmed':
        color = AppTheme.accent;
        label = 'Confirmado';
        break;
      case 'tentative':
        color = AppTheme.warning;
        label = 'Tentativo';
        break;
      case 'cancelled':
        color = AppTheme.danger;
        label = 'Cancelado';
        break;
      default:
        color = AppTheme.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TagBadge({
    required this.icon,
    required this.label,
    this.color = AppTheme.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}

class _AttendeeCount extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _AttendeeCount(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  final Attendee attendee;

  const _AttendeeRow({required this.attendee});

  Color get _statusColor {
    switch (attendee.responseStatus) {
      case 'accepted':
        return AppTheme.accent;
      case 'declined':
        return AppTheme.danger;
      case 'tentative':
        return AppTheme.warning;
      default:
        return AppTheme.textMuted;
    }
  }

  IconData get _statusIcon {
    switch (attendee.responseStatus) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'declined':
        return Icons.cancel_outlined;
      case 'tentative':
        return Icons.help_outline;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppTheme.surfaceVariant,
            child: Text(
              attendee.name.isNotEmpty ? attendee.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendee.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (attendee.displayName != null && attendee.email != null)
                  Text(
                    attendee.email!,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
              ],
            ),
          ),
          if (attendee.organizer == true)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                'Org.',
                style: TextStyle(fontSize: 10, color: AppTheme.accentBlue),
              ),
            ),
          Icon(_statusIcon, size: 16, color: _statusColor),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool monospace;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                fontFamily: monospace ? 'monospace' : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
