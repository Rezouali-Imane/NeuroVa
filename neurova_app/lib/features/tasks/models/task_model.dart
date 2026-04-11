class Task {
  final String taskid;
  final String userid;
  final String listid;
  final String title;
  final String? description;
  final DateTime? deadline;
  final int priority;
  final String status; // PENDING, IN_PROGRESS, COMPLETED, OVERDUE
  final String category; // ACADEMIC, PERSONAL, WORK, HEALTH, OTHER
  final String? googleeventid;
  final bool syncwithgoogle;
  final DateTime createdat;
  final DateTime updatedat;

  Task({
    required this.taskid,
    required this.userid,
    required this.listid,
    required this.title,
    this.description,
    this.deadline,
    required this.priority,
    required this.status,
    required this.category,
    this.googleeventid,
    required this.syncwithgoogle,
    required this.createdat,
    required this.updatedat,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskid: json['taskid'] as String,
      userid: json['userid'] as String,
      listid: json['listid'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      priority: json['priority'] as int? ?? 1,
      status: json['status'] as String? ?? 'PENDING',
      category: json['category'] as String? ?? 'OTHER',
      googleeventid: json['googleeventid'] as String?,
      syncwithgoogle: json['syncwithgoogle'] as bool? ?? false,
      createdat: DateTime.parse(json['createdat'] as String),
      updatedat: DateTime.parse(json['updatedat'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskid': taskid,
      'userid': userid,
      'listid': listid,
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'priority': priority,
      'status': status,
      'category': category,
      'googleeventid': googleeventid,
      'syncwithgoogle': syncwithgoogle,
      'createdat': createdat.toIso8601String(),
      'updatedat': updatedat.toIso8601String(),
    };
  }

  Task copyWith({
    String? taskid,
    String? userid,
    String? listid,
    String? title,
    String? description,
    DateTime? deadline,
    int? priority,
    String? status,
    String? category,
    String? googleeventid,
    bool? syncwithgoogle,
    DateTime? createdat,
    DateTime? updatedat,
  }) {
    return Task(
      taskid: taskid ?? this.taskid,
      userid: userid ?? this.userid,
      listid: listid ?? this.listid,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      googleeventid: googleeventid ?? this.googleeventid,
      syncwithgoogle: syncwithgoogle ?? this.syncwithgoogle,
      createdat: createdat ?? this.createdat,
      updatedat: updatedat ?? this.updatedat,
    );
  }
}
