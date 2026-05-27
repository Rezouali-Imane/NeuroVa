class DisciplineSettings {
  final String userId;
  final String filterLevel;
  final int dailyFreeMinutes;
  final bool customBlockingEnabled;
  final bool faithModeEnabled;

  DisciplineSettings({
    required this.userId,
    this.filterLevel = 'Medium',
    this.dailyFreeMinutes = 120,
    this.customBlockingEnabled = true,
    this.faithModeEnabled = false,
  });

  factory DisciplineSettings.fromJson(Map<String, dynamic> json) {
    return DisciplineSettings(
      userId: json['userid'] as String? ?? '',
      filterLevel: json['filterLevel'] as String? ?? 'Medium',
      dailyFreeMinutes: json['dailyFreeMinutes'] as int? ?? 120,
      customBlockingEnabled: json['customBlockingEnabled'] as bool? ?? true,
      faithModeEnabled: json['faithModeEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'userid': userId,
    'filterLevel': filterLevel,
    'dailyFreeMinutes': dailyFreeMinutes,
    'customBlockingEnabled': customBlockingEnabled,
    'faithModeEnabled': faithModeEnabled,
  };
}

class BlockedApp {
  final String appId;
  final String appName;
  final String packageName;
  final bool isBlocked;

  BlockedApp({
    required this.appId,
    required this.appName,
    required this.packageName,
    this.isBlocked = true,
  });

  factory BlockedApp.fromJson(Map<String, dynamic> json) {
    return BlockedApp(
      appId: json['appid'] as String? ?? '',
      appName: json['appname'] as String? ?? '',
      packageName: json['packagename'] as String? ?? '',
      isBlocked: json['isblocked'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'appid': appId,
    'appname': appName,
    'packagename': packageName,
    'isblocked': isBlocked,
  };
}

class BlockedWebsite {
  final String websiteId;
  final String domain;
  final String category;
  final bool isBlocked;

  BlockedWebsite({
    required this.websiteId,
    required this.domain,
    required this.category,
    this.isBlocked = true,
  });

  factory BlockedWebsite.fromJson(Map<String, dynamic> json) {
    return BlockedWebsite(
      websiteId: json['websiteid'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isBlocked: json['isblocked'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'websiteid': websiteId,
    'domain': domain,
    'category': category,
    'isblocked': isBlocked,
  };
}

class UsageLog {
  final String logId;
  final String userId;
  final String appOrWebsite;
  final int duration;
  final DateTime timestamp;

  UsageLog({
    required this.logId,
    required this.userId,
    required this.appOrWebsite,
    required this.duration,
    required this.timestamp,
  });

  factory UsageLog.fromJson(Map<String, dynamic> json) {
    return UsageLog(
      logId: json['logid'] as String? ?? '',
      userId: json['userid'] as String? ?? '',
      appOrWebsite: json['appOrWebsite'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'logid': logId,
    'userid': userId,
    'appOrWebsite': appOrWebsite,
    'duration': duration,
    'timestamp': timestamp.toIso8601String(),
  };
}

class DisciplineScore {
  final String scoreId;
  final String userId;
  final int score;
  final int totalMinutes;
  final int sessionsCompleted;
  final DateTime date;

  DisciplineScore({
    required this.scoreId,
    required this.userId,
    required this.score,
    required this.totalMinutes,
    required this.sessionsCompleted,
    required this.date,
  });

  factory DisciplineScore.fromJson(Map<String, dynamic> json) {
    return DisciplineScore(
      scoreId: json['scoreid'] as String? ?? '',
      userId: json['userid'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      sessionsCompleted: json['sessionsCompleted'] as int? ?? 0,
      date: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'scoreid': scoreId,
    'userid': userId,
    'score': score,
    'totalMinutes': totalMinutes,
    'sessionsCompleted': sessionsCompleted,
    'date': date.toIso8601String(),
  };
}

class DailyUsage {
  final String day;
  final int minutes;
  final List<UsageLog> logs;

  DailyUsage({
    required this.day,
    required this.minutes,
    required this.logs,
  });
}
