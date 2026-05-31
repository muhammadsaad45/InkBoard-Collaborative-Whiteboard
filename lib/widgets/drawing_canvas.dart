import 'package:flutter/material.dart';
import '../models/stroke.dart';
import '../services/socket_service.dart';

class DrawingCanvas extends StatefulWidget {
  final Color initialColor;
  final double initialBrushSize;
  final String roomId;
  final String username;

  const DrawingCanvas({
    super.key,
    required this.roomId,
    required this.username,
    required this.initialColor,
    required this.initialBrushSize,
  });

  @override
  DrawingCanvasState createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  List<Stroke> strokes = [];
  List<Offset> currentPoints = [];

  List<String> users = [];
  Map<String, bool> drawingStatus = {};

  late Color selectedColor;
  late double brushSize;

  final SocketService socketService = SocketService();

  @override
  void initState() {
    super.initState();

    selectedColor = widget.initialColor;
    brushSize = widget.initialBrushSize;

    socketService.connect(widget.roomId, widget.username);

    // ✅ USER LIST (single source of truth)
    socketService.onUserList((data) {
      setState(() {
        users = List<String>.from(data);
      });
    });

    // ✅ USER LEFT
    socketService.onUserLeft((username) {
      setState(() {
        users.remove(username);
        drawingStatus.remove(username);
      });
    });

    // ✅ DRAWING STATUS
    socketService.onDrawingStatus((data) {
      setState(() {
        drawingStatus[data["username"]] = data["isDrawing"];
      });
    });

    // ✅ RECEIVE STROKES
    socketService.onStroke((data) {
      if (!mounted) return;
      setState(() {
        strokes.add(
          Stroke(
            points: (data["points"] as List)
                .map((p) => Offset(
              (p["x"] as num).toDouble(), // 🛠️ FIX: Forces 'int' to 'double'
              (p["y"] as num).toDouble(), // 🛠️ FIX: Forces 'int' to 'double'
            ))
                .toList(),
            color: Color(data["color"]),
            width: (data["width"] as num).toDouble(), // 🛠️ FIX: Cast to num then double
            username: data["username"] ?? "unknown",
          ),
        );
      });
    });



    // ✅ CLEAR BOARD
    socketService.onClear(() {
      setState(() {
        strokes.clear();
      });
    });

// ✅ LOAD PREVIOUS STROKES
    socketService.onLoadBoard((data) {
      if (!mounted) return;
      setState(() {
        strokes = (data as List).map((s) {
          return Stroke(
            points: (s["points"] as List)
                .map((p) => Offset(
              (p["x"] as num).toDouble(), // 🛠️ FIX
              (p["y"] as num).toDouble(), // 🛠️ FIX
            ))
                .toList(),
            color: Color(s["color"]),
            width: (s["width"] as num).toDouble(), // 🛠️ FIX
            username: s["username"] ?? "unknown",
          );
        }).toList();
      });
    });
  }

  void setColor(Color color) {
    selectedColor = color;
  }

  void setBrushSize(double size) {
    brushSize = size;
  }

  void startStroke(Offset point) {
    currentPoints = [point];

    socketService.sendDrawingStatus(
      widget.roomId,
      true,
      widget.username,
    );
  }

  void updateStroke(Offset point) {
    setState(() {
      currentPoints.add(point);
    });
  }

  void endStroke() {
    if (currentPoints.isEmpty) return;

    final stroke = Stroke(
      points: List.from(currentPoints),
      color: selectedColor,
      width: brushSize,
      username: widget.username,
    );

    setState(() {
      strokes.add(stroke);
      currentPoints.clear();
    });

    socketService.sendStroke(
      widget.roomId,
      {
        "points": stroke.points
            .map((p) => {"x": p.dx, "y": p.dy})
            .toList(),
        "color": stroke.color.value,
        "width": stroke.width,
      },
      widget.username,
    );

    socketService.sendDrawingStatus(
      widget.roomId,
      false,
      widget.username,
    );
  }

  void clearBoard() {
    setState(() {
      strokes.clear();
    });

    socketService.clearBoard(widget.roomId);
  }

  @override
  void dispose() {
    socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// CANVAS
        GestureDetector(
          onPanStart: (details) => startStroke(details.localPosition),
          onPanUpdate: (details) => updateStroke(details.localPosition),
          onPanEnd: (details) => endStroke(),
          child: CustomPaint(
            painter: CanvasPainter(
              strokes,
              currentPoints,
              selectedColor,
              brushSize,
            ),
            size: Size.infinite,
          ),
        ),

        /// USER LIST OVERLAY
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Users",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                ...users.map((user) {
                  final isDrawing = drawingStatus[user] ?? false;

                  return Text(
                    isDrawing ? "$user ✏️" : user,
                    style: const TextStyle(color: Colors.white),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 🎨 PAINTER
class CanvasPainter extends CustomPainter {
  final List<Stroke> strokes;
  final List<Offset> currentPoints;
  final Color currentColor;
  final double currentWidth;

  CanvasPainter(
      this.strokes,
      this.currentPoints,
      this.currentColor,
      this.currentWidth,
      );

  @override
  void paint(Canvas canvas, Size size) {
    /// DRAW OLD STROKES
    for (var stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(
          stroke.points[i],
          stroke.points[i + 1],
          paint,
        );
      }
    }

    /// DRAW CURRENT STROKE
    final paint = Paint()
      ..color = currentColor
      ..strokeWidth = currentWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < currentPoints.length - 1; i++) {
      canvas.drawLine(
        currentPoints[i],
        currentPoints[i + 1],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}