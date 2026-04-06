// AI message model for chat UI
class AIMessage {
  final String id;
  final String content;
  final String role; // 'USER' or 'ASSISTANT'
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  AIMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.metadata,
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) {
    return AIMessage(
      id: json['chatid'] ?? '',
      content: json['content'] ?? '',
      role: json['role'] ?? 'USER',
      timestamp: json['createdat'] != null
          ? DateTime.parse(json['createdat'])
          : DateTime.now(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatid': id,
      'content': content,
      'role': role,
      'createdat': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  AIMessage copyWith({
    String? id,
    String? content,
    String? role,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return AIMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Study plan model
class StudyPlan {
  final String title;
  final List<String> sections;
  final Map<String, dynamic> details;
  final DateTime generatedAt;

  StudyPlan({
    required this.title,
    required this.sections,
    required this.details,
    required this.generatedAt,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      title: json['title'] ?? 'Study Plan',
      sections: List<String>.from(json['sections'] ?? []),
      details: json['details'] ?? {},
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'sections': sections,
      'details': details,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

// Weakness analysis result
class WeaknessAnalysis {
  final List<String> weakSubjects;
  final List<String> recommendations;
  final Map<String, dynamic> details;

  WeaknessAnalysis({
    required this.weakSubjects,
    required this.recommendations,
    required this.details,
  });

  factory WeaknessAnalysis.fromJson(Map<String, dynamic> json) {
    return WeaknessAnalysis(
      weakSubjects: List<String>.from(json['weakSubjects'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      details: json['details'] ?? {},
    );
  }
}

// Document/knowledge base item
class KnowledgeItem {
  final String id;
  final String filename;
  final String? subject;
  final String? major;
  final int chunkCount;
  final DateTime uploadedAt;

  KnowledgeItem({
    required this.id,
    required this.filename,
    this.subject,
    this.major,
    required this.chunkCount,
    required this.uploadedAt,
  });

  factory KnowledgeItem.fromJson(Map<String, dynamic> json) {
    return KnowledgeItem(
      id: json['knowledgeid'] ?? '',
      filename: json['filename'] ?? '',
      subject: json['subject'],
      major: json['major'],
      chunkCount: json['chunkCount'] ?? 0,
      uploadedAt: json['uploadedat'] != null
          ? DateTime.parse(json['uploadedat'])
          : DateTime.now(),
    );
  }
}

// Student memory (profile)
class StudentMemory {
  final Map<String, String> data;

  StudentMemory({required this.data});

  factory StudentMemory.fromJson(dynamic json) {
    final map = <String, String>{};

    if (json is List) {
      for (final item in json) {
        if (item is Map) {
          final key = item['key']?.toString();
          if (key != null && key.isNotEmpty) {
            map[key] = item['value']?.toString() ?? '';
          }
        }
      }
    } else if (json is Map) {
      final hasKeyValueShape = json.containsKey('key') && json.containsKey('value');
      if (hasKeyValueShape) {
        final key = json['key']?.toString();
        if (key != null && key.isNotEmpty) {
          map[key] = json['value']?.toString() ?? '';
        }
      } else {
        json.forEach((k, v) {
          if (k != null) {
            map[k.toString()] = v?.toString() ?? '';
          }
        });
      }
    }

    return StudentMemory(data: map);
  }

  String? get name => data['name'];
  String? get major => data['major'];
  String? get university => data['university'];
  String? get weakSubjects => data['weak_subjects'];
  String? get goals => data['goals'];

  Map<String, dynamic> toJson() {
    return data;
  }
}

// AI tool result (for task creation, focus session, etc.)
class ToolResult {
  final String toolName;
  final String result;
  final Map<String, dynamic> details;

  ToolResult({
    required this.toolName,
    required this.result,
    required this.details,
  });

  factory ToolResult.fromJson(Map<String, dynamic> json) {
    return ToolResult(
      toolName: json['toolName'] ?? '',
      result: json['result'] ?? '',
      details: json['details'] ?? {},
    );
  }
}
