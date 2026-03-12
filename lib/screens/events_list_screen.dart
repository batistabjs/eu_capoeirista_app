import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../services/auth_service.dart';
import '../services/calendar_service.dart';
import '../theme/app_theme.dart';
import '../widgets/event_card.dart';
import '../widgets/calendar_filter_bar.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/user_avatar.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final AuthService _authService = AuthService();
  late final CalendarService _calendarService;

  List<CalendarEvent> _events = [];
  List<CalendarInfo> _calendars = [];
  String? _selectedCalendarId;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _nextPageToken;
  String? _searchQuery;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month + 3, 0);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _calendarService = CalendarService(_authService);
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreEvents();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final calendars = await _calendarService.listCalendars();
      setState(() {
        _calendars = calendars;
        if (_selectedCalendarId == null && calendars.isNotEmpty) {
          _selectedCalendarId = 'primary';
        }
      });

      await _loadEvents(reset: true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEvents({bool reset = false}) async {
    if (reset) {
      setState(() {
        _events = [];
        _nextPageToken = null;
        _isLoading = true;
      });
    }

    try {
      final result = await _calendarService.listEvents(
        calendarId: _selectedCalendarId ?? 'primary',
        timeMin: _startDate,
        timeMax: _endDate,
        maxResults: 50,
        pageToken: reset ? null : _nextPageToken,
        query: _searchQuery,
      );

      setState(() {
        if (reset) {
          _events = result.events;
        } else {
          _events.addAll(result.events);
        }
        _nextPageToken = result.nextPageToken;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreEvents() async {
    if (_isLoadingMore || _nextPageToken == null) return;
    setState(() => _isLoadingMore = true);
    await _loadEvents();
  }

  void _onCalendarChanged(String? calendarId) {
    setState(() => _selectedCalendarId = calendarId);
    _loadEvents(reset: true);
  }

  void _onDateRangeChanged(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _loadEvents(reset: true);
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query.isEmpty ? null : query);
    _loadEvents(reset: true);
  }

  Map<String, List<CalendarEvent>> _groupEventsByDate(List<CalendarEvent> events) {
    final grouped = <String, List<CalendarEvent>>{};
    for (final event in events) {
      final date = event.start?.effectiveDateTime;
      if (date == null) continue;
      final key = DateFormat('yyyy-MM-dd').format(date);
      grouped.putIfAbsent(key, () => []).add(event);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          CalendarFilterBar(
            calendars: _calendars,
            selectedCalendarId: _selectedCalendarId,
            startDate: _startDate,
            endDate: _endDate,
            onCalendarChanged: _onCalendarChanged,
            onDateRangeChanged: _onDateRangeChanged,
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _buildSearchBar(),
          ),
          // Events list
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface,
      title: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppTheme.accentBlue, size: 22),
          const SizedBox(width: 10),
          const Text('Meus Compromissos'),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppTheme.border),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppTheme.textSecondary, size: 20),
          onPressed: () => _loadData(),
          tooltip: 'Atualizar',
        ),
        const SizedBox(width: 8),
        UserAvatar(authService: _authService),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: _onSearch,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Pesquisar compromissos...',
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 18),
          suffixIcon: _searchQuery != null
              ? IconButton(
                  icon: const Icon(Icons.close, size: 16, color: AppTheme.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingSkeleton();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_events.isEmpty) {
      return _buildEmpty();
    }

    final grouped = _groupEventsByDate(_events);
    final sortedKeys = grouped.keys.toList()..sort();

    return RefreshIndicator(
      color: AppTheme.accentBlue,
      backgroundColor: AppTheme.surface,
      onRefresh: () => _loadEvents(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        itemCount: sortedKeys.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == sortedKeys.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentBlue,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          final dateKey = sortedKeys[index];
          final dayEvents = grouped[dateKey]!;
          final date = DateTime.parse(dateKey);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(date, dayEvents.length),
              ...dayEvents.map(
                (event) => EventCard(
                  event: event,
                  onTap: () => _openEventDetail(event),
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, int count) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    final isToday = eventDay == today;
    final isTomorrow = eventDay == today.add(const Duration(days: 1));

    String label;
    if (isToday) {
      label = 'Hoje · ${DateFormat('d MMM', 'pt_BR').format(date)}';
    } else if (isTomorrow) {
      label = 'Amanhã · ${DateFormat('d MMM', 'pt_BR').format(date)}';
    } else {
      label = DateFormat('EEEE, d MMMM', 'pt_BR').format(date);
      label = label[0].toUpperCase() + label.substring(1);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          else
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                color: isToday ? AppTheme.accentBlue : AppTheme.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: AppTheme.border,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count evento${count != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.event_busy_outlined,
                color: AppTheme.textMuted,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhum compromisso encontrado',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery != null
                  ? 'Nenhum resultado para "$_searchQuery"'
                  : 'Não há eventos no período selecionado.',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openEventDetail(CalendarEvent event) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EventDetailScreen(
          event: event,
          calendarId: _selectedCalendarId ?? 'primary',
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}
