class FocusSession {
  final String sessionid;
  final String userid;
  final String? roomid;
  final DateTime starttime;
  final DateTime? endtime;
  final String status; // SCHEDULED, ACTIVE, COMPLETED, CANCELED
  final int? duration; // minutes
  final int? focusscore;
  final DateTime? scheduleid; // optional

  FocusSession({
    required this.sessionid,
    required this.userid,
    this.roomid,
    required this.starttime,
    this.endtime,
    required this.status,
    this.duration,
    this.focusscore,
    this.scheduleid,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      sessionid: json['sessionid'].toString(),
      userid: json['userid'].toString(),
      roomid: json['roomid']?.toString(),
      starttime: DateTime.parse(json['starttime']),
      endtime: json['endtime'] != null ? DateTime.parse(json['endtime']) : null,
      status: json['status'] ?? 'SCHEDULED',
      duration: json['duration'] as int?,
      focusscore: json['focusscore'] as int?,
      scheduleid: json['scheduleid'] != null ? DateTime.parse(json['scheduleid']) : null,
    );
  }
}

class TimerSettings {
  final String type;       // Pomodoro, Countdown, Stopwatch
  final int durationminutes;
  final int? breakminutes;
  final int? longbreakminutes;
  final int? pomodorocycles;
  final int remainingseconds;
  final bool isrunning;

  TimerSettings({
    required this.type,
    required this.durationminutes,
    this.breakminutes,
    this.longbreakminutes,
    this.pomodorocycles,
    required this.remainingseconds,
    required this.isrunning,
  });

Map<String, dynamic> toJson() => {
  'timertype': type,   // change from 'type' to 'timertype'
  'durationminutes': durationminutes,
  'remainingseconds': remainingseconds,
  'isrunning': isrunning,
  if (breakminutes != null) 'breakminutes': breakminutes,
  if (longbreakminutes != null) 'longbreakminutes': longbreakminutes,
  if (pomodorocycles != null) 'pomodorocycles': pomodorocycles,
};

  factory TimerSettings.fromJson(Map<String, dynamic> json) => TimerSettings(
    type: (json['timertype'] ?? json['type'] ?? 'POMODORO').toString(),
    durationminutes: json['durationminutes'] ?? 25,
    breakminutes: json['breakminutes'],
    longbreakminutes: json['longbreakminutes'],
    pomodorocycles: json['pomodoroscycle'] ?? json['pomodorocycles'],
    remainingseconds: json['remainingseconds'] ?? 0,
    isrunning: json['isrunning'] ?? false,
  );
}