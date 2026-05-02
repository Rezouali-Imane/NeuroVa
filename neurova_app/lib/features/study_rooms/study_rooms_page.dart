import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/app_theme.dart' show AppColors, AppTypography;
import '../../shared/widgets/unified_bottom_nav_bar.dart';
import './models/studyroom_module.dart';
import './state/studyroom_notifier.dart';

class StudyRoomsPage extends ConsumerStatefulWidget {
  const StudyRoomsPage({super.key});

  @override
  ConsumerState<StudyRoomsPage> createState() => _StudyRoomsPageState();
}

class _StudyRoomsPageState extends ConsumerState<StudyRoomsPage> {
  int _selectedNavIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFocusMode = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(studyRoomNotifierProvider.notifier).fetchRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudyRoom> _getFilteredRooms(List<StudyRoom> rooms) {
    return rooms.where((room) {
      final matchesSearch = _searchController.text.isEmpty ||
          room.roomname
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          room.subject
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      final matchesMode =
          _selectedFocusMode == 'All' || room.focusmode == _selectedFocusMode;
      return matchesSearch && matchesMode;
    }).toList();
  }

  Future<void> _handleJoinRoom(StudyRoom room) async {
    try {
      await ref.read(studyRoomNotifierProvider.notifier).joinRoom(room.roomcode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined ${room.roomname}!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCreateRoom({
    required String roomname,
    required String subject,
    required String focusmode,
    required bool ispublic,
  }) async {
    try {
      await ref.read(studyRoomNotifierProvider.notifier).createRoom(
            roomname: roomname,
            subject: subject,
            focusmode: focusmode,
            ispublic: ispublic,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create room: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final studyRoomState = ref.watch(studyRoomNotifierProvider);
    final activeRoom = studyRoomState.activeRoom;
    final recentRooms = studyRoomState.recentRooms;

    if (activeRoom != null) {
      return _buildActiveRoomView(activeRoom);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: SafeArea(
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
                    '${recentRooms.fold(0, (sum, room) => sum + room.participants.length)} students studying now',
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
                          '${recentRooms.length} rooms available',
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
            if (studyRoomState.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFB284BE),
                    strokeWidth: 3,
                  ),
                ),
              )
            else if (studyRoomState.error != null)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0x33F5576C),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x66F5576C)),
                ),
                child: Text(
                  studyRoomState.error!,
                  style: const TextStyle(color: Color(0xFFF5576C), fontFamily: 'Syne'),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search rooms, subjects...',
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
                              selectedColor: AppColors.purple.withValues(alpha: 0.24),
                              labelStyle: TextStyle(
                                color: selected ? AppColors.purple : AppColors.textSecondary,
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
                    if (_getFilteredRooms(recentRooms).isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              const Icon(Icons.meeting_room_outlined,
                                  color: Color(0xFF7D749C), size: 42),
                              const SizedBox(height: 10),
                              Text(
                                'No rooms available',
                                style: AppTypography.headline3.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Create or join a study room',
                                style: AppTypography.body2.copyWith(
                                    color: const Color(0xFF8E88A8)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._getFilteredRooms(recentRooms)
                          .map((room) => _buildRoomCard(room)),
                  ],
                ),
              ),
          ],
        ),
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
    final modeColor = _getColorForFocusMode(room.focusmode);

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
                        room.roomname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Syne',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Hosted by ${room.ownername}',
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
                    color: room.isactive
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    room.isactive ? 'Live' : 'Open',
                    style: TextStyle(
                      color: room.isactive ? AppColors.success : AppColors.amber,
                      fontFamily: 'Syne',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.tag, color: AppColors.textMuted, size: 14),
                const SizedBox(width: 6),
                Text(
                  room.subject,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontFamily: 'Syne',
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(Icons.code, color: AppColors.textMuted, size: 14),
                const SizedBox(width: 6),
                Text(
                  room.roomcode,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontFamily: 'Syne',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
                        participant.username.substring(0, 2).toUpperCase(),
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
                  '${room.participants.length}/${room.maxparticipants} joined',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Syne',
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (!room.ispublic)
                  Icon(Icons.lock, color: AppColors.textMuted, size: 14),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleJoinRoom(room),
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
        builder: (context, setDialogState) => AlertDialog(
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
                  children: ['Pomodoro', 'Deep Work', 'Flexible'].map((mode) {
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
                          setDialogState(() => selectedMode = mode);
                        }
                      },
                    );
                  }).toList(),
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
                      Icon(isPublic ? Icons.public : Icons.lock, color: isPublic ? AppColors.success : AppColors.amber, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPublic ? 'Public Room' : 'Private Room',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Syne',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPublic ? 'Anyone can join' : 'Only with room code',
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
                          setDialogState(() => isPublic = value);
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
                      Navigator.pop(context);
                      _handleCreateRoom(
                        roomname: roomName,
                        subject: subject,
                        focusmode: selectedMode,
                        ispublic: isPublic,
                      );
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

  Widget _buildActiveRoomView(StudyRoom room) {
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
                      onPressed: () async {
                        try {
                          await ref
                              .read(studyRoomNotifierProvider.notifier)
                              .leaveRoom(room.roomid);
                        } catch (e) {
                          ref
                              .read(studyRoomNotifierProvider.notifier)
                              .clearActiveRoom();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.roomname,
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
                      color: room.isactive
                          ? AppColors.success.withValues(alpha: 0.18)
                          : AppColors.amber.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: room.isactive
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: room.isactive ? AppColors.success : AppColors.amber,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          room.isactive ? 'Live' : 'Waiting',
                          style: TextStyle(
                            color: room.isactive ? AppColors.success : AppColors.amber,
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
                            'SESSION CODE',
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
                            room.roomcode,
                            style: TextStyle(
                              color: AppColors.amber,
                              fontFamily: 'Syne',
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            room.focusmode,
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
                                      participant.username.substring(0, 2).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Syne',
                                      ),
                                    ),
                                  ),
                                  if (participant.isowner)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.amber,
                                      ),
                                      child: const Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                participant.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Syne',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
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
                  _buildControlButton(
                    Icons.play_arrow,
                    'Start Session',
                    color: AppColors.success,
                    onTap: () async {
                      await ref
                          .read(studyRoomNotifierProvider.notifier)
                          .startSession(room.roomid);
                    },
                  ),
                  _buildControlButton(
                    Icons.stop,
                    'End Session',
                    color: AppColors.amber,
                    onTap: () async {
                      await ref
                          .read(studyRoomNotifierProvider.notifier)
                          .endSession(room.roomid);
                    },
                  ),
                  _buildControlButton(
                    Icons.exit_to_app,
                    'Leave Room',
                    color: const Color(0xFFF5576C),
                    onTap: () async {
                      try {
                        await ref
                            .read(studyRoomNotifierProvider.notifier)
                            .leaveRoom(room.roomid);
                      } catch (e) {
                        ref.read(studyRoomNotifierProvider.notifier).clearActiveRoom();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    String label, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (color ?? AppColors.textSecondary).withValues(alpha: 0.12),
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