import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? socket;

  final String SERVER_URL = "http://192.168.100.9:3000";

  bool isConnected = false;

  // ------------------ CONNECT ------------------
  void connect(String roomId, String username) {
    if (socket != null && socket!.connected) {
      print("Already connected. Reconnecting...");
      socket!.disconnect();
    }

    socket = IO.io(
      SERVER_URL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print("Connected to server");
      isConnected = true;

      socket!.emit("join-room", {
        "roomId": roomId,
        "username": username,
      });
    });

    socket!.onDisconnect((_) {
      print("Disconnected from server");
      isConnected = false;
    });

    socket!.onConnectError((data) {
      print("Connection Error: $data");
    });

    socket!.onError((data) {
      print("Socket Error: $data");
    });
  }

  // ------------------ STROKE ------------------
  void sendStroke(String roomId, Map<String, dynamic> data, String username) {
    if (socket == null || !socket!.connected) return;

    socket!.emit("stroke", {
      "roomId": roomId,
      "username": username,
      ...data,
    });
  }

  void onStroke(Function(dynamic) callback) {
    socket?.off("stroke");
    socket?.on("stroke", callback);
  }

  // ------------------ LOAD BOARD ------------------
  void onLoadBoard(Function(dynamic) callback) {
    socket?.off("load-strokes");
    socket?.on("load-strokes", callback);
  }

  // ------------------ CLEAR BOARD ------------------
  void clearBoard(String roomId) {
    socket?.emit("clear", {"roomId": roomId});
  }

  void onClear(Function callback) {
    socket?.off("clear");
    socket?.on("clear", (_) => callback());
  }

  // ------------------ USER EVENTS ------------------
  void onUserJoined(Function(dynamic) callback) {
    socket?.off("user-joined");
    socket?.on("user-joined", callback);
  }

  void onUserLeft(Function(dynamic) callback) {
    socket?.off("user-left");
    socket?.on("user-left", callback);
  }

  // ------------------ DRAWING STATUS ------------------
  void sendDrawingStatus(String roomId, bool isDrawing, String username) {
    socket?.emit("drawing-status", {
      "roomId": roomId,
      "username": username,
      "isDrawing": isDrawing,
    });
  }

  void onDrawingStatus(Function(dynamic) callback) {
    socket?.off("drawing-status");
    socket?.on("drawing-status", callback);
  }

  // ------------------ DISCONNECT ------------------
  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    isConnected = false;
  }
  void onUserList(Function(dynamic) callback) {
    socket?.off("user-list");
    socket?.on("user-list", callback);
  }

}

