import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/note_service.dart';
import '../models/note_module.dart';
import '../../auth/state/auth_notifier.dart' show localStorageServiceProvider;
import '../../../core/constants/app_constants.dart';

class NotesState {
  final List<Note> notes;
  final bool isLoading;
  final String? error;

  NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? error,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final notesServiceProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
  final localStorage = ref.watch(localStorageServiceProvider);
  return NotesService(dio, localStorage);
});

class NotesNotifier extends StateNotifier<NotesState> {
  final NotesService _notesService;
  final Ref _ref;

  NotesNotifier(this._notesService, this._ref) : super(NotesState());

  Future<void> fetchNotes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final localStorage = _ref.read(localStorageServiceProvider);
      final userId = (await localStorage.readUserId()) ?? 'user';
      final notes = await _notesService.getNotes(userId);
      state = state.copyWith(notes: notes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createNote({
    required String title,
    String? content,
  }) async {
    try {
      final localStorage = _ref.read(localStorageServiceProvider);
      final userId = (await localStorage.readUserId()) ?? 'user';
      final note = await _notesService.createNote(
        userId: userId,
        title: title,
        content: content,
      );
      state = state.copyWith(notes: [note, ...state.notes]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateNote({
    required String noteId,
    required String title,
    String? content,
  }) async {
    try {
      final note = await _notesService.updateNote(
        noteId: noteId,
        title: title,
        content: content,
      );
      final updatedNotes = state.notes
          .map((n) => n.noteid == noteId ? note : n)
          .toList();
      state = state.copyWith(notes: updatedNotes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _notesService.deleteNote(noteId);
      state = state.copyWith(
        notes: state.notes.where((n) => n.noteid != noteId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final notesNotifierProvider =
    StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  final notesService = ref.watch(notesServiceProvider);
  return NotesNotifier(notesService, ref);
});