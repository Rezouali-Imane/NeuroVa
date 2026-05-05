class NotificationModel {
  final String notificationid;
  final String userid;
  final String title;
  final String message;
  final String type;
  final bool isread;
  final DateTime createdat;

  NotificationModel({
    required this.notificationid,
    required this.userid,
    required this.title,
    required this.message,
    required this.type,
    required this.isread,
    required this.createdat,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationid: json['notificationid'].toString(),
      userid: json['userid'].toString(),
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'SYSTEM',
      isread: json['isread'] as bool? ?? false,
      createdat: DateTime.parse(json['createdat'] as String),
    );
  }
}