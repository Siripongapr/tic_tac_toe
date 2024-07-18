import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TicTacToeCell extends StatelessWidget {
  final int index;

  const TicTacToeCell({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (kDebugMode) {
            print('tapped ${index + 1}');
          }
        },
        child: Container(decoration: const BoxDecoration()));
  }
}

class TicTacToePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    double cellSize = size.width / 3;

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(cellSize * i, 0),
        Offset(cellSize * i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, cellSize * i),
        Offset(size.width, cellSize * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
