class XpEntry {
  final String xpid;
  final int amount;
  final String source;
  final String? description;
  final DateTime createdat;

  XpEntry({
    required this.xpid,
    required this.amount,
    required this.source,
    this.description,
    required this.createdat,
  });

  factory XpEntry.fromJson(Map<String, dynamic> json) => XpEntry(
    xpid: json['xpid'].toString(),
    amount: json['amount'] as int,
    source: json['source'] as String,
    description: json['description'] as String?,
    createdat: DateTime.parse(json['createdat'] as String),
  );
}

class Achievement {
  final String achievementid;
  final String name;
  final String? description;
  final DateTime earnedat;

  Achievement({
    required this.achievementid,
    required this.name,
    this.description,
    required this.earnedat,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    achievementid: json['achievementid'].toString(),
    name: json['name'] as String,
    description: json['description'] as String?,
    earnedat: DateTime.parse(json['earnedat'] as String),
  );
}

class Badge {
  final String badgeid;
  final String name;
  final String? description;
  final String? iconurl;
  final DateTime earnedat;

  Badge({
    required this.badgeid,
    required this.name,
    this.description,
    this.iconurl,
    required this.earnedat,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
    badgeid: json['badgeid'].toString(),
    name: json['name'] as String,
    description: json['description'] as String?,
    iconurl: json['iconurl'] as String?,
    earnedat: DateTime.parse(json['earnedat'] as String),
  );
}

class LeaderboardEntry {
  final String userid;
  final String? username;
  final int xppoints;
  final int rank;

  LeaderboardEntry({
    required this.userid,
    this.username,
    required this.xppoints,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        userid: json['userid'].toString(),
        username: json['username'] as String?,
        xppoints: json['xppoints'] as int,
        rank: json['rank'] as int,
      );
}

class DailyChallenge {
  final String challengeid;
  final String title;
  final String? description;
  final bool iscompleted;
  final int xpreward;

  DailyChallenge({
    required this.challengeid,
    required this.title,
    this.description,
    required this.iscompleted,
    required this.xpreward,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    final template = json['dailychallengetemplate'] as Map<String, dynamic>?;
    return DailyChallenge(
      challengeid: json['challengeid'].toString(),
      title: template?['title'] as String? ?? json['title'] as String? ?? '',
      description: template?['description'] as String? ?? json['description'] as String?,
      iscompleted: json['iscompleted'] as bool? ?? false,
      xpreward: template?['xpreward'] as int? ?? json['xpreward'] as int? ?? 0,
    );
  }
}