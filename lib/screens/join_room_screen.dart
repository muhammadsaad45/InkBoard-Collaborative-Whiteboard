import 'dart:math';
import 'package:flutter/material.dart';
import 'board_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {

  final nameController = TextEditingController();
  final roomController = TextEditingController();

  String generateRoomCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        5,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void createRoom() {

    String username = nameController.text.trim();

    if (username.isEmpty) return;

    String roomCode = generateRoomCode();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BoardScreen(
          username: username,
          roomId: roomCode,
        ),
      ),
    );
  }

  void joinRoom() {

    String username = nameController.text.trim();
    String roomCode = roomController.text.trim();

    if (username.isEmpty || roomCode.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BoardScreen(
          username: username,
          roomId: roomCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xff0f172a),

      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xff1e293b),
            borderRadius: BorderRadius.circular(16),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Realtime Whiteboard",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: createRoom,
                child: const Text("Create Room"),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: roomController,
                decoration: const InputDecoration(
                  labelText: "Room Code",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: joinRoom,
                child: const Text("Join Room"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}