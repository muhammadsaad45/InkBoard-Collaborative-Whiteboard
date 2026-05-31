import 'package:flutter/material.dart';
import '../widgets/drawing_canvas.dart';

class BoardScreen extends StatefulWidget {
  final String username;
  final String roomId;

  const BoardScreen({
    super.key,
    required this.username,
    required this.roomId,
  });

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  Color selectedColor = Colors.black;
  double brushSize = 4;

  final GlobalKey<DrawingCanvasState> canvasKey = GlobalKey();

  /// 🎨 IMPROVED COLOR BUTTON
  Widget colorButton(Color color) {
    final isSelected = selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
          canvasKey.currentState?.setColor(color);
        });
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: 8,
            )
          ]
              : [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1e293b), // softer dark

      appBar: AppBar(
        title: Text("Room: ${widget.roomId}"),
        centerTitle: true,
        backgroundColor: const Color(0xff0f172a),
        elevation: 0,
      ),

      body: Row(
        children: [

          /// 🎨 LEFT SIDEBAR TOOLBAR
          Container(
            width: 70,
            color: const Color(0xff111827),
            child: Column(
              children: [

                const SizedBox(height: 20),

                colorButton(Colors.black),
                colorButton(Colors.red),
                colorButton(Colors.blue),
                colorButton(Colors.green),
                colorButton(Colors.orange),
                colorButton(Colors.purple),
                colorButton(Colors.pink),
                colorButton(Colors.yellow),

                const SizedBox(height: 20),

                /// 🖌 BRUSH SIZE (ROTATED)
                RotatedBox(
                  quarterTurns: -1,
                  child: Slider(
                    value: brushSize,
                    min: 1,
                    max: 20,
                    activeColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        brushSize = value;
                        canvasKey.currentState?.setBrushSize(value);
                      });
                    },
                  ),
                ),

                const Spacer(),

                /// 🧹 CLEAR BUTTON
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.white,
                  tooltip: "Clear Board",
                  onPressed: () {
                    canvasKey.currentState?.clearBoard();
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          /// 🧾 CANVAS AREA
          Expanded(
            child: DrawingCanvas(
              key: canvasKey,
              roomId: widget.roomId,
              username: widget.username,
              initialColor: selectedColor,
              initialBrushSize: brushSize,
            ),
          ),
        ],
      ),
    );
  }
}