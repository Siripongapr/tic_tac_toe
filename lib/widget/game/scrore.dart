import 'package:flutter/material.dart';
import 'package:tic_tac_toe/xo_icon.dart';

class Score extends StatelessWidget {
  Score({super.key, required this.score});
  List<int> score = [0, 0, 0];
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [XO(text: 'X'), Text('${score[0].toString()} Wins')],
        ),
        Column(
          children: [XO(text: 'O'), Text('${score[1].toString()} Wins')],
        ),
        Column(
          children: [
            Icon(
              Icons.balance,
              size: 50,
            ),
            Text('${score[2].toString()} Draws')
          ],
        )
      ],
    );
  }
}
