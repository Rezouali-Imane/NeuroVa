import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_models.dart';
import '../services/ai_service.dart';


final List<AIInsight> _fallbackInsights = [
  AIInsight(
    id: 'insight-0',
    title: 'AI INSIGHT',
    content: '5-MIN BREAKS IMPROVE RETENTION BY UP TO 20%. 🧠',
    icon: 'psychology_outlined',
    category: 'productivity',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  AIInsight(
    id: 'insight-1',
    title: 'AI INSIGHT',
    content: 'POMODORO TECHNIQUE: 25 MIN WORK + 5 MIN BREAK MAXIMIZES FOCUS. ⏱️',
    icon: 'psychology_outlined',
    category: 'focus',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  AIInsight(
    id: 'insight-2',
    title: 'AI INSIGHT',
    content: 'MORNING STUDY SESSIONS ARE 40% MORE PRODUCTIVE THAN EVENING. 🌅',
    icon: 'psychology_outlined',
    category: 'learning',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  AIInsight(
    id: 'insight-3',
    title: 'AI INSIGHT',
    content: 'STAYING HYDRATED CAN IMPROVE COGNITIVE PERFORMANCE BY 30%. 💧',
    icon: 'psychology_outlined',
    category: 'wellbeing',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  AIInsight(
    id: 'insight-4',
    title: 'AI INSIGHT',
    content: 'CONSISTENT SLEEP SCHEDULE BOOSTS LEARNING RETENTION BY 25%. 😴',
    icon: 'psychology_outlined',
    category: 'wellbeing',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
];

// ==============================================================================
// STATE
// ==============================================================================

class InsightsState {
  final List<AIInsight> insights;
  final int currentInsightIndex;
  final bool isLoading;
  final String error;
  final bool hasError;
  final bool isAutoSwitching;

  const InsightsState({
    this.insights = const [],
    this.currentInsightIndex = 0,
    this.isLoading = false,
    this.error = '',
    this.hasError = false,
    this.isAutoSwitching = false,
  });

  AIInsight? get currentInsight {
    if (insights.isEmpty || currentInsightIndex >= insights.length) {
      return null;
    }
    return insights[currentInsightIndex];
  }

  InsightsState copyWith({
    List<AIInsight>? insights,
    int? currentInsightIndex,
    bool? isLoading,
    String? error,
    bool? hasError,
    bool? isAutoSwitching,
  }) {
    return InsightsState(
      insights: insights ?? this.insights,
      currentInsightIndex: currentInsightIndex ?? this.currentInsightIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasError: hasError ?? this.hasError,
      isAutoSwitching: isAutoSwitching ?? this.isAutoSwitching,
    );
  }
}

// ==============================================================================
// NOTIFIER
// ==============================================================================

class InsightsNotifier extends StateNotifier<InsightsState> {
  final AIService? _aiService;
  final String? _userId;
  Timer? _autoSwitchTimer;
  static const Duration _autoSwitchInterval = Duration(seconds: 8);

  InsightsNotifier(this._aiService, this._userId) : super(const InsightsState());

  // Factory constructor for uninitialized state
  factory InsightsNotifier._uninitialized() {
    return InsightsNotifier(null, null);
  }

  /// Load insights from the API (or use fallback demo insights)
  Future<void> loadInsights() async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, error: '', hasError: false);

      List<AIInsight> insights;

      // If no services are wired up, use fallback insights for demo
      if (_aiService == null || _userId == null) {
        insights = List<AIInsight>.from(_fallbackInsights);
      } else {
        // Fetch real insights from API
        insights = await _aiService.getInsights(_userId);
      }

      if (insights.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No insights available',
          hasError: true,
        );
        return;
      }

      state = state.copyWith(
        insights: insights,
        currentInsightIndex: 0,
        isLoading: false,
        hasError: false,
      );

      // Start auto-switching after loading
      startAutoSwitch();
    } catch (e) {
      // Fallback to demo insights if API fails
      try {
        final insights = List<AIInsight>.from(_fallbackInsights);
        state = state.copyWith(
          insights: insights,
          currentInsightIndex: 0,
          isLoading: false,
          hasError: false,
        );
        startAutoSwitch();
      } catch (fallbackError) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
          hasError: true,
        );
      }
    }
  }

  /// Start auto-switching insights
  void startAutoSwitch() {
    if (state.isAutoSwitching || state.insights.isEmpty) return;

    state = state.copyWith(isAutoSwitching: true);

    _autoSwitchTimer?.cancel();
    _autoSwitchTimer = Timer.periodic(_autoSwitchInterval, (_) {
      nextInsight();
    });
  }

  /// Stop auto-switching insights
  void stopAutoSwitch() {
    _autoSwitchTimer?.cancel();
    _autoSwitchTimer = null;
    state = state.copyWith(isAutoSwitching: false);
  }

  /// Move to the next insight
  void nextInsight() {
    if (state.insights.isEmpty) return;

    final nextIndex = (state.currentInsightIndex + 1) % state.insights.length;
    state = state.copyWith(currentInsightIndex: nextIndex);
  }

  /// Move to the previous insight
  void previousInsight() {
    if (state.insights.isEmpty) return;

    final prevIndex = state.currentInsightIndex == 0
        ? state.insights.length - 1
        : state.currentInsightIndex - 1;
    state = state.copyWith(currentInsightIndex: prevIndex);
  }

  /// Jump to a specific insight by index
  void goToInsight(int index) {
    if (index < 0 || index >= state.insights.length) return;
    state = state.copyWith(currentInsightIndex: index);
  }

  @override
  void dispose() {
    _autoSwitchTimer?.cancel();
    super.dispose();
  }
}

// ==============================================================================
// PROVIDERS
// ==============================================================================

// Provider for AIService - implement this in your main app
final aiServiceProvider = Provider<AIService?>((ref) {
  // TODO: Wire up AIService from your DI container
  // Example:
  // final dio = ref.watch(dioProvider);
  // final localStorage = ref.watch(localStorageServiceProvider);
  // return AIService(dio, localStorage);
  return null;
});

// Provider for current user ID - implement this in your main app
final currentUserIdProvider = Provider<String?>((ref) {
  // TODO: Wire up current user ID from your auth provider
  // Example:
  // final auth = ref.watch(authProvider);
  // return auth.user?.id;
  return null;
});

// Insights state notifier provider
final insightsProvider =
    StateNotifierProvider<InsightsNotifier, InsightsState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  // Return an uninitialized state if dependencies are missing
  if (aiService == null || userId == null) {
    return InsightsNotifier._uninitialized();
  }
  
  return InsightsNotifier(aiService, userId);
});

// Current insight provider
final currentInsightProvider = Provider<AIInsight?>((ref) {
  final state = ref.watch(insightsProvider);
  return state.currentInsight;
});

// Auto-switch status provider
final isAutoSwitchingProvider = Provider<bool>((ref) {
  final state = ref.watch(insightsProvider);
  return state.isAutoSwitching;
});
