class Note {
  final String noteid;
  final String userid;
  final String title;
  final String? content;
  final DateTime createdat;

  const Note({
    required this.noteid,
    required this.userid,
    required this.title,
    this.content,
    required this.createdat,
  });

  Note copyWith({
    String? noteid,
    String? userid,
    String? title,
    String? content,
    DateTime? createdat,
  }) {
    return Note(
      noteid: noteid ?? this.noteid,
      userid: userid ?? this.userid,
      title: title ?? this.title,
      content: content ?? this.content,
      createdat: createdat ?? this.createdat,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      noteid: json['noteid']?.toString() ?? '',
      userid: json['userid']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String?,
      createdat: json['createdat'] != null
          ? DateTime.parse(json['createdat'] as String)
          : DateTime.now(),
    );
  }
}