import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart' show AppColors, AppTypography;
import '../../shared/widgets/unified_bottom_nav_bar.dart';

class StudyRoom {
  final String id;
  final String name;
  final String host;
  final String subject;
  final String focusMode;
  final List<String> participants;
  final int maxParticipants;
  final List<String> tags;
  final Duration elapsed;
  final bool isLive;

  StudyRoom({
    required this.id,
    required this.name,
    required this.host,
    required this.subject,
    required this.focusMode,
    required this.participants,
    this.maxParticipants = 10,
    required this.tags,
    required this.elapsed,
    this.isLive = true,
  });
}

class StudyRoomsPage extends StatefulWidget {
  const StudyRoomsPage({super.key});

  @override
  State<StudyRoomsPage> createState() => _StudyRoomsPageState();
}

class _StudyRoomsPageState extends State<StudyRoomsPage> {
  int _selectedNavIndex = 2; // Focus is at index 2
  final TextEditingController _searchController = TextEditingController();
  String _selectedFocusMode = 'All';
  StudyRoom? _activeRoom;

  late List<StudyRoom> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = [
      StudyRoom(
        id: '1',
        name: 'Algorithms Deep Dive',
        host: 'Sarah K.',
        subject: 'Computer Science',
        focusMode: 'Pomodoro',
        participants: ['SK', 'JL', 'PM', 'CW'],
        tags: ['#Algorithms', '#LeetCode', '#DataStructures'],
        elapsed: const Duration(minutes: 18, seconds: 34),
      ),
      StudyRoom(
        id: '2',
        name: 'UX Design Sprint',
        host: 'Amara T.',
        subject: 'Design',
        focusMode: 'Deep Work',
        participants: ['AT', 'YB'],
        tags: ['#Figma', '#UXResearch', '#Wireframing'],
        elapsed: const Duration(minutes: 35, seconds: 12),
      ),
      StudyRoom(
        id: '3',
        name: 'Calculus Problem Set',
        host: 'Mike J.',
        subject: 'Mathematics',
        focusMode: 'Flexible',
        participants: ['MJ', 'LH', 'NK'],
        tags: ['#Calculus', '#Integration', '#Derivatives'],
        elapsed: const Duration(minutes: 5, seconds: 48),
      ),
      StudyRoom(
        id: '4',
        name: 'History Essay Review',
        host: 'Emma R.',
        subject: 'History',
        focusMode: 'Pomodoro',
        participants: ['ER', 'TS'],
        tags: ['#Essay', '#WorldHistory', '#Analysis'],
        elapsed: const Duration(minutes: 22, seconds: 15),
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudyRoom> _getFilteredRooms() {
    return _rooms.where((room) {
      final matchesSearch = _searchController.text.isEmpty ||
          room.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          room.subject.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesMode =
          _selectedFocusMode == 'All' || room.focusMode == _selectedFocusMode;
      return matchesSearch && matchesMode;
    }).toList();
  }

  void _joinRoom(StudyRoom room) {
    setState(() {
      _activeRoom = room;
    });
  }

  void _leaveRoom() {
    setState(() {
      _activeRoom = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activeRoom != null) {
      return _buildActiveRoomView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Study\nRooms',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                height: 0.9,
                              ),
                            ),
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.purple,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.purple.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white, size: 28),
                              onPressed: () => _showCreateRoomDialog(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_rooms.fold(0, (sum, room) => sum + room.participants.length)} students studying now',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${_getFilteredRooms().length} rooms active · Live collab enabled',
                              style: AppTypography.body2.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search rooms, subjects, tags...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontFamily: 'Syne',
                          ),
                          prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.glassBackground,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: AppColors.glassBorderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: AppColors.glassBorderLight),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: ['All', 'Pomodoro', 'Deep Work', 'Flexible']
                              .map((mode) {
                            final selected = _selectedFocusMode == mode;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: FilterChip(
                                label: Text(mode),
                                selected: selected,
                                backgroundColor: AppColors.glassBackground,
                                selectedColor:
                                    AppColors.purple.withValues(alpha: 0.24),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? AppColors.purple
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                side: BorderSide(
                                  color: selected
                                      ? AppColors.purple.withValues(alpha: 0.5)
                                      : AppColors.glassBorderLight,
                                ),
                                onSelected: (value) {
                                  setState(() {
                                    _selectedFocusMode = mode;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._getFilteredRooms().map((room) => _buildRoomCard(room)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: UnifiedBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onNavItemTapped: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }

  Color _getColorForFocusMode(String focusMode) {
    switch (focusMode) {
      case 'Pomodoro':
        return AppColors.purple;
      case 'Deep Work':
        return AppColors.amber;
      case 'Flexible':
        return const Color(0xFFA2ADD0);
      default:
        return AppColors.amber;
    }
  }

  Widget _buildRoomCard(StudyRoom room) {
    final modeColor = _getColorForFocusMode(room.focusMode);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: modeColor.withValues(alpha: 0.2),
                  ),
                  child: Icon(Icons.grid_view, color: modeColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Syne',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Hosted by ${room.host}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Syne',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    room.focusMode,
                    style: TextStyle(
                      color: modeColor,
                      fontFamily: 'Syne',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: room.tags
                  .map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontFamily: 'Syne',
                        fontSize: 12,
                      ),
                    ),
                  ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Wrap(
                  spacing: -10,
                  children: room.participants.take(4).map((participant) {
                    final colors = [
                      Colors.purple,
                      Colors.orange,
                      Colors.pink,
                      Colors.cyan
                    ];
                    final index = room.participants.indexOf(participant);
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors[index % colors.length].withValues(alpha: 0.7),
                        border: Border.all(
                          color: const Color(0xFF13111A),
                          width: 2.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        participant,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 10),
                Text(
                  '${room.participants.length}/${room.maxParticipants} joined',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Syne',
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(Icons.timer, color: AppColors.textMuted, size: 15),
                const SizedBox(width: 5),
                Text(
                  '${room.elapsed.inMinutes}:${(room.elapsed.inSeconds % 60).toString().padLeft(2, '0')} elapsed',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontFamily: 'Syne',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _joinRoom(room),
                style: ElevatedButton.styleFrom(
                  backgroundColor: modeColor.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: modeColor.withValues(alpha: 0.4)),
                  ),
                ),
                child: Text(
                  'Join Room',
                  style: TextStyle(
                    color: modeColor,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoomDialog() {
    String roomName = '';
    String subject = '';
    String selectedMode = 'Deep Work';
    bool isPublic = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1C1A26),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              const Text(
                'Create Room',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          titlePadding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROOM NAME',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontFamily: 'Syne',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => roomName = value,
                  decoration: InputDecoration(
                    hintText: 'e.g. Algorithms Study Group',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontFamily: 'Syne'),
                ),
                const SizedBox(height: 16),
                Text(
                  'SUBJECT',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontFamily: 'Syne',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => subject = value,
                  decoration: InputDecoration(
                    hintText: 'e.g. Computer Science',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontFamily: 'Syne'),
                ),
                const SizedBox(height: 16),
                Text(
                  'FOCUS MODE',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontFamily: 'Syne',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Pomodoro', 'Deep Work', 'Flexible']
                      .map((mode) {
                        final modeColor = _getColorForFocusMode(mode);
                        return ChoiceChip(
                          label: Text(
                            mode,
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w600,
                              color: selectedMode == mode ? modeColor : AppColors.textSecondary,
                            ),
                          ),
                          selected: selectedMode == mode,
                          backgroundColor: Colors.white.withValues(alpha: 0.04),
                          selectedColor: modeColor.withValues(alpha: 0.2),
                          side: BorderSide(
                            color: selectedMode == mode
                                ? modeColor.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => selectedMode = mode);
                            }
                          },
                        );
                      })
                      .toList(),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.public, color: AppColors.success, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Public Room',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Syne',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Anyone can join',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontFamily: 'Syne',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isPublic,
                        onChanged: (value) {
                          setState(() => isPublic = value);
                        },
                        activeColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    if (roomName.isNotEmpty && subject.isNotEmpty) {
                      final newRoom = StudyRoom(
                        id: DateTime.now().toString(),
                        name: roomName,
                        host: 'You',
                        subject: subject,
                        focusMode: selectedMode,
                        participants: ['You'],
                        tags: ['#StudyGroup'],
                        elapsed: Duration.zero,
                      );
                      setState(() {
                        _rooms.insert(0, newRoom);
                        _activeRoom = newRoom;
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '🚀 Create & Join Room',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildActiveRoomView() {
    final room = _activeRoom!;
    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorderLight),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _leaveRoom,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Syne',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          room.subject,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Syne',
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Live',
                          style: TextStyle(
                            color: AppColors.success,
                            fontFamily: 'Syne',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'SHARED SESSION TIMER',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontFamily: 'Syne',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '35:15',
                            style: TextStyle(
                              color: AppColors.amber,
                              fontFamily: 'Syne',
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            room.focusMode,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Syne',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${room.participants.length} PARTICIPANTS',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontFamily: 'Syne',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                      children: room.participants.map((participant) {
                        final colors = [
                          Colors.purple,
                          Colors.orange,
                          Colors.pink,
                          Colors.cyan
                        ];
                        final index = room.participants.indexOf(participant);
                        final participantColor = colors[index % colors.length];
                        
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: participantColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: participantColor.withValues(alpha: 0.24),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: participantColor.withValues(alpha: 0.7),
                                      border: Border.all(
                                        color: participantColor.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      participant.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Syne',
                                      ),
                                    ),
                                  ),
                                  if (participant == 'You')
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.success,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF13111A),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                participant,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Syne',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                participant == 'You' ? '35:15' : '${28 + index}m',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Syne',
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(Icons.share_outlined, 'Share'),
                  _buildControlButton(Icons.exit_to_app, 'Exit',
                      color: const Color(0xFFF5576C)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label,
      {Color? color}) {
    return GestureDetector(
      onTap: label == 'Exit' ? _leaveRoom : () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (color ?? AppColors.textSecondary)
                  .withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color ?? AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.textSecondary,
              fontFamily: 'Syne',
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
