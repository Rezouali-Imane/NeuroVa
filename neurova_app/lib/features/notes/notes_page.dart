import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/theme/app_theme.dart' show AppColors, AppTypography;
import '../../shared/widgets/profile_view_shell.dart';
import '../../shared/widgets/unified_bottom_nav_bar.dart';
import './models/note_module.dart';
import './state/note_notifier.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  int _selectedNavIndex = 1;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notesNotifierProvider.notifier).fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>() ?? NeuropaColors.dark;
    final notesState = ref.watch(notesNotifierProvider);
    final notes = notesState.notes;


    final availableCategories = <String>{
      ...notes.map((note) => note.title.trim()).where((t) => t.isNotEmpty),
    };

    final categories = ['All'];

    final selectedCategory =
        categories.contains(_selectedCategory) ? _selectedCategory : 'All';

    final filteredNotes = notes.where((note) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          (note.content ?? '').toLowerCase().contains(query);
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ProfileViewShell(
        child: Stack(
          children: [
            Positioned(
              left: -140,
              top: -120,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.purple.withValues(alpha: 0.12), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -110,
              top: 320,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.periwinkle.withValues(alpha: 0.1), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                children: [
                  _buildHeader(
                    filteredVisible: filteredNotes.length,
                    total: notes.length,
                    nc: nc,
                  ),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 18),
                  if (notesState.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFB284BE),
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  else if (notesState.error != null)
                    _buildError(notesState.error!)
                  else if (notes.isEmpty)
                    _buildEmptyState()
                  else ...[
                    _buildSectionHeader(
                      label: 'ALL NOTES',
                      icon: Icons.menu_book_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildNotesGrid(filteredNotes, context),
                  ],
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required int filteredVisible,
    required int total,
    required NeuropaColors nc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '$total notes · $filteredVisible visible',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showCreateNoteSheet(context, nc),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.purple, AppColors.periwinkle],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 26),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'My Notes',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Syne',
            fontSize: 44,
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: -1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      style: AppTypography.body2.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search notes...',
        hintStyle: AppTypography.body2.copyWith(color: AppColors.textMuted),
        prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
        filled: true,
        fillColor: AppColors.cardBackgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.glassBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.glassBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.purple.withValues(alpha: 0.8)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 56),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, color: Color(0xFF7D749C), size: 42),
            const SizedBox(height: 10),
            Text(
              'No notes yet',
              style: AppTypography.headline3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to create your first note',
              style: AppTypography.body2.copyWith(color: const Color(0xFF8E88A8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x33F5576C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x66F5576C)),
      ),
      child: Text(
        error,
        style: const TextStyle(color: Color(0xFFF5576C), fontFamily: 'Syne'),
      ),
    );
  }

  Widget _buildSectionHeader({required String label, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.amber, size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesGrid(List<Note> notes, BuildContext context) {
    if (notes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1F867AAD)),
          color: const Color(0x110E0B18),
        ),
        child: Text(
          'Nothing here yet',
          style: AppTypography.body2.copyWith(color: const Color(0xFF7E7895)),
        ),
      );
    }

    return GridView.builder(
      itemCount: notes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.79,
      ),
      itemBuilder: (context, index) => _buildNoteCard(notes[index], context),
    );
  }

  Widget _buildNoteCard(Note note, BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>() ?? NeuropaColors.dark;
    final colorSeed = note.title.toLowerCase();
    final isWarm = colorSeed.contains('plan') ||
        colorSeed.contains('dev') ||
        colorSeed.contains('study') ||
        colorSeed.contains('task');

    final cardGradient = isWarm
        ? const [Color(0xFF2A1F16), Color(0xFF201822)]
        : const [Color(0xFF1A1830), Color(0xFF171324)];
    final badgeColor = isWarm ? const Color(0xFF5B4327) : const Color(0xFF3A2954);
    final badgeIconColor = isWarm ? const Color(0xFFE7C58E) : const Color(0xFFD4B6FF);

    return GestureDetector(
      onTap: () => _showNoteDetail(note, context, nc),
      onLongPress: () => _showNoteOptions(note, context, nc),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: cardGradient,
          ),
          border: Border.all(color: const Color(0xFF2D2941)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x42000000),
              blurRadius: 16,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_outlined,
                    color: badgeIconColor,
                    size: 16,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Color(0xFF6A6484), size: 12),
                    const SizedBox(width: 3),
                    Text(
                      _formatDate(note.createdat),
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF6A6484),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              note.title.isNotEmpty ? note.title : 'Untitled',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title2.copyWith(
                color: const Color(0xFFF4F1FF),
                fontWeight: FontWeight.w700,
                height: 1.24,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                note.content ?? '',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body2.copyWith(
                  color: const Color(0xFF8C86A8),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateNoteSheet(BuildContext context, NeuropaColors nc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: nc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CreateNoteSheet(
        onSubmit: (title, content) async {
          await ref.read(notesNotifierProvider.notifier).createNote(
            title: title.trim().isEmpty ? 'Untitled' : title.trim(),
            content: content.trim().isEmpty ? null : content.trim(),
          );
          if (!context.mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Note created'),
              backgroundColor: nc.lilacSurface,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showNoteDetail(Note note, BuildContext context, NeuropaColors nc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: nc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _NoteDetailSheet(
        note: note,
        onUpdate: (title, content) async {
          await ref.read(notesNotifierProvider.notifier).updateNote(
            noteId: note.noteid,
            title: title.trim().isEmpty ? 'Untitled' : title.trim(),
            content: content.trim().isEmpty ? null : content.trim(),
          );
          if (!context.mounted) return;
          Navigator.pop(context);
        },
        onDelete: () {
          Navigator.pop(context);
          _handleDeleteNote(note, context, nc);
        },
      ),
    );
  }

  void _showNoteOptions(Note note, BuildContext context, NeuropaColors nc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: nc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showNoteDetail(note, context, nc);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: nc.lilacSurface, size: 20),
                    const SizedBox(width: 16),
                    Text(
                      'Edit',
                      style: AppTypography.body2.copyWith(color: nc.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _handleDeleteNote(note, context, nc);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, color: Color(0xFFF5576C), size: 20),
                    const SizedBox(width: 16),
                    Text(
                      'Delete',
                      style: AppTypography.body2.copyWith(color: const Color(0xFFF5576C)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDeleteNote(Note note, BuildContext context, NeuropaColors nc) {
    ref.read(notesNotifierProvider.notifier).deleteNote(note.noteid);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = months[date.month - 1];
    final now = DateTime.now();
    if (date.year == now.year) return '$month ${date.day}';
    return '$month ${date.day}, ${date.year}';
  }

  Widget _buildBottomNav() {
    return UnifiedBottomNavBar(
      selectedIndex: _selectedNavIndex,
      onNavItemTapped: (index) => setState(() => _selectedNavIndex = index),
    );
  }
}



class _CreateNoteSheet extends StatefulWidget {
  final Future<void> Function(String title, String content) onSubmit;

  const _CreateNoteSheet({required this.onSubmit});

  @override
  State<_CreateNoteSheet> createState() => _CreateNoteSheetState();
}

class _CreateNoteSheetState extends State<_CreateNoteSheet> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>() ?? NeuropaColors.light;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Note',
            style: AppTypography.headline2.copyWith(color: nc.textPrimary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: AppTypography.body2.copyWith(color: nc.textPrimary),
            decoration: InputDecoration(
              hintText: 'Title',
              hintStyle: AppTypography.body2.copyWith(color: nc.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: nc.surfaceElevated),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 5,
            style: AppTypography.body2.copyWith(color: nc.textPrimary),
            decoration: InputDecoration(
              hintText: 'Content',
              hintStyle: AppTypography.body2.copyWith(color: nc.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: nc.surfaceElevated),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      await widget.onSubmit(
                        _titleController.text,
                        _contentController.text,
                      );
                      if (mounted) setState(() => _isLoading = false);
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: nc.lilacSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Text(
                        'Create',
                        textAlign: TextAlign.center,
                        style: AppTypography.body2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _NoteDetailSheet extends StatefulWidget {
  final Note note;
  final Future<void> Function(String title, String content) onUpdate;
  final VoidCallback onDelete;

  const _NoteDetailSheet({
    required this.note,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_NoteDetailSheet> createState() => _NoteDetailSheetState();
}

class _NoteDetailSheetState extends State<_NoteDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>() ?? NeuropaColors.light;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Note',
            style: AppTypography.headline2.copyWith(color: nc.textPrimary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: AppTypography.body2.copyWith(color: nc.textPrimary),
            decoration: InputDecoration(
              hintText: 'Title',
              hintStyle: AppTypography.body2.copyWith(color: nc.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: nc.surfaceElevated),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 5,
            style: AppTypography.body2.copyWith(color: nc.textPrimary),
            decoration: InputDecoration(
              hintText: 'Content',
              hintStyle: AppTypography.body2.copyWith(color: nc.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: nc.surfaceElevated),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      'Delete',
                      textAlign: TextAlign.center,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          await widget.onUpdate(
                            _titleController.text,
                            _contentController.text,
                          );
                          if (mounted) setState(() => _isLoading = false);
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: nc.lilacSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : Text(
                            'Update',
                            textAlign: TextAlign.center,
                            style: AppTypography.body2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}