import 'package:flutter/material.dart';
import 'package:tic_tac_toe/xo_icon.dart';

class TicTacToeCell extends StatelessWidget {
  final int index;
  final int? player;
  final VoidCallback onTap;

  const TicTacToeCell({
    super.key,
    required this.index,
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          player == null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: player == null ? onTap : null,
        child: Container(
          decoration: const BoxDecoration(),
          child: Center(
            child: player != null ? XO(text: player == 1 ? 'X' : 'O') : null,
          ),
        ),
      ),
    );
  }
}

class TicTacToePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    double cellSize = size.width / 3;

    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(cellSize * i, 0),
        Offset(cellSize * i, size.height),
        paint,
      );
    }

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
