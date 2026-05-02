import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/studyroom_service.dart';
import '../models/studyroom_module.dart';
import '../../auth/state/auth_notifier.dart' show localStorageServiceProvider;

class StudyRoomState {
  final StudyRoom? activeRoom;
  final List<StudyRoom> recentRooms;
  final bool isLoading;
  final String? error;

  StudyRoomState({
    this.activeRoom,
    this.recentRooms = const [],
    this.isLoading = false,
    this.error,
  });

  StudyRoomState copyWith({
    StudyRoom? activeRoom,
    List<StudyRoom>? recentRooms,
    bool? isLoading,
    String? error,
    bool clearActiveRoom = false,
  }) {
    return StudyRoomState(
      activeRoom: clearActiveRoom ? null : activeRoom ?? this.activeRoom,
      recentRooms: recentRooms ?? this.recentRooms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final studyRoomServiceProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
  final localStorage = ref.watch(localStorageServiceProvider);
  return StudyRoomService(dio, localStorage);
});

class StudyRoomNotifier extends StateNotifier<StudyRoomState> {
  final StudyRoomService _studyRoomService;
  final Ref _ref;

  StudyRoomNotifier(this._studyRoomService, this._ref) : super(StudyRoomState());

  Future<void> fetchRooms() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rooms = await _studyRoomService.getRooms();
      state = state.copyWith(
        recentRooms: rooms,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createRoom({
    required String roomname,
    required String subject,
    required String focusmode,
    required bool ispublic,
    int maxparticipants = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final room = await _studyRoomService.createRoom(
        roomname: roomname,
        subject: subject,
        focusmode: focusmode,
        maxparticipants: maxparticipants,
        ispublic: ispublic,
      );
      state = state.copyWith(
        activeRoom: room,
        recentRooms: [room, ...state.recentRooms],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> joinRoom(String roomcode) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _studyRoomService.joinRoom(roomcode);
      
      final room = StudyRoom(
        roomid: result['roomid']?.toString() ?? '',
        roomcode: roomcode,
        ownername: result['username']?.toString() ?? '',
        roomname: result['roomname']?.toString() ?? '',
        subject: '',
        focusmode: 'Deep Work',
        maxparticipants: 10,
        ispublic: true,
        isactive: false,
        participants: [],
        createdat: DateTime.now(),
      );
      
      state = state.copyWith(
        activeRoom: room,
        recentRooms: [room, ...state.recentRooms],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> leaveRoom(String roomid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _studyRoomService.leaveRoom(roomid);
      state = state.copyWith(clearActiveRoom: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> startSession(String roomid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _studyRoomService.startSession(roomid);
      
      if (state.activeRoom != null) {
        final updatedRoom = StudyRoom(
          roomid: state.activeRoom!.roomid,
          roomcode: state.activeRoom!.roomcode,
          ownername: state.activeRoom!.ownername,
          roomname: state.activeRoom!.roomname,
          subject: state.activeRoom!.subject,
          focusmode: state.activeRoom!.focusmode,
          maxparticipants: state.activeRoom!.maxparticipants,
          ispublic: state.activeRoom!.ispublic,
          isactive: true,
          participants: state.activeRoom!.participants,
          createdat: state.activeRoom!.createdat,
          startedat: result['startedat'] != null 
            ? DateTime.parse(result['startedat'].toString()) 
            : DateTime.now(),
        );
        state = state.copyWith(activeRoom: updatedRoom, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> endSession(String roomid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _studyRoomService.endSession(roomid);
      state = state.copyWith(clearActiveRoom: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void setActiveRoom(StudyRoom room) {
    state = state.copyWith(activeRoom: room);
  }

  void clearActiveRoom() {
    state = state.copyWith(clearActiveRoom: true);
  }
}

final studyRoomNotifierProvider =
    StateNotifierProvider<StudyRoomNotifier, StudyRoomState>((ref) {
  final studyRoomService = ref.watch(studyRoomServiceProvider);
  return StudyRoomNotifier(studyRoomService, ref);
});