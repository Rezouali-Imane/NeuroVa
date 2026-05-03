import 'dart:async';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:neurova_app/shared/services/local_storage_service.dart';
import '../models/ai_models.dart';

class AIService {
  final Dio _dio;
  final LocalStorageService _localStorageService;
  io.Socket? _voiceCallSocket;
  bool _keepVoiceCallConnected = false;

  static const Duration _standardConnectTimeout = Duration(seconds: 12);
  static const Duration _standardReceiveTimeout = Duration(seconds: 20);
  static const Duration _longReceiveTimeout = Duration(seconds: 95);

  AIService(this._dio, this._localStorageService);

  Future<void> _waitForVoiceSocketConnected(io.Socket socket) async {
    if (socket.connected) return;

    final completer = Completer<void>();

    void onConnected(_) {
      if (!completer.isCompleted) completer.complete();
    }

    void onConnectError(dynamic error) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Voice call connection failed: $error'));
      }
    }

    socket.on('connect', onConnected);
    socket.on('connect_error', onConnectError);

    try {
      await completer.future.timeout(const Duration(seconds: 8));
    } finally {
      socket.off('connect', onConnected);
      socket.off('connect_error', onConnectError);
    }
  }

  Future<void> connectVoiceCallChannel() async {
    _keepVoiceCallConnected = true;

    final existing = _voiceCallSocket;
    if (existing != null) {
      if (!existing.connected) {
        existing.connect();
        await _waitForVoiceSocketConnected(existing);
      }
      return;
    }

    final token = await _getAuthToken();
    if (token == null || token.trim().isEmpty) {
      throw Exception('Authentication token missing for voice call');
    }

    final baseUri = Uri.parse(_dio.options.baseUrl);
    final scheme = baseUri.scheme == 'https' ? 'https' : 'http';
    final host = baseUri.host;
    final port = baseUri.hasPort ? ':${baseUri.port}' : '';
    final namespaceUrl = '$scheme://$host$port/aicall';

    _voiceCallSocket = io.io(
      namespaceUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 999999,
        'reconnectionDelay': 500,
        'reconnectionDelayMax': 4000,
        'auth': {'token': token},
      },
    );

    final socket = _voiceCallSocket!;
    socket.onDisconnect((_) {
      if (_keepVoiceCallConnected) {
        socket.connect();
      }
    });

    await _waitForVoiceSocketConnected(socket);
  }

  Future<void> disconnectVoiceCallChannel() async {
    _keepVoiceCallConnected = false;
    _voiceCallSocket?.disconnect();
    _voiceCallSocket?.dispose();
    _voiceCallSocket = null;
  }

  Future<AIMessage> sendRealtimeVoiceTurn({
    required String transcript,
    bool directChat = true,
    bool faithMode = false,
  }) async {
    final content = transcript.trim();
    if (content.isEmpty) {
      throw Exception('Voice transcript is empty');
    }

    if (_voiceCallSocket?.connected != true) {
      await connectVoiceCallChannel();
    }

    final socket = _voiceCallSocket;
    if (socket == null) {
      throw Exception('Voice call channel is unavailable');
    }

    final requestId = DateTime.now().microsecondsSinceEpoch.toString();
    final completer = Completer<AIMessage>();

    void onAssistantReply(dynamic raw) {
      final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      if (map['requestId']?.toString() != requestId) return;

      if (!completer.isCompleted) {
        completer.complete(
          AIMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: (map['reply'] ?? '').toString(),
            role: 'ASSISTANT',
            timestamp: DateTime.now(),
            metadata: map,
          ),
        );
      }
    }

    void onModerationBlock(dynamic raw) {
      final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      if (map['requestId']?.toString() != requestId) return;

      if (!completer.isCompleted) {
        completer.completeError(
          Exception('Blocked by moderation: ${(map['reason'] ?? 'unsafe content').toString()}'),
        );
      }
    }

    void onVoiceError(dynamic raw) {
      final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      if (map['requestId']?.toString() != requestId) return;

      if (!completer.isCompleted) {
        completer.completeError(Exception((map['message'] ?? 'Voice turn failed').toString()));
      }
    }

    socket.on('assistant_reply', onAssistantReply);
    socket.on('moderation_block', onModerationBlock);
    socket.on('voice_turn_error', onVoiceError);

    void emitVoiceTurn() {
      socket.emit('voice_turn', {
        'requestId': requestId,
        'content': content,
        'directchat': directChat,
        'faithmode': faithMode,
      });
    }

    emitVoiceTurn();

    try {
      return await completer.future.timeout(const Duration(seconds: 90));
    } on TimeoutException {
      if (!socket.connected) {
        await connectVoiceCallChannel();
        emitVoiceTurn();
        return await completer.future.timeout(const Duration(seconds: 45));
      }
      rethrow;
    } finally {
      socket.off('assistant_reply', onAssistantReply);
      socket.off('moderation_block', onModerationBlock);
      socket.off('voice_turn_error', onVoiceError);
    }
  }

  Future<String?> _getAuthToken() async {
    return await _localStorageService.readAuthToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Options _requestOptions(
    Map<String, String> headers, {
    bool longRunning = false,
  }) {
    return Options(
      headers: headers,
      sendTimeout: _standardConnectTimeout,
      connectTimeout: _standardConnectTimeout,
      receiveTimeout: longRunning ? _longReceiveTimeout : _standardReceiveTimeout,
    );
  }

  // Send message to AI - main chat endpoint
  Future<AIMessage> sendMessage({
    required String userId,
    required String content,
    bool directChat = false,
    bool faithMode = false,
  }) async {
    Future<Response<dynamic>> postMessage({required bool allowExtendedTimeout}) async {
      final headers = await _getHeaders();
      return _dio.post<dynamic>(
        '/api/ai/message',
        data: {
          'userid': userId,
          'content': content,
          'directchat': directChat,
          'faithmode': faithMode,
        },
        options: _requestOptions(headers, longRunning: true).copyWith(
          // Give local Ollama extra headroom on retry when model is warming up or queued.
          receiveTimeout: allowExtendedTimeout ? const Duration(seconds: 120) : _longReceiveTimeout,
        ),
      );
    }

    try {
      late Response<dynamic> response;
      try {
        response = await postMessage(allowExtendedTimeout: false);
      } on DioException catch (e) {
        final serverMessage = e.response?.data?['message']?.toString().toLowerCase() ?? '';
        final retryable =
            e.type == DioExceptionType.receiveTimeout ||
            serverMessage.contains('timeout') ||
            serverMessage.contains('busy');

        if (!retryable) rethrow;

        await Future.delayed(const Duration(milliseconds: 450));
        response = await postMessage(allowExtendedTimeout: true);
      }

      if (response.statusCode == 200) {
        final payload = response.data;
        if (payload is! Map<String, dynamic>) {
          throw Exception('Invalid AI response payload');
        }

        final dataRaw = payload['data'];
        final data = dataRaw is Map<String, dynamic> ? dataRaw : <String, dynamic>{};
        final replyText = (data['reply'] ?? data['content'] ?? data['message'] ?? '')
            .toString()
            .trim();

        return AIMessage(
          id: (data['chatid'] ?? data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
              .toString(),
          content: replyText.isNotEmpty ? replyText : 'No response generated.',
          role: 'ASSISTANT',
          timestamp: DateTime.now(),
          metadata: data['metadata'] is Map<String, dynamic>
              ? data['metadata'] as Map<String, dynamic>
              : null,
        );
      }
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to send message',
        type: DioExceptionType.badResponse,
        response: response,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AIMessage> sendImageMessage({
    required String userId,
    required String imagePath,
    String prompt = '',
    bool directChat = true,
    bool faithMode = false,
  }) async {
    try {
      final token = await _getAuthToken();
      final headers = {
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final formData = FormData.fromMap({
        'userid': userId,
        'prompt': prompt,
        'directchat': directChat.toString(),
        'faithmode': faithMode.toString(),
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post<dynamic>(
        '/api/ai/message/image',
        data: formData,
        options: _requestOptions(headers, longRunning: true),
      );

      if (response.statusCode == 200) {
        final payload = response.data as Map<String, dynamic>;
        final data = (payload['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        final replyText = (data['reply'] ?? '').toString().trim();

        return AIMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: replyText.isNotEmpty ? replyText : 'No response generated.',
          role: 'ASSISTANT',
          timestamp: DateTime.now(),
          metadata: data['metadata'] is Map<String, dynamic>
              ? data['metadata'] as Map<String, dynamic>
              : null,
        );
      }

      throw Exception('Failed to send image message');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AIMessage> sendVoiceMessage({
    required String userId,
    required String audioPath,
    String promptPrefix = '',
    bool directChat = true,
    bool faithMode = false,
  }) async {
    try {
      final token = await _getAuthToken();
      final headers = {
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final formData = FormData.fromMap({
        'userid': userId,
        'promptPrefix': promptPrefix,
        'directchat': directChat.toString(),
        'faithmode': faithMode.toString(),
        'audio': await MultipartFile.fromFile(audioPath),
      });

      final response = await _dio.post<dynamic>(
        '/api/ai/message/voice',
        data: formData,
        options: _requestOptions(headers, longRunning: true),
      );

      if (response.statusCode == 200) {
        final payload = response.data as Map<String, dynamic>;
        final data = (payload['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        final replyText = (data['reply'] ?? '').toString().trim();

        return AIMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: replyText.isNotEmpty ? replyText : 'No response generated.',
          role: 'ASSISTANT',
          timestamp: DateTime.now(),
          metadata: data,
        );
      }

      throw Exception('Failed to send voice message');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get chat history
  Future<List<AIMessage>> getChatHistory({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get<dynamic>(
        '/api/ai/history/$userId',
        queryParameters: {'limit': limit, 'offset': offset},
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((msg) => AIMessage.fromJson(msg as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch chat history');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Clear chat history
  Future<bool> clearChatHistory(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete<dynamic>(
        '/api/ai/history/$userId',
        options: _requestOptions(headers),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generate study plan
  Future<StudyPlan> generateStudyPlan({
    required String userId,
    bool faithMode = false,
    String? city,
    String? country,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post<dynamic>(
        '/api/ai/study-plan/$userId',
        data: {
          'faithmode': faithMode,
          'city': city,
          'country': country,
        },
        options: _requestOptions(headers, longRunning: true),
      );

      if (response.statusCode == 200) {
        return StudyPlan.fromJson(response.data['data']);
      }
      throw Exception('Failed to generate study plan');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Analyze weakness
  Future<WeaknessAnalysis> analyzeWeakness(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post<dynamic>(
        '/api/ai/weakness/$userId',
        options: _requestOptions(headers, longRunning: true),
      );

      if (response.statusCode == 200) {
        return WeaknessAnalysis.fromJson(response.data['data']);
      }
      throw Exception('Failed to analyze weakness');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get student memory/profile
  Future<StudentMemory> getMemory(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get<dynamic>(
        '/api/ai/memory/$userId',
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final payload = response.data;
        if (payload is! Map<String, dynamic>) {
          throw Exception('Invalid memory response payload');
        }
        return StudentMemory.fromJson(payload['data']);
      }
      throw Exception('Failed to fetch memory');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update student memory
  Future<StudentMemory> updateMemory({
    required String userId,
    required Map<String, String> data,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put<dynamic>(
        '/api/ai/memory/$userId',
        data: data,
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final payload = response.data;
        if (payload is! Map<String, dynamic>) {
          throw Exception('Invalid memory response payload');
        }
        return StudentMemory.fromJson(payload['data']);
      }
      throw Exception('Failed to update memory');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Upload document
  Future<KnowledgeItem> uploadDocument({
    required String userId,
    required String filePath,
    String? subject,
    String? major,
  }) async {
    try {
      final token = await _getAuthToken();
      final headers = {
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final formData = FormData.fromMap({
        'userid': userId,
        'subject': subject,
        'major': major,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post<dynamic>(
        '/api/ai/knowledge',
        data: formData,
        options: _requestOptions(headers, longRunning: true),
      );

      if (response.statusCode == 201) {
        return KnowledgeItem.fromJson(response.data['data']);
      }
      throw Exception('Failed to upload document');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get knowledge base (documents)
  Future<List<KnowledgeItem>> getKnowledgeBase(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get<dynamic>(
        '/api/ai/knowledge/$userId',
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((item) => KnowledgeItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch knowledge base');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete document
  Future<bool> deleteDocument(String documentId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete<dynamic>(
        '/api/ai/knowledge/$documentId',
        options: _requestOptions(headers),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Schedule focus session from AI recommendation
  Future<Map<String, dynamic>> scheduleFocusSession({
    required String userId,
    String? taskId,
    int durationMinutes = 50,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post<dynamic>(
        '/api/ai/schedule-session',
        data: {
          'userid': userId,
          'taskid': taskId,
          'durationminutes': durationMinutes,
        },
        options: _requestOptions(headers, longRunning: true),
      );

      if (response.statusCode == 201) {
        return response.data['data'];
      }
      throw Exception('Failed to schedule focus session');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get AI insights for dashboard
  Future<List<AIInsight>> getInsights(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get<dynamic>(
        '/api/ai/insights/$userId',
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((item) => AIInsight.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch AI insights');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle and standardize errors
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout) {
        return Exception('Connection timeout. Please try again.');
      } else if (error.type == DioExceptionType.sendTimeout) {
        return Exception('Request timed out while sending data. Please retry.');
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return Exception('AI response is taking too long. Please try again.');
      } else if (error.response?.statusCode == 401) {
        return Exception('Authentication failed. Please sign in again.');
      } else if (error.response?.statusCode == 403) {
        return Exception('Access forbidden.');
      } else if (error.response?.statusCode == 429) {
        return Exception('Too many requests. Please wait before trying again.');
      } else if (error.response?.statusCode == 500) {
        final serverMessage = error.response?.data['message']?.toString() ?? '';
        if (serverMessage.toLowerCase().contains('timeout')) {
          return Exception('AI is currently busy. Please retry in a moment.');
        }
        return Exception('Server error. Please try again later.');
      }
      return Exception(
          error.response?.data['message'] ?? 'An error occurred: ${error.message}');
    }
    return Exception(error.toString());
  }
}

// TODO: Add AI Service provider in your providers file or main.dart
// Example:
// final aiServiceProvider = Provider((ref) {
//   final dio = ref.watch(dioProvider);  // Your existing dio provider
//   final localStorage = ref.watch(localStorageServiceProvider);  // Your existing storage provider
//   return AIService(dio, localStorage);
// });
