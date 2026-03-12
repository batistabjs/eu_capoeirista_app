class CalendarEvent {
  final String id;
  final String summary;
  final String? description;
  final String? location;
  final EventDateTime? start;
  final EventDateTime? end;
  final String? status;
  final String? htmlLink;
  final List<Attendee>? attendees;
  final Creator? creator;
  final Creator? organizer;
  final String? colorId;
  final bool? allDay;
  final List<String>? recurrence;
  final ConferenceData? conferenceData;
  final String? hangoutLink;
  final Reminders? reminders;
  final DateTime? created;
  final DateTime? updated;
  final String? recurringEventId;

  CalendarEvent({
    required this.id,
    required this.summary,
    this.description,
    this.location,
    this.start,
    this.end,
    this.status,
    this.htmlLink,
    this.attendees,
    this.creator,
    this.organizer,
    this.colorId,
    this.allDay,
    this.recurrence,
    this.conferenceData,
    this.hangoutLink,
    this.reminders,
    this.created,
    this.updated,
    this.recurringEventId,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    final startJson = json['start'];
    final endJson = json['end'];
    final bool isAllDay = startJson != null && startJson['date'] != null && startJson['dateTime'] == null;

    return CalendarEvent(
      id: json['id'] ?? '',
      summary: json['summary'] ?? '(Sem título)',
      description: json['description'],
      location: json['location'],
      start: startJson != null ? EventDateTime.fromJson(startJson) : null,
      end: endJson != null ? EventDateTime.fromJson(endJson) : null,
      status: json['status'],
      htmlLink: json['htmlLink'],
      attendees: (json['attendees'] as List?)
          ?.map((a) => Attendee.fromJson(a))
          .toList(),
      creator: json['creator'] != null ? Creator.fromJson(json['creator']) : null,
      organizer: json['organizer'] != null ? Creator.fromJson(json['organizer']) : null,
      colorId: json['colorId'],
      allDay: isAllDay,
      recurrence: (json['recurrence'] as List?)?.cast<String>(),
      conferenceData: json['conferenceData'] != null
          ? ConferenceData.fromJson(json['conferenceData'])
          : null,
      hangoutLink: json['hangoutLink'],
      reminders: json['reminders'] != null ? Reminders.fromJson(json['reminders']) : null,
      created: json['created'] != null ? DateTime.tryParse(json['created']) : null,
      updated: json['updated'] != null ? DateTime.tryParse(json['updated']) : null,
      recurringEventId: json['recurringEventId'],
    );
  }

  bool get isRecurring => recurringEventId != null || (recurrence != null && recurrence!.isNotEmpty);

  bool get hasVideoConference =>
      hangoutLink != null ||
      (conferenceData?.entryPoints?.any((ep) => ep.entryPointType == 'video') ?? false);

  String get videoLink {
    if (hangoutLink != null) return hangoutLink!;
    final videoEp = conferenceData?.entryPoints
        ?.firstWhere((ep) => ep.entryPointType == 'video', orElse: () => EntryPoint(entryPointType: '', uri: ''));
    return videoEp?.uri ?? '';
  }
}

class EventDateTime {
  final DateTime? dateTime;
  final String? date;
  final String? timeZone;

  EventDateTime({this.dateTime, this.date, this.timeZone});

  factory EventDateTime.fromJson(Map<String, dynamic> json) {
    return EventDateTime(
      dateTime: json['dateTime'] != null ? DateTime.tryParse(json['dateTime']) : null,
      date: json['date'],
      timeZone: json['timeZone'],
    );
  }

  DateTime? get effectiveDateTime {
    if (dateTime != null) return dateTime;
    if (date != null) return DateTime.tryParse(date!);
    return null;
  }
}

class Attendee {
  final String? email;
  final String? displayName;
  final bool? self;
  final String? responseStatus;
  final bool? organizer;
  final bool? optional;

  Attendee({
    this.email,
    this.displayName,
    this.self,
    this.responseStatus,
    this.organizer,
    this.optional,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      email: json['email'],
      displayName: json['displayName'],
      self: json['self'],
      responseStatus: json['responseStatus'],
      organizer: json['organizer'],
      optional: json['optional'],
    );
  }

  String get name => displayName ?? email ?? 'Desconhecido';
}

class Creator {
  final String? email;
  final String? displayName;

  Creator({this.email, this.displayName});

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      email: json['email'],
      displayName: json['displayName'],
    );
  }

  String get name => displayName ?? email ?? 'Desconhecido';
}

class ConferenceData {
  final String? conferenceSolution;
  final List<EntryPoint>? entryPoints;

  ConferenceData({this.conferenceSolution, this.entryPoints});

  factory ConferenceData.fromJson(Map<String, dynamic> json) {
    return ConferenceData(
      conferenceSolution: json['conferenceSolution']?['name'],
      entryPoints: (json['entryPoints'] as List?)
          ?.map((e) => EntryPoint.fromJson(e))
          .toList(),
    );
  }
}

class EntryPoint {
  final String entryPointType;
  final String uri;
  final String? label;

  EntryPoint({required this.entryPointType, required this.uri, this.label});

  factory EntryPoint.fromJson(Map<String, dynamic> json) {
    return EntryPoint(
      entryPointType: json['entryPointType'] ?? '',
      uri: json['uri'] ?? '',
      label: json['label'],
    );
  }
}

class Reminders {
  final bool? useDefault;
  final List<ReminderOverride>? overrides;

  Reminders({this.useDefault, this.overrides});

  factory Reminders.fromJson(Map<String, dynamic> json) {
    return Reminders(
      useDefault: json['useDefault'],
      overrides: (json['overrides'] as List?)
          ?.map((r) => ReminderOverride.fromJson(r))
          .toList(),
    );
  }
}

class ReminderOverride {
  final String method;
  final int minutes;

  ReminderOverride({required this.method, required this.minutes});

  factory ReminderOverride.fromJson(Map<String, dynamic> json) {
    return ReminderOverride(
      method: json['method'] ?? '',
      minutes: json['minutes'] ?? 0,
    );
  }

  String get formattedTime {
    if (minutes < 60) return '$minutes min';
    if (minutes < 1440) return '${minutes ~/ 60}h';
    return '${minutes ~/ 1440} dias';
  }
}

class CalendarInfo {
  final String id;
  final String summary;
  final String? description;
  final String? backgroundColor;
  final String? foregroundColor;
  final bool? primary;

  CalendarInfo({
    required this.id,
    required this.summary,
    this.description,
    this.backgroundColor,
    this.foregroundColor,
    this.primary,
  });

  factory CalendarInfo.fromJson(Map<String, dynamic> json) {
    return CalendarInfo(
      id: json['id'] ?? '',
      summary: json['summary'] ?? '',
      description: json['description'],
      backgroundColor: json['backgroundColor'],
      foregroundColor: json['foregroundColor'],
      primary: json['primary'],
    );
  }
}
