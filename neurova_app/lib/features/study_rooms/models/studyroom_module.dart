class StudyRoom {
  final String roomid;
  final String roomcode;
  final String ownername;
  final String roomname;
  final String subject;
  final String focusmode;
  final int maxparticipants;
  final bool ispublic;
  final bool isactive;
  final List<Participant> participants;
  final DateTime createdat;
  final DateTime? startedat;
  final DateTime? endedat;

  const StudyRoom({
    required this.roomid,
    required this.roomcode,
    required this.ownername,
    required this.roomname,
    required this.subject,
    required this.focusmode,
    required this.maxparticipants,
    required this.ispublic,
    required this.isactive,
    this.participants = const [],
    required this.createdat,
    this.startedat,
    this.endedat,
  });

  factory StudyRoom.fromJson(Map<String, dynamic> json) {
    return StudyRoom(
      roomid: json['roomid']?.toString() ?? '',
      roomcode: json['roomcode']?.toString() ?? '',
      ownername: json['ownername']?.toString() ?? '',
      roomname: json['roomname']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      focusmode: json['focusmode']?.toString() ?? 'Deep Work',
      maxparticipants: json['maxparticipants'] as int? ?? 10,
      ispublic: json['ispublic'] as bool? ?? true,
      isactive: json['isactive'] as bool? ?? false,
      participants: json['participants'] != null
          ? (json['participants'] as List<dynamic>)
              .map((p) => Participant.fromJson(p as Map<String, dynamic>))
              .toList()
          : [],
      createdat: json['createdat'] != null
          ? DateTime.parse(json['createdat'] as String)
          : DateTime.now(),
      startedat: json['startedat'] != null
          ? DateTime.parse(json['startedat'] as String)
          : null,
      endedat: json['endedat'] != null
          ? DateTime.parse(json['endedat'] as String)
          : null,
    );
  }
}

class Participant {
  final String userid;
  final String username;
  final bool isowner;
  final DateTime joinedat;

  const Participant({
    required this.userid,
    required this.username,
    required this.isowner,
    required this.joinedat,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userid: json['userid']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      isowner: json['isowner'] as bool? ?? false,
      joinedat: json['joinedat'] != null
          ? DateTime.parse(json['joinedat'] as String)
          : DateTime.now(),
    );
  }
}