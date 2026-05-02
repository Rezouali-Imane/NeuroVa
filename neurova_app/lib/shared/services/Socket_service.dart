import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_storage_service.dart';
import '../../features/auth/state/auth_notifier.dart' show localStorageServiceProvider;

final socketServiceProvider = Provider((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return SocketService(localStorage);
});

class SocketService {
  final LocalStorageService _localStorage;
  IO.Socket? _studyRoomSocket;

  SocketService(this._localStorage);

  Future<String?> _getToken() async => await _localStorage.readAuthToken();

  Future<IO.Socket> getStudyRoomSocket() async {
    if (_studyRoomSocket != null && _studyRoomSocket!.connected) {
      return _studyRoomSocket!;
    }

    final token = await _getToken();
    _studyRoomSocket = IO.io(
      'http://localhost:3000/studyroom',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token ?? ''})
          .enableReconnection()
          .build(),
    );

    final completer = Completer<void>();
    _studyRoomSocket!.onConnect((_) {
      completer.complete();
    });
    _studyRoomSocket!.onConnectError((data) {
      completer.completeError('Socket connection error: $data');
    });
    _studyRoomSocket!.connect();

    await completer.future;
    return _studyRoomSocket!;
  }

  void dispose() {
    _studyRoomSocket?.disconnect();
    _studyRoomSocket?.dispose();
    _studyRoomSocket = null;
  }
}