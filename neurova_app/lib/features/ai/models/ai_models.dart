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

  factory StudyPlan.fromPlanText(String planText, {DateTime? generatedAt}) {
    final normalizedText = planText.trim();
    final lines = normalizedText.split('\n');
    final sections = <String>[];
    final buffer = <String>[];

    void flushBuffer() {
      if (buffer.isEmpty) return;
      sections.add(buffer.join('\n').trim());
      buffer.clear();
    }

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      final headingMatch = RegExp(r'^(?:\*\*)?(Day\s+\d+[^\*]*)(?:\*\*)?$').firstMatch(line.trim());

      if (headingMatch != null && buffer.isNotEmpty) {
        flushBuffer();
      }

      if (line.trim().isNotEmpty) {
        buffer.add(line);
      } else if (buffer.isNotEmpty) {
        buffer.add('');
      }
    }

    flushBuffer();

    final fallbackSections = normalizedText
        .split(RegExp(r'\n\s*\n'))
        .map((section) => section.trim())
        .where((section) => section.isNotEmpty)
        .toList();

    final resolvedSections = sections.isNotEmpty ? sections : fallbackSections;

    return StudyPlan(
      title: 'Study Plan',
      sections: resolvedSections,
      details: {
        'rawPlan': normalizedText,
        'sectionCount': resolvedSections.length,
      },
      generatedAt: generatedAt ?? DateTime.now(),
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

// AI Insight model for dashboard insights
class AIInsight {
  final String id;
  final String title;
  final String content;
  final String? icon;
  final String category; // productivity, focus, wellbeing, learning
  final DateTime createdAt;

  AIInsight({
    required this.id,
    required this.title,
    required this.content,
    this.icon,
    required this.category,
    required this.createdAt,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      id: json['id'] ?? '',
      title: json['title'] ?? 'AI INSIGHT',
      content: json['content'] ?? '',
      icon: json['icon'],
      category: json['category'] ?? 'productivity',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'icon': icon,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AIInsight copyWith({
    String? id,
    String? title,
    String? content,
    String? icon,
    String? category,
    DateTime? createdAt,
  }) {
    return AIInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
