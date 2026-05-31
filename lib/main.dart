import 'package:flutter/material.dart';
import 'screens/join_room_screen.dart';

void main() {
  runApp(const WhiteboardApp());
}

class WhiteboardApp extends StatelessWidget {
  const WhiteboardApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Realtime Whiteboard",
      theme: ThemeData.dark(),
      home: const JoinRoomScreen(),
    );
  }
}