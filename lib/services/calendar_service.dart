import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/calendar_event.dart';
import 'auth_service.dart';

class CalendarService {
  static const String _baseUrl = 'https://www.googleapis.com/calendar/v3';
  final AuthService _authService;

  CalendarService(this._authService);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getValidToken();
    if (token == null) throw Exception('Não autenticado');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Lista todos os calendários do usuário
  Future<List<CalendarInfo>> listCalendars() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me/calendarList'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List? ?? [];
        return items.map((item) => CalendarInfo.fromJson(item)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('Error listing calendars: $e');
      rethrow;
    }
  }

  /// Lista eventos de um calendário específico
  Future<EventsResult> listEvents({
    String calendarId = 'primary',
    DateTime? timeMin,
    DateTime? timeMax,
    int maxResults = 50,
    String? pageToken,
    String? query,
    String orderBy = 'startTime',
    bool singleEvents = true,
  }) async {
    try {
      final headers = await _getHeaders();

      final params = <String, String>{
        'maxResults': maxResults.toString(),
        'singleEvents': singleEvents.toString(),
        'orderBy': orderBy,
      };

      if (timeMin != null) {
        params['timeMin'] = timeMin.toUtc().toIso8601String();
      } else {
        // Padrão: eventos a partir do início do mês atual
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        params['timeMin'] = startOfMonth.toUtc().toIso8601String();
      }

      if (timeMax != null) {
        params['timeMax'] = timeMax.toUtc().toIso8601String();
      }

      if (pageToken != null) {
        params['pageToken'] = pageToken;
      }

      if (query != null && query.isNotEmpty) {
        params['q'] = query;
      }

      final uri = Uri.parse('$_baseUrl/calendars/$calendarId/events')
          .replace(queryParameters: params);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List? ?? [];
        final events = items.map((item) => CalendarEvent.fromJson(item)).toList();

        return EventsResult(
          events: events,
          nextPageToken: data['nextPageToken'],
          summary: data['summary'],
          timeZone: data['timeZone'],
        );
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('Error listing events: $e');
      rethrow;
    }
  }

  /// Obtém detalhes de um evento específico
  Future<CalendarEvent> getEvent({
    required String calendarId,
    required String eventId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/calendars/$calendarId/events/$eventId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return CalendarEvent.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      debugPrint('Error getting event: $e');
      rethrow;
    }
  }

  /// Lista eventos de múltiplos calendários combinados
  Future<List<CalendarEvent>> listAllCalendarsEvents({
    DateTime? timeMin,
    DateTime? timeMax,
    int maxResults = 100,
  }) async {
    final calendars = await listCalendars();
    final allEvents = <CalendarEvent>[];

    for (final calendar in calendars) {
      try {
        final result = await listEvents(
          calendarId: calendar.id,
          timeMin: timeMin,
          timeMax: timeMax,
          maxResults: maxResults,
        );
        allEvents.addAll(result.events);
      } catch (e) {
        debugPrint('Could not fetch events from calendar ${calendar.id}: $e');
      }
    }

    // Ordenar por data de início
    allEvents.sort((a, b) {
      final aDate = a.start?.effectiveDateTime;
      final bDate = b.start?.effectiveDateTime;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    return allEvents;
  }

  Exception _handleError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      final error = data['error'];
      final message = error?['message'] ?? 'Erro desconhecido';
      final code = response.statusCode;

      switch (code) {
        case 401:
          return Exception('Não autorizado. Faça login novamente.');
        case 403:
          return Exception('Sem permissão: $message');
        case 404:
          return Exception('Recurso não encontrado: $message');
        case 429:
          return Exception('Limite de requisições excedido. Tente novamente em alguns instantes.');
        default:
          return Exception('Erro $code: $message');
      }
    } catch (_) {
      return Exception('Erro HTTP ${response.statusCode}');
    }
  }
}

class EventsResult {
  final List<CalendarEvent> events;
  final String? nextPageToken;
  final String? summary;
  final String? timeZone;

  EventsResult({
    required this.events,
    this.nextPageToken,
    this.summary,
    this.timeZone,
  });
}
