import 'package:flutter/material.dart';
import 'package:tic_tac_toe/xo_icon.dart';

class Score extends StatelessWidget {
  const Score({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [XO(text: 'X'), Text('0 Wins')],
        ),
        Column(
          children: [XO(text: 'O'), Text('0 Wins')],
        ),
        Column(
          children: [
            Icon(
              Icons.balance,
              size: 50,
            ),
            Text('0 Draws')
          ],
        )
      ],
    );
  }
}
