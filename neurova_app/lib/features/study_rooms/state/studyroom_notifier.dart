import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../services/studyroom_service.dart';
import '../models/studyroom_module.dart';
import '../../auth/state/auth_notifier.dart' show localStorageServiceProvider;
import '../../../shared/services/Socket_service.dart';
import '../../../core/constants/app_constants.dart';

class StudyRoomState {
  final StudyRoom? activeRoom;
  final List<StudyRoom> recentRooms;
  final bool isLoading;
  final String? error;
  final String? closureMessage;

  StudyRoomState({
    this.activeRoom,
    this.recentRooms = const [],
    this.isLoading = false,
    this.error,
    this.closureMessage,
  });

  StudyRoomState copyWith({
    StudyRoom? activeRoom,
    List<StudyRoom>? recentRooms,
    bool? isLoading,
    String? error,
    bool clearActiveRoom = false,
    String? closureMessage,
    bool clearClosureMessage = false,
  }) {
    return StudyRoomState(
      activeRoom: clearActiveRoom ? null : activeRoom ?? this.activeRoom,
      recentRooms: recentRooms ?? this.recentRooms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      closureMessage: clearClosureMessage ? null : closureMessage ?? this.closureMessage,
    );
  }
}

final studyRoomServiceProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
  final localStorage = ref.watch(localStorageServiceProvider);
  return StudyRoomService(dio, localStorage);
});

final studyRoomNotifierProvider = StateNotifierProvider<StudyRoomNotifier, StudyRoomState>((ref) {
  ref.keepAlive(); // Keep state alive across tab navigation
  final studyRoomService = ref.watch(studyRoomServiceProvider);
  final socketService = ref.watch(socketServiceProvider);
  return StudyRoomNotifier(studyRoomService, socketService, ref);
});

class StudyRoomNotifier extends StateNotifier<StudyRoomState> {
  final StudyRoomService _studyRoomService;
  final SocketService _socketService;
  final Ref _ref;
  io.Socket? _socket;
  String? _currentUserId;
  String? _currentUsername;

  StudyRoomNotifier(this._studyRoomService, this._socketService, this._ref)
      : super(StudyRoomState()) {
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final localStorage = _ref.read(localStorageServiceProvider);
    _currentUserId = await localStorage.readUserId();
    _currentUsername = await localStorage.readUsername();
  }

  Future<void> _setupSocketForRoom(String roomid) async {
    _socket = await _socketService.getStudyRoomSocket();
    _socket?.emit('leave_room');
    _socket?.emit('join_room', roomid);

    _socket?.on('room:member-joined', (data) {
      if (state.activeRoom?.roomid == roomid) {
        final newMemberList = data['room']['studyroommember'] as List;
        final newMembers = newMemberList.map((m) => Participant.fromJson(m)).toList();
        final updatedRoom = state.activeRoom!.copyWith(participants: newMembers);
        state = state.copyWith(activeRoom: updatedRoom);
      }
    });

    _socket?.on('room:member-left', (data) {
      if (state.activeRoom?.roomid == roomid) {
        final username = data['username'] as String;
        final updatedParticipants = state.activeRoom!.participants
            .where((p) => p.username != username)
            .toList();
        final updatedRoom = state.activeRoom!.copyWith(participants: updatedParticipants);
        state = state.copyWith(activeRoom: updatedRoom);
      }
    });

    _socket?.on('session:start', (data) {
      if (state.activeRoom?.roomid == roomid) {
        final updatedRoom = state.activeRoom!.copyWith(isactive: true);
        state = state.copyWith(activeRoom: updatedRoom);
      }
    });

    _socket?.on('session:end', (data) {
      if (state.activeRoom?.roomid == roomid) {
        final message = data['message'] as String? ?? 'Session ended. Room is now closed.';
        state = state.copyWith(
          clearActiveRoom: true,
          closureMessage: message,
        );
      }
    });

    _socket?.on('room:closed', (data) {
      if (state.activeRoom?.roomid == roomid) {
        final message = data['message'] as String? ?? 'Room closed by owner.';
        state = state.copyWith(
          clearActiveRoom: true,
          closureMessage: message,
        );
      }
    });
  }

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

      List<Participant> fixedParticipants = List.from(room.participants);
      if (_currentUserId != null && _currentUsername != null) {
        bool ownerExists = fixedParticipants.any((p) => p.userid == _currentUserId);
        if (!ownerExists) {
          final ownerParticipant = Participant(
            userid: _currentUserId!,
            username: _currentUsername!,
            isowner: true,
            joinedat: DateTime.now(),
          );
          fixedParticipants.add(ownerParticipant);
        } else {
          for (int i = 0; i < fixedParticipants.length; i++) {
            if (fixedParticipants[i].userid == _currentUserId && !fixedParticipants[i].isowner) {
              fixedParticipants[i] = Participant(
                userid: fixedParticipants[i].userid,
                username: fixedParticipants[i].username,
                isowner: true,
                joinedat: fixedParticipants[i].joinedat,
              );
              break;
            }
          }
        }
      }

      final updatedRoom = room.copyWith(participants: fixedParticipants);
      await _setupSocketForRoom(updatedRoom.roomid);

      state = state.copyWith(
        activeRoom: updatedRoom,
        recentRooms: [updatedRoom, ...state.recentRooms],
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
      final updatedRoom = StudyRoom.fromJson(result['data'] as Map<String, dynamic>);

      List<Participant> fixedParticipants = List.from(updatedRoom.participants);
      if (_currentUserId != null && _currentUsername != null) {
        bool userExists = fixedParticipants.any((p) => p.userid == _currentUserId);
        if (!userExists) {
          final selfParticipant = Participant(
            userid: _currentUserId!,
            username: _currentUsername!,
            isowner: false,
            joinedat: DateTime.now(),
          );
          fixedParticipants.add(selfParticipant);
          updatedRoom.copyWith(participants: fixedParticipants);
        }
      }

      await _setupSocketForRoom(updatedRoom.roomid);
      state = state.copyWith(
        activeRoom: updatedRoom,
        recentRooms: [
          updatedRoom,
          ...state.recentRooms.where((r) => r.roomid != updatedRoom.roomid),
        ],
        isLoading: false,
      );
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('Unique constraint failed')) {
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: errorString);
      }
      rethrow;
    }
  }

  Future<void> joinRoomFromCard(StudyRoom room) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _studyRoomService.joinRoom(room.roomcode);
      final updatedRoom = StudyRoom.fromJson(result['data'] as Map<String, dynamic>);

      List<Participant> fixedParticipants = List.from(updatedRoom.participants);
      if (_currentUserId != null && _currentUsername != null) {
        bool userExists = fixedParticipants.any((p) => p.userid == _currentUserId);
        if (!userExists) {
          final selfParticipant = Participant(
            userid: _currentUserId!,
            username: _currentUsername!,
            isowner: false,
            joinedat: DateTime.now(),
          );
          fixedParticipants.add(selfParticipant);
          updatedRoom.copyWith(participants: fixedParticipants);
        }
      }

      await _setupSocketForRoom(updatedRoom.roomid);
      state = state.copyWith(
        activeRoom: updatedRoom,
        recentRooms: [updatedRoom, ...state.recentRooms],
        isLoading: false,
      );
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('Unique constraint failed')) {
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: errorString);
      }
      rethrow;
    }
  }

  Future<void> leaveRoom(String roomid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _studyRoomService.leaveRoom(roomid);
      _socket?.emit('leave_room');
      state = state.copyWith(clearActiveRoom: true, isLoading: false);
    } catch (e) {
      final errorString = e.toString();
      // For any error, just clear loading and rethrow
      state = state.copyWith(isLoading: false, error: errorString);
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
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> endSession(String roomid, {int? duration}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _studyRoomService.endSession(roomid, duration: duration);
      // The socket 'session:end' event will handle clearing the room and showing the message.
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

  void clearClosureMessage() {
    state = state.copyWith(clearClosureMessage: true);
  }

  bool isCurrentUserOwner(StudyRoom room) {
    if (_currentUserId == null) return false;
    for (final p in room.participants) {
      if (p.isowner) {
        return p.userid == _currentUserId;
      }
    }
    return false;
  }
}