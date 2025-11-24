import 'dart:async';
import 'dart:developer' show log;
import 'dart:io' show WebSocket;

typedef OnStatusChange = void Function(SocketStatus);

class AppSocket {
  AppSocket({
    required this.url,
    required this.onStatusChange,
    this.header,
  });
  final StreamController<String> controller =
      StreamController.broadcast(sync: true);
  WebSocket? _channel;
  final String url;
  final Map<String, String>? header;
  final OnStatusChange onStatusChange;

  Future<void> close() async {
    await controller.done;
    await _channel?.close();
    _channel = null;
    _log('close');
  }

  Future<void> init() async {
    _log('conecting...');
    onStatusChange(SocketStatus.connecting);
    _channel = await _connectToSocket();
    onStatusChange(SocketStatus.connect);
    _log('socket connection initializied');
    await _channel!.done.then(_thenDone);
    _channel!.listen(_listen, onDone: _onDone, onError: _onError);
  }

  void _thenDone(value) {
    if (_channel == null) return;
    _log('then done');
    init();
  }

  void _listen(dynamic data) {
    _log('WebSocket Data: $data');
    //! potantial error
    controller.add(data as String);
  }

  void _onError(dynamic e) {
    onStatusChange(SocketStatus.error);
    _log('Server error: $e');
    init();
  }

  void _onDone() {
    if (_channel == null) return;
    onStatusChange(SocketStatus.disconnect);
    _log('conecting aborted');
    init();
  }

  Future<WebSocket> _connectToSocket() async {
    try {
      return await WebSocket.connect(url, headers: header);
    } catch (e) {
      _log('Error! can not connect WS connectWs $e');
      await Future<void>.delayed(const Duration(seconds: 1));
      return _connectToSocket();
    }
  }

  void send(String data) {
    _log('Sended Data: $data');
    _channel!.add(data);
  }

  void _log(String message) => log(message, name: 'socket');
}

enum SocketStatus {
  init,
  connect,
  connecting,
  error,
  connectError,
  connectTimeout,
  disconnect
}
