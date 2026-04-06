import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import '../models/ai_models.dart';
import '../services/ai_service.dart';
import '../state/ai_notifier.dart';

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

  Future<void> _sendPresetPrompt(String prompt) async {
    _messageController.text = prompt;
    await _sendMessage();
  }

  @override
  void dispose() {
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
                    _buildInputBar(state),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
              _buildBottomNav(),
            ],
          ),
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
                colors: [Color(0xFFB284BE), Color(0xFFA2ADD0)],
              ),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
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
                    color: Color(0x99FFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '● Online · 3 docs indexed',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    color: Color(0xAAFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2A2440)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  color: Colors.white70,
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
                  color: Colors.white70,
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
          color: const Color(0xFF1A1628),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2440)),
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: selected ? const Color(0x332D9CDB) : Colors.transparent,
              border: Border.all(
                color: selected ? const Color(0x66B284BE) : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: selected ? const Color(0xFFB284BE) : Colors.white54),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? const Color(0xFFB284BE) : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabPlaceholder() {
    final title = switch (_selectedTab) {
      _AITab.agent => 'Agent tools are available in chat.',
      _AITab.plans => 'Tap Study Plan to generate a schedule.',
      _AITab.knowledge => 'Upload notes to use document-aware AI answers.',
      _ => '',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 42, color: Color(0xFFB284BE)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontFamily: 'Syne'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedTab = _AITab.chat;
                });
              },
              child: const Text('Open Chat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 560;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, compact ? 4 : 8, 16, compact ? 4 : 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How may I help you today?',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              SizedBox(height: compact ? 10 : 14),
              _buildActionCard(
                icon: '🗓️',
                title: 'Study Plan',
                subtitle: 'Build your schedule',
                gradient: const [Color(0xFFB284BE), Color(0xFFA2ADD0)],
                onTap: _showStudyPlanDialog,
                compact: compact,
              ),
              SizedBox(height: compact ? 8 : 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        icon: '📝',
                        title: 'Quiz Me',
                        subtitle: 'Test your knowledge',
                        gradient: const [Color(0xFFA2ADD0), Color(0xFFC8A2C8)],
                        onTap: () => _sendPresetPrompt('Create a short quiz for me.'),
                        compact: compact,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionCard(
                        icon: '🔍',
                        title: 'Analyse',
                        subtitle: 'Find weak areas',
                        gradient: const [Color(0xFFF8B878), Color(0xFFECEBBD)],
                        onTap: _analyzeWeakness,
                        compact: compact,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 8 : 10),
              SizedBox(
                height: compact ? 96 : 104,
                width: 160,
                child: _buildActionCard(
                  icon: '⏱️',
                  title: 'Focus Tips',
                  subtitle: 'Study smarter',
                  gradient: const [Color(0xFFC8A2C8), Color(0xFFB284BE)],
                  onTap: () => _sendPresetPrompt('Give me focused study tips for today.'),
                  compact: compact,
                ),
              ),
              SizedBox(height: compact ? 8 : 12),
              _buildPromptRow(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBody(AIState state) {
    if (_selectedTab != _AITab.chat) {
      return KeyedSubtree(
        key: ValueKey<String>('tab_${_selectedTab.name}'),
        child: _buildTabPlaceholder(),
      );
    }

    if (!_showConversation || state.messages.isEmpty) {
      return KeyedSubtree(
        key: const ValueKey<String>('home_view'),
        child: _buildEmptyState(),
      );
    }

    return KeyedSubtree(
      key: const ValueKey<String>('chat_view'),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final message = state.messages[index];
          return _buildChatMessage(message);
        },
      ),
    );
  }

  Widget _buildPromptRow() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPromptChip('🗓️ Study plan', () => _sendPresetPrompt('Make me a 7-day study plan.')),
          const SizedBox(width: 8),
          _buildPromptChip('🧠 Merge sort', () => _sendPresetPrompt('Explain merge sort simply with an example.')),
          const SizedBox(width: 8),
          _buildPromptChip('📝 Quiz me', () => _sendPresetPrompt('Quiz me on data structures.')),
          const SizedBox(width: 8),
          _buildPromptChip('🔍 Weak areas', _analyzeWeakness),
          const SizedBox(width: 8),
          _buildPromptChip('📎 Documents', _showUploadDialog),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: gradient),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: TextStyle(fontSize: compact ? 20 : 22)),
            SizedBox(height: compact ? 6 : 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 15 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: compact ? 11 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      labelStyle: const TextStyle(color: Colors.white70),
      backgroundColor: const Color(0xFF1A1628),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2A2440)),
      ),
    );
  }

  Widget _buildInputBar(AIState state) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13111A),
      ),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.32),
                  fontFamily: 'Syne',
                ),
                filled: true,
                fillColor: const Color(0xFF1A1628),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2A2440)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2A2440)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0x66B284BE)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              style: const TextStyle(color: Colors.white, fontFamily: 'Syne'),
              maxLines: null,
              enabled: !state.isSending,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: state.isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: Colors.white70),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.stars),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _buildChatMessage(AIMessage message) {
    final isUser = message.role == 'USER';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFFB284BE), Color(0xFFA2ADD0)],
                )
              : null,
          color: isUser ? null : const Color(0xFF1A1628),
          borderRadius: BorderRadius.circular(14),
          border: isUser
              ? null
              : Border.all(
                  color: const Color(0xFF2A2440),
                ),
        ),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: isUser
            ? Text(
                message.content,
                style: const TextStyle(color: Colors.white),
              )
            : MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 14, color: Colors.white70),
                  code: const TextStyle(
                    backgroundColor: Color(0xFF2A2440),
                    color: Color(0xFFE0E0E0),
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: const Color(0xFF1A1628),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A2440)),
                  ),
                  codeblockPadding: const EdgeInsets.all(12),
                  h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  h2: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  h3: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  blockquote: const TextStyle(fontSize: 13, color: Color(0xFFA2ADD0)),
                  em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70),
                  strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  listBullet: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 14,
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: const Color(0xF40E0B16),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: const [
            BoxShadow(color: Color(0x7F000000), blurRadius: 20, offset: Offset(0, 4)),
            BoxShadow(color: Color(0xBF000000), blurRadius: 60, offset: Offset(0, 20)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _navItem(Icons.home_outlined, 'Home', false, () => context.go('/home'))),
            Expanded(child: _navItem(Icons.check_box_outlined, 'Tasks', false, _showComingSoon)),
            Expanded(child: _navItem(Icons.timer_outlined, 'Focus', false, _showComingSoon)),
            Expanded(child: _navItem(Icons.auto_awesome_outlined, 'AI', true, () {})),
            Expanded(child: _navItem(Icons.person_outline, 'Profile', false, () => context.go('/profile'))),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? const Color(0x14C8A2C8) : Colors.transparent,
          border: Border.all(
            color: selected ? const Color(0x24C8A2C8) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? const Color(0xFFC8A2C8) : Colors.white.withValues(alpha: 0.50),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 8,
                  height: 1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? const Color(0xFFC8A2C8) : Colors.white.withValues(alpha: 0.50),
                  letterSpacing: 0.20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This section will be connected next.')),
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
}
