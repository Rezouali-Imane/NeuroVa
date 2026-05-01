import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../../shared/theme/app_theme.dart' show AppColors, AppTypography;
import '../models/ai_models.dart';
import '../services/ai_service.dart';
import '../state/ai_notifier.dart';
import '../../../shared/widgets/unified_bottom_nav_bar.dart';

enum _AITab { chat, agent, plans, knowledge }

class AIChatScreen extends StatefulWidget {
  final String userId;
  final AIService aiService;

  const AIChatScreen({
    super.key,
    required this.userId,
    required this.aiService,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AINotifier _notifier;
  late ValueNotifier<AIState> _stateNotifier;
  bool _isInitialized = false;
  bool _showConversation = false;
  _AITab _selectedTab = _AITab.chat;
  int _selectedNavIndex = 3; // AI is at index 3
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _voiceCallMode = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechReady = false;
  String _lastRecognizedWords = '';
  String _voicePersona = 'Balanced';
  String _voiceSpeedPreset = 'Normal';
  List<Map<String, dynamic>> _availableVoices = [];

  @override
  void initState() {
    super.initState();
    _notifier = AINotifier(widget.aiService, widget.userId);
    _stateNotifier = ValueNotifier<AIState>(
      AIState(
        messages: [],
        isLoading: false,
        error: '',
        hasError: false,
        memory: StudentMemory(data: {}),
        studyPlan: null,
        weaknessAnalysis: null,
        knowledgeBase: [],
        isSending: false,
      ),
    );
    
    // Listen to state changes
    _notifier.addListener((newState) {
      _stateNotifier.value = newState;
      _scrollToBottom();
    });

    _initializeChat();
    _initializeVoiceChat();
    _loadSavedVoiceSettings();
  }

  Future<void> _loadSavedVoiceSettings() async {
    final savedPersona = await _localStorageService.readAIVoicePersona();
    final savedSpeed = await _localStorageService.readAIVoiceSpeedPreset();

    if (!mounted) return;

    setState(() {
      if (savedPersona != null && savedPersona.isNotEmpty) {
        _voicePersona = savedPersona;
      }
      if (savedSpeed != null && savedSpeed.isNotEmpty) {
        _voiceSpeedPreset = savedSpeed;
      }
    });

    await _applyVoiceStyle();
  }

  Future<void> _initializeVoiceChat() async {
    _speechReady = await _speechToText.initialize(
      onStatus: (status) {
        final normalized = status.toLowerCase();
        if (normalized == 'listening') {
          if (mounted) setState(() => _isListening = true);
          return;
        }

        if (_isListening && mounted) {
          setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );

    await _flutterTts.awaitSpeakCompletion(true);

    final dynamic voices = await _flutterTts.getVoices;
    if (voices is List) {
      _availableVoices = voices
          .whereType<Map>()
          .map((v) => Map<String, dynamic>.from(v))
          .toList();
    }

    await _applyVoiceStyle();
  }

  double _speedRateForPreset(String preset) {
    switch (preset) {
      case 'Slow':
        return 0.40;
      case 'Fast':
        return 0.58;
      default:
        return 0.48;
    }
  }

  double _pitchForPersona(String persona) {
    switch (persona) {
      case 'Warm':
        return 0.92;
      case 'Energetic':
        return 1.08;
      case 'Mentor':
        return 0.86;
      default:
        return 1.0;
    }
  }

  Future<void> _applyVoiceStyle() async {
    await _flutterTts.setSpeechRate(_speedRateForPreset(_voiceSpeedPreset));
    await _flutterTts.setPitch(_pitchForPersona(_voicePersona));

    if (_availableVoices.isNotEmpty) {
      Map<String, dynamic>? preferred;

      if (_voicePersona == 'Warm') {
        preferred = _availableVoices.firstWhere(
          (v) => (v['name']?.toString().toLowerCase().contains('female') ?? false),
          orElse: () => _availableVoices.first,
        );
      } else if (_voicePersona == 'Mentor') {
        preferred = _availableVoices.firstWhere(
          (v) => (v['name']?.toString().toLowerCase().contains('male') ?? false),
          orElse: () => _availableVoices.first,
        );
      } else {
        preferred = _availableVoices.first;
      }

      final voiceName = preferred['name']?.toString();
      final voiceLocale = preferred['locale']?.toString();
      if (voiceName != null && voiceLocale != null) {
        await _flutterTts.setVoice({'name': voiceName, 'locale': voiceLocale});
      }
    }
  }

  Future<void> _showVoiceSettingsDialog() async {
    String draftPersona = _voicePersona;
    String draftSpeed = _voiceSpeedPreset;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Voice Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Persona'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Balanced', 'Warm', 'Energetic', 'Mentor']
                      .map(
                        (option) => ChoiceChip(
                          label: Text(option),
                          selected: draftPersona == option,
                          onSelected: (_) => setDialogState(() => draftPersona = option),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                const Text('Speed'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Slow', 'Normal', 'Fast']
                      .map(
                        (option) => ChoiceChip(
                          label: Text(option),
                          selected: draftSpeed == option,
                          onSelected: (_) => setDialogState(() => draftSpeed = option),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  setState(() {
                    _voicePersona = draftPersona;
                    _voiceSpeedPreset = draftSpeed;
                  });
                  await _localStorageService.saveAIVoicePersona(draftPersona);
                  await _localStorageService.saveAIVoiceSpeedPreset(draftSpeed);
                  await _applyVoiceStyle();
                  navigator.pop();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showChatHistorySheet() async {
    try {
      final history = await widget.aiService.getChatHistory(
        userId: widget.userId,
        limit: 100,
      );
      if (!mounted) return;

      final threads = _groupChatThreads(history);
      if (threads.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No chat history found yet.')),
        );
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return DraggableScrollableSheet(
            initialChildSize: 0.88,
            minChildSize: 0.6,
            maxChildSize: 0.96,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF120F1D),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chat history',
                                  style: AppTypography.headline2.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${threads.length} conversation${threads.length == 1 ? '' : 's'}',
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: threads.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final thread = threads[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              setState(() {
                                _selectedTab = _AITab.chat;
                                _showConversation = true;
                              });
                              _notifier.replaceMessages(thread.messages);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackgroundLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.glassBorderLight),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFC8B8E8), Color(0xFFA2ADD0)],
                                      ),
                                    ),
                                    child: const Icon(Icons.forum_outlined, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          thread.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.title2.copyWith(color: Colors.white, fontSize: 15),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          thread.preview,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${_formatRelativeTime(thread.updatedAt)} · ${thread.messages.length} messages',
                                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.chevron_right, color: Colors.white54),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chat history: $e')),
      );
    }
  }

  List<_ChatThreadPreview> _groupChatThreads(List<AIMessage> history) {
    final sorted = [...history]..sort((left, right) => left.timestamp.compareTo(right.timestamp));
    final threads = <_ChatThreadPreview>[];
    var current = <AIMessage>[];

    for (final message in sorted) {
      if (message.role == 'USER' && current.isNotEmpty) {
        threads.add(_buildThreadPreview(current));
        current = [];
      }
      current.add(message);
    }

    if (current.isNotEmpty) {
      threads.add(_buildThreadPreview(current));
    }

    return threads.reversed.toList();
  }

  _ChatThreadPreview _buildThreadPreview(List<AIMessage> messages) {
    final firstUser = messages.firstWhere(
      (message) => message.role == 'USER',
      orElse: () => messages.first,
    );
    final assistantReply = messages.firstWhere(
      (message) => message.role == 'ASSISTANT',
      orElse: () => firstUser,
    );

    return _ChatThreadPreview(
      title: _shortenThreadTitle(firstUser.content),
      preview: _normalizePreview(
        assistantReply.role == 'ASSISTANT' ? assistantReply.content : firstUser.content,
      ),
      updatedAt: messages.last.timestamp,
      messages: messages,
    );
  }

  String _shortenThreadTitle(String content) {
    final normalized = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return 'New chat';
    if (normalized.length <= 42) return normalized;
    return '${normalized.substring(0, 42).trimRight()}...';
  }

  String _normalizePreview(String content) {
    final normalized = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return 'No preview available';
    if (normalized.length <= 88) return normalized;
    return '${normalized.substring(0, 88).trimRight()}...';
  }

  String _formatRelativeTime(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
  }

  Future<void> _initializeChat() async {
    if (!_isInitialized) {
      await _notifier.loadMemory();
      _isInitialized = true;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    if (!_showConversation) {
      setState(() {
        _showConversation = true;
      });
    }
    await _notifier.sendMessage(content, directChat: true);
  }

  Future<void> _toggleVoiceCallMode() async {
    if (_voiceCallMode) {
      await _stopVoiceCallMode();
      return;
    }

    if (!_speechReady) {
      _speechReady = await _speechToText.initialize();
    }
    if (!_speechReady) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone is not available on this device.')),
        );
      }
      return;
    }

    try {
      setState(() {
        _voiceCallMode = true;
        _showConversation = true;
        _lastRecognizedWords = '';
      });

      await _notifier.connectVoiceCall();
      await _startListeningCycle();
    } catch (e) {
      if (mounted) {
        setState(() {
          _voiceCallMode = false;
          _isListening = false;
          _isSpeaking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice call unavailable: $e')),
        );
      }
    }
  }

  Future<void> _stopVoiceCallMode() async {
    setState(() {
      _voiceCallMode = false;
      _isListening = false;
      _isSpeaking = false;
    });
    await _speechToText.stop();
    await _flutterTts.stop();
    await _notifier.disconnectVoiceCall();
  }

  Future<void> _startListeningCycle() async {
    if (!_voiceCallMode || _isSpeaking) return;
    if (!_speechReady) return;

    _lastRecognizedWords = '';
    setState(() => _isListening = true);

    await _speechToText.listen(
      onResult: (result) async {
        if (mounted) {
          setState(() {
            _lastRecognizedWords = result.recognizedWords.trim();
          });
        }
        if (result.finalResult && _lastRecognizedWords.isNotEmpty) {
          await _speechToText.stop();
          if (mounted) setState(() => _isListening = false);
          await _handleVoiceTurn(_lastRecognizedWords);
        }
      },
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(minutes: 2),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> _handleVoiceTurn(String transcript) async {
    if (!_voiceCallMode) return;

    final before = _stateNotifier.value.messages.length;
    await _notifier.sendRealtimeVoiceTurn(transcript, directChat: true);

    final messages = _stateNotifier.value.messages;
    String? assistantReply;
    for (int i = messages.length - 1; i >= 0; i--) {
      final m = messages[i];
      if (m.role == 'ASSISTANT') {
        assistantReply = m.content;
        break;
      }
    }

    if (messages.length <= before || assistantReply == null || assistantReply.trim().isEmpty) {
      if (_voiceCallMode) await _startListeningCycle();
      return;
    }

    setState(() => _isSpeaking = true);
    await _flutterTts.speak(assistantReply);
    if (mounted) setState(() => _isSpeaking = false);

    if (_voiceCallMode) {
      await _startListeningCycle();
    }
  }

  Future<void> _interruptAndListenNow() async {
    if (!_voiceCallMode) return;
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
    await _startListeningCycle();
  }

  String _voiceStatus(AIState state) {
    if (!_voiceCallMode) return 'Voice off';
    if (_isListening) return 'Listening...';
    if (state.isSending) return 'Thinking...';
    if (_isSpeaking) return 'Speaking...';
    return 'Ready';
  }

  Future<void> _sendPresetPrompt(String prompt) async {
    _messageController.text = prompt;
    await _sendMessage();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    _messageController.dispose();
    _scrollController.dispose();
    _stateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AIState>(
      valueListenable: _stateNotifier,
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF13111A),
          body: Stack(
            children: [
              Positioned(
                left: -80,
                top: -120,
                child: Opacity(
                  opacity: 0.12,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x35A2ADD0), Color(0x1FB284BE), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -70,
                top: 340,
                child: Opacity(
                  opacity: 0.08,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x28F8B878), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildTopHeader(),
                    _buildModeTabs(),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          );
                          return FadeTransition(
                            opacity: curved,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.02, 0.03),
                                end: Offset.zero,
                              ).animate(curved),
                              child: child,
                            ),
                          );
                        },
                        child: _buildAnimatedBody(state),
                      ),
                    ),
                    if (state.hasError)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0x26F5576C),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x44F5576C)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFF5576C)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.error,
                                style: const TextStyle(color: Color(0xFFF5576C)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Color(0xFFF5576C)),
                              onPressed: () {
                                _notifier.clearError();
                              },
                            ),
                          ],
                        ),
                      ),
                    if (_selectedTab == _AITab.chat && _voiceCallMode)
                      _buildVoiceCallPanel(state),
                    if (_selectedTab == _AITab.chat) _buildInputBar(state),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFC8B8E8), Color(0xFFA2ADD0)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                'lib/features/onboarding/assets/logo.svg',
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Academic Assistant',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    color: Color(0xA5FFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '● Online · 3 docs indexed',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorderLight),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  color: AppColors.textSecondary,
                  onPressed: () {
                    setState(() {
                      _selectedTab = _AITab.chat;
                      _showConversation = false;
                    });
                    _messageController.clear();
                    _notifier.clearError();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.tune, size: 18),
                  color: AppColors.textSecondary,
                  onPressed: () => _showAIMenu(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorderLight),
        ),
        child: Row(
          children: [
            _buildTabButton(_AITab.chat, Icons.smart_toy_outlined, 'Chat'),
            _buildTabButton(_AITab.agent, Icons.psychology_outlined, 'Agent'),
            _buildTabButton(_AITab.plans, Icons.menu_book_outlined, 'Plans'),
            _buildTabButton(_AITab.knowledge, Icons.description_outlined, 'Knowledge'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(_AITab tab, IconData icon, String label) {
    final selected = _selectedTab == tab;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _selectedTab = tab;
            });
          },
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: selected ? AppColors.purple.withValues(alpha: 0.18) : Colors.transparent,
              border: Border.all(
                color: selected ? AppColors.purple.withValues(alpha: 0.5) : Colors.transparent,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: selected ? AppColors.white : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppColors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 560;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, compact ? 2 : 8, 16, compact ? 4 : 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How may I help\nyou today?',
                maxLines: 2,
                style: TextStyle(
                  fontFamily: 'Syne',
                  color: Colors.white,
                  fontSize: compact ? 38 : 42,
                  fontWeight: FontWeight.w800,
                  height: 0.95,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ask Neurova for study plans, explanations, task ideas, or document help.',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              SizedBox(height: compact ? 12 : 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _StatusPill(icon: Icons.auto_awesome_outlined, label: 'Neurova ready', tint: Color(0xFFC8B8E8)),
                  _StatusPill(icon: Icons.description_outlined, label: '3 docs indexed', tint: Color(0xFFF8B878)),
                  _StatusPill(icon: Icons.lock_outline, label: 'Private chat', tint: Color(0xFFA2ADD0)),
                ],
              ),
              SizedBox(height: compact ? 18 : 22),
              Text(
                'Quick prompts',
                style: AppTypography.label.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPromptChip('Study plan', () => _sendPresetPrompt('Make me a 7-day study plan.')),
                  _buildPromptChip('Quiz me', () => _sendPresetPrompt('Create a short quiz for me.')),
                  _buildPromptChip('Weak areas', _analyzeWeakness),
                  _buildPromptChip('Documents', _showUploadDialog),
                ],
              ),
              SizedBox(height: compact ? 18 : 22),
              Row(
                children: [
                  Text(
                    'Recent chats',
                    style: AppTypography.label.copyWith(color: AppColors.textMuted),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _showChatHistorySheet,
                    icon: const Icon(Icons.history_rounded, size: 16),
                    label: const Text('See chat history'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildHistoryLine(
                'Explain Newton’s laws simply',
                '2m ago',
                'Answered with a quick analogy and example.',
              ),
              const SizedBox(height: 10),
              _buildHistoryLine(
                'Build a 7-day revision plan',
                '18m ago',
                'Created a balanced schedule for three subjects.',
              ),
              const SizedBox(height: 10),
              _buildHistoryLine(
                'Find my weak topics',
                '1h ago',
                'Highlighted the topics that need more practice.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBody(AIState state) {
    return switch (_selectedTab) {
      _AITab.chat => KeyedSubtree(
          key: const ValueKey<String>('chat_view'),
          child: _buildChatDashboard(state),
        ),
      _AITab.agent => KeyedSubtree(
          key: const ValueKey<String>('agent_view'),
          child: _buildAgentTab(),
        ),
      _AITab.plans => KeyedSubtree(
          key: const ValueKey<String>('plans_view'),
          child: _buildPlansTab(),
        ),
      _AITab.knowledge => KeyedSubtree(
          key: const ValueKey<String>('knowledge_view'),
          child: _buildKnowledgeTab(state),
        ),
    };
  }

  Widget _buildChatDashboard(AIState state) {
    if (!_showConversation || state.messages.isEmpty) {
      return _buildEmptyState();
    }

    // Simple message list without frame
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      itemCount: state.messages.length,
      separatorBuilder: (context, index) {
        final current = state.messages[index];
        final next = state.messages[index + 1];
        final currentDate = DateUtils.dateOnly(current.timestamp);
        final nextDate = DateUtils.dateOnly(next.timestamp);
        if (currentDate == nextDate) {
          return const SizedBox(height: 8);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.glassBorderLight),
              ),
              child: Text(
                _formatDateLabel(current.timestamp),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return _buildChatMessage(message);
      },
    );
  }

  Widget _buildConversationHeader(int messageCount) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFC8B8E8), Color(0xFFA2ADD0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.forum_outlined, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conversation',
                style: AppTypography.title2.copyWith(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 3),
              Text(
                '$messageCount messages · dashboard styled',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.glassBorderLight),
          ),
          child: Text(
            _selectedTab.name.toUpperCase(),
            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundLight,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.glassBorderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(colors: [Color(0xFFC8B8E8), Color(0xFFA2ADD0)]),
                ),
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  'lib/features/onboarding/assets/logo.svg',
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Neurova Agent',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '● Idle — ready for a mission',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        color: Color(0xFFD8B77B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'LAUNCH MISSION',
          style: TextStyle(
            fontFamily: 'Syne',
            color: Color(0xFF7B768C),
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.03,
          children: [
            _launchMissionCard('🗓️', 'Optimize my week', 'Analyzes deadlines & schedules optimal sessions', const [Color(0xFF171426), Color(0xFF1D1930)]),
            _launchMissionCard('🔍', 'Review weak areas', 'Scans notes & tasks to find knowledge gaps', const [Color(0xFF171426), Color(0xFF1D1930)]),
            _launchMissionCard('📋', 'Build study plan', 'Creates a full week schedule from your syllabus', const [Color(0xFF171426), Color(0xFF1D1930)]),
            _launchMissionCard('☀️', 'Daily digest', 'Summarizes progress & today’s priorities', const [Color(0xFF171426), Color(0xFF1D1930)]),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'ACTION FEED',
          style: TextStyle(
            fontFamily: 'Syne',
            color: Color(0xFF7B768C),
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _feedItem('Analyzed your focus patterns', '1h ago', AppColors.purple),
        const SizedBox(height: 10),
        _feedItem('Created task from overdue note', '47m ago', AppColors.amber),
      ],
    );
  }

  Widget _buildPlansTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        const Text(
          'AI-generated plans tailored to your goals and Knowledge\nBase.',
          style: TextStyle(
            fontFamily: 'Syne',
            color: Color(0xFF9A94A9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        _planCard(
          title: 'Algorithms\nMastery',
          subtitle: '7 days · Medium',
          gradient: const [Color(0xFFC8B8E8), Color(0xFFA2ADD0)],
          stats: const [('Duration', '7 days'), ('Sessions', '14'), ('Difficulty', 'Medium')],
        ),
        const SizedBox(height: 14),
        _planCard(
          title: 'System Design\nPrep',
          subtitle: '5 days · Hard',
          gradient: const [Color(0xFFF5EFC0), Color(0xFFF3C57D)],
          stats: const [('Duration', '5 days'), ('Sessions', '10'), ('Difficulty', 'Hard')],
        ),
        const SizedBox(height: 14),
        _planCard(
          title: 'UX Design Sprint',
          subtitle: '4 days · Easy',
          gradient: const [Color(0xFFC8B8E8), Color(0xFFC8A2C8)],
          stats: const [('Duration', '4 days'), ('Sessions', '8'), ('Difficulty', 'Easy')],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundLight,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.glassBorderLight),
          ),
          child: Row(
            children: [
              const Icon(Icons.add, color: Color(0xFFC8B8E8)),
              const SizedBox(width: 10),
              Text(
                'Generate Custom Plan with AI',
                style: AppTypography.title2.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeTab(AIState state) {
    final docs = state.knowledgeBase;
    final compactUploadCard = MediaQuery.of(context).size.height < 760;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Row(
          children: [
            Expanded(child: _statCard('3', 'Documents', const Color(0xFF241B2F))),
            const SizedBox(width: 10),
            Expanded(child: _statCard('3', 'Indexed', const Color(0xFF18261C))),
            const SizedBox(width: 10),
            Expanded(child: _statCard('210', 'Total Pages', const Color(0xFF20212D))),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: compactUploadCard ? 176 : 188,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.purple.withValues(alpha: 0.28),
              style: BorderStyle.solid,
            ),
          ),
          child: CustomPaint(
            painter: _DashedBorderPainter(color: AppColors.purple.withValues(alpha: 0.24)),
            child: Padding(
              padding: EdgeInsets.all(compactUploadCard ? 14 : 18),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: compactUploadCard ? 52 : 58,
                        height: compactUploadCard ? 52 : 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: AppColors.cardBackgroundLight,
                        ),
                        child: const Icon(Icons.upload_outlined, color: Color(0xFFC8B8E8), size: 28),
                      ),
                      SizedBox(height: compactUploadCard ? 10 : 14),
                      Text('Upload Documents', style: AppTypography.title2.copyWith(color: Colors.white)),
                      SizedBox(height: compactUploadCard ? 4 : 6),
                      Text(
                        'Drag & drop PDFs, DOCX, or TXT files or tap to browse',
                        textAlign: TextAlign.center,
                        style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: compactUploadCard ? 8 : 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _FileTag('.PDF'),
                          _FileTag('.DOCX'),
                          _FileTag('.TXT'),
                          _FileTag('.MD'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'INDEXED DOCUMENTS',
          style: TextStyle(
            fontFamily: 'Syne',
            color: Color(0xFF7B768C),
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _docTile('Algorithms_Lecture_Notes.pdf', '2.4 MB · 48 pages · 72h ago', const Color(0xFF3A2954)),
        const SizedBox(height: 10),
        _docTile('Linear_Algebra_Chapter3.pdf', '1.1 MB · 22 pages · 24h ago', const Color(0xFF3A2954)),
        const SizedBox(height: 10),
        _docTile('System_Design_Handbook.pdf', '5.8 MB · 140 pages · 1h ago', const Color(0xFF3A2954)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.glassBorderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How it works', style: AppTypography.title2.copyWith(color: Colors.white)),
              const SizedBox(height: 10),
              Text(
                'Documents are automatically indexed when uploaded. Ask questions in chat or use the Knowledge tab to manage files.',
                style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        if (docs.isNotEmpty) const SizedBox(height: 14),
      ],
    );
  }

  Widget _statCard(String value, String label, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTypography.headline2.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _launchMissionCard(String icon, String title, String subtitle, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const Spacer(),
          Text(title, style: AppTypography.title2.copyWith(color: Colors.white, height: 1.05)),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, height: 1.2)),
        ],
      ),
    );
  }

  Widget _feedItem(String title, String time, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_chart_outlined, color: accent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.title2.copyWith(color: Colors.white, fontSize: 15)),
                const SizedBox(height: 2),
                Text(time, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 18),
        ],
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required List<(String, String)> stats,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.calculate_outlined, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headline2.copyWith(color: Colors.white, height: 0.95),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 16),
          Row(
            children: stats
                .map(
                  (s) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.$1, style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.78))),
                          const SizedBox(height: 6),
                          Text(s.$2, style: AppTypography.title2.copyWith(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _docTile(String title, String meta, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: accent.withValues(alpha: 0.18),
            ),
            child: Icon(Icons.description_outlined, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.title2.copyWith(color: Colors.white, fontSize: 15)),
                const SizedBox(height: 2),
                Text(meta, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.check_circle_outline, color: Colors.greenAccent.shade400, size: 18),
          const SizedBox(width: 10),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF4A1F3D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delete_outline, color: Color(0xFFF5576C), size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      labelStyle: TextStyle(color: AppColors.textSecondary, fontFamily: 'Syne', fontSize: 13),
      backgroundColor: AppColors.glassBackground,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: AppColors.glassBorderLight),
      ),
    );
  }

  Widget _buildHistoryLine(String title, String time, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.purple.withValues(alpha: 0.18),
            ),
            child: const Icon(Icons.forum_outlined, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title2.copyWith(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(time, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildInputBar(AIState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: state.isSending ? null : _toggleVoiceCallMode,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _voiceCallMode
                            ? AppColors.success.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _voiceCallMode
                              ? AppColors.success.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Icon(
                        Icons.mic_none,
                        size: 16,
                        color: _voiceCallMode ? AppColors.success : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Message Neurova...',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontFamily: 'Syne',
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Syne',
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      enabled: !state.isSending,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: IconButton(
              tooltip: 'Attach file',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.attach_file, color: AppColors.textSecondary, size: 18),
              onPressed: state.isSending ? null : _showUploadDialog,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.purple.withValues(alpha: 0.3),
              ),
            ),
            child: IconButton(
              tooltip: 'Send',
              icon: Icon(
                state.isSending ? Icons.hourglass_top : Icons.send,
                color: AppColors.purple,
                size: 18,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: state.isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(AIMessage message) {
    final isUser = message.role == 'USER';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            // Clean glassmorphism - subtle frosted effect
            color: isUser
                ? AppColors.purple.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUser
                  ? AppColors.purple.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.08),
              width: 0.8,
            ),
            // Minimal shadow for subtle depth
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact header
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isUser
                          ? AppColors.purple.withValues(alpha: 0.2)
                          : AppColors.purple.withValues(alpha: 0.16),
                    ),
                    child: Icon(
                      isUser ? Icons.person_outline : Icons.auto_awesome,
                      size: 14,
                      color: isUser ? AppColors.purple : const Color(0xFFC8B8E8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isUser ? 'You' : 'Neurova',
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      fontFamily: 'Syne',
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Clean message content
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontFamily: 'Syne',
                  fontSize: 14,
                  height: 1.5,
                ),
                child: isUser
                    ? Text(message.content)
                    : MarkdownBody(
                        data: message.content,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.88),
                            height: 1.5,
                          ),
                          code: TextStyle(
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            color: const Color(0xFFE0D7FF),
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          codeblockPadding: const EdgeInsets.all(12),
                          h1: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFC8B8E8),
                          ),
                          h2: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFC8B8E8),
                          ),
                          h3: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFA2ADD0),
                          ),
                          blockquote: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFFA2ADD0).withValues(alpha: 0.8),
                            fontStyle: FontStyle.italic,
                          ),
                          strong: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC8B8E8),
                          ),
                          em: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          listBullet: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.5,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateLabel(DateTime timestamp) {
    final now = DateTime.now();
    final date = DateUtils.dateOnly(timestamp);
    final today = DateUtils.dateOnly(now);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
  }

  String _formatMessageTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute ${isPm ? 'PM' : 'AM'}';
  }

  Widget _buildBottomNav() {
    return UnifiedBottomNavBar(
      selectedIndex: _selectedNavIndex,
      onNavItemTapped: (index) {
        setState(() {
          _selectedNavIndex = index;
        });
      },
    );
  }

  Future<void> _showStudyPlanDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Study Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Include Prayer Times (Faith Mode)'),
              value: false,
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notifier.generateStudyPlan();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeWeakness() async {
    await _notifier.analyzeWeakness();
  }

  Future<void> _showUploadDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Study Material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF File'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Text File'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAIMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 50, 0, 0),
      items: [
        PopupMenuItem(
          onTap: _showChatHistorySheet,
          child: const Text('See Chat History'),
        ),
        PopupMenuItem(
          onTap: _showVoiceSettingsDialog,
          child: const Text('Voice Settings'),
        ),
        PopupMenuItem(
          onTap: _showStudyPlanDialog,
          child: const Text('Study Plan'),
        ),
        PopupMenuItem(
          onTap: _analyzeWeakness,
          child: const Text('Analyze Weakness'),
        ),
        PopupMenuItem(
          child: const Text('View Documents'),
          onTap: () {
            // Navigate to knowledge base view
          },
        ),
        PopupMenuItem(
          child: const Text('Clear History'),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear Chat History'),
                content: const Text(
                    'Are you sure? This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await _notifier.clearChatHistory();
            }
          },
        ),
      ],
    );
  }

  Widget _buildVoiceCallPanel(AIState state) {
    final status = _voiceStatus(state);
    final canInterrupt = _isSpeaking || state.isSending;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening
                  ? const Color(0xFF57F5AA)
                  : _isSpeaking
                      ? const Color(0xFFA2ADD0)
                      : state.isSending
                          ? const Color(0xFFF8B878)
                          : const Color(0xFF666A80),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Call: $status',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (_lastRecognizedWords.isNotEmpty)
                  Text(
                    _lastRecognizedWords,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Syne',
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  '$_voicePersona • $_voiceSpeedPreset',
                  style: const TextStyle(
                    color: Color(0xFF9AA0B8),
                    fontFamily: 'Syne',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (canInterrupt)
            TextButton.icon(
              onPressed: _interruptAndListenNow,
              icon: const Icon(Icons.graphic_eq, size: 16),
              label: const Text('Interrupt'),
            )
          else
            TextButton.icon(
              onPressed: _startListeningCycle,
              icon: const Icon(Icons.mic, size: 16),
              label: const Text('Speak'),
            ),
        ],
      ),
    );
  }
}

class _FileTag extends StatelessWidget {
  final String label;

  const _FileTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color tint;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tint),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color;

    const dashWidth = 7.0;
    const dashSpace = 6.0;
    const radius = 28.0;

    final rect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(radius));
    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}

class _ChatThreadPreview {
  final String title;
  final String preview;
  final DateTime updatedAt;
  final List<AIMessage> messages;

  const _ChatThreadPreview({
    required this.title,
    required this.preview,
    required this.updatedAt,
    required this.messages,
  });
}
