import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_models.dart';
import '../services/ai_service.dart';

// ==============================================================================
// STATE
// ==============================================================================

class AIState {
  final List<AIMessage> messages;
  final bool isLoading;
  final String error;
  final bool hasError;
  final StudentMemory? memory;
  final StudyPlan? currentStudyPlan;
  final WeaknessAnalysis? weaknessAnalysis;
  final List<KnowledgeItem> knowledgeBase;
  final bool isSending;

  const AIState({
    this.messages = const [],
    this.isLoading = false,
    this.error = '',
    this.hasError = false,
    this.memory,
    this.currentStudyPlan,
    this.weaknessAnalysis,
    this.knowledgeBase = const [],
    this.isSending = false, Object? studyPlan,
  });

  AIState copyWith({
    List<AIMessage>? messages,
    bool? isLoading,
    String? error,
    bool? hasError,
    StudentMemory? memory,
    StudyPlan? currentStudyPlan,
    WeaknessAnalysis? weaknessAnalysis,
    List<KnowledgeItem>? knowledgeBase,
    bool? isSending,
  }) {
    return AIState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasError: hasError ?? this.hasError,
      memory: memory ?? this.memory,
      currentStudyPlan: currentStudyPlan ?? this.currentStudyPlan,
      weaknessAnalysis: weaknessAnalysis ?? this.weaknessAnalysis,
      knowledgeBase: knowledgeBase ?? this.knowledgeBase,
      isSending: isSending ?? this.isSending,
    );
  }
}

// ==============================================================================
// NOTIFIER
// ==============================================================================

class AINotifier extends StateNotifier<AIState> {
  final AIService _aiService;
  final String _userId;

  AINotifier(this._aiService, this._userId) : super(const AIState());

  // Send message to AI
  Future<void> sendMessage(String content, {bool directChat = false}) async {
    try {
      state = state.copyWith(isSending: true, error: '', hasError: false);

      // Add user message immediately to UI
      final userMessage = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        role: 'USER',
        timestamp: DateTime.now(),
      );

      state = state.copyWith(messages: [...state.messages, userMessage]);

      // Get AI response
      final response = await _aiService.sendMessage(
        userId: _userId,
        content: content,
        directChat: directChat,
      );

      // Add AI message to chat
      state = state.copyWith(
        messages: [...state.messages, response],
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        hasError: true,
        isSending: false,
      );
    }
  }

  // Load chat history
  Future<void> loadChatHistory({int limit = 50, int offset = 0}) async {
    try {
      state = state.copyWith(isLoading: true, error: '', hasError: false);

      final messages = await _aiService.getChatHistory(
        userId: _userId,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        hasError: true,
        isLoading: false,
      );
    }
  }

  // Clear chat history
  Future<void> clearChatHistory() async {
    try {
      final success = await _aiService.clearChatHistory(_userId);
      if (success) {
        state = state.copyWith(messages: []);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), hasError: true);
    }
  }

  // Load student memory/profile
  Future<void> loadMemory() async {
    try {
      state = state.copyWith(isLoading: true, error: '', hasError: false);

      final memory = await _aiService.getMemory(_userId);
      state = state.copyWith(memory: memory, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        hasError: true,
        isLoading: false,
      );
    }
  }

  // Update student memory
  Future<void> updateMemory(Map<String, String> data) async {
    try {
      state = state.copyWith(isLoading: true, error: '', hasError: false);

      final updatedMemory = await _aiService.updateMemory(
        userId: _userId,
        data: data,
      );

      state = state.copyWith(memory: updatedMemory, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        hasError: true,
        isLoading: false,
      );
    }
  }

  // Generate study plan
  Future<void> generateStudyPlan({
    bool faithMode = false,
    String? city,
    String? country,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: '', hasError: false);

      final plan = await _aiService.generateStudyPlan(
        userId: _userId,
        faithMode: faithMode,
        city: city,
        country: country,
      );

      state = state.copyWith(currentStudyPlan: plan, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        hasError: true,
        isLoading: false,
      );
    }
  }

  // Analyze weakness
  Future<void> analyzeWeakness() async {
    try {
      state = state.copyWith(isLoading: true, error: '', hasError: false);

      final analysis = await _aiService.analyzeWeakness(_userId);
      state = state.copyWith(weaknessAnalysis: analysis, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        hasError: true,
        isLoading: false,
      );
    }
  }

  // Load knowledge base
  Future<void> loadKnowledgeBase() async {
    try {
      state = state.copyWith(isLoading: true, error: '', hasError: false);

      final knowledge = await _aiService.getKnowledgeBase(_userId);
      state = state.copyWith(knowledgeBase: knowledge, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        hasError: true,
        isLoading: false,
      );
    }
  }

  // Upload document
  Future<void> uploadDocument(
    String filePath, {
    String? subject,
    String? major,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: '', hasError: false);

      final item = await _aiService.uploadDocument(
        userId: _userId,
        filePath: filePath,
        subject: subject,
        major: major,
      );

      state = state.copyWith(
        knowledgeBase: [...state.knowledgeBase, item],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        hasError: true,
        isLoading: false,
      );
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentId) async {
    try {
      state = state.copyWith(isLoading: true, error: '', hasError: false);

      final success = await _aiService.deleteDocument(documentId);
      if (success) {
        state = state.copyWith(
          knowledgeBase: [
            ...state.knowledgeBase.where((item) => item.id != documentId)
          ],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        hasError: true,
        isLoading: false,
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: '', hasError: false);
  }
}

// ==============================================================================
// PROVIDERS
// ==============================================================================

// TODO: Create provider in your providers file or main.dart
// You'll need to:
// 1. Import AIService: import '../services/ai_service.dart';
// 2. Create AIService provider (using your existing dio and localStorage providers)
// 3. Create AINotifier provider like this:
//
// final aiServiceProvider = Provider((ref) {
//   final dio = ref.watch(dioProvider);  // Your existing provider
//   final localStorage = ref.watch(localStorageServiceProvider);  // Your existing provider
//   return AIService(dio, localStorage);
// });
//
// final aiNotifierProvider = StateNotifierProvider.family<AINotifier, AIState, String>((ref, userId) {
//   final aiService = ref.watch(aiServiceProvider);
//   return AINotifier(aiService, userId);
// });

// For now, we provide a basic notifier that can be created manually:
// Example usage in your screen:
// final notifier = AINotifier(aiService, userId);

// Convenience providers for current user
final currentUserIdProvider = Provider<String>((ref) {
  // This should be injected or obtained from auth state
  // For now, return empty string - you'll need to update this
  throw UnimplementedError(
      'currentUserIdProvider must be implemented with actual user ID');
});
