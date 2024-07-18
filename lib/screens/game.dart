import 'package:flutter/material.dart';
import 'package:tic_tac_toe/widget/game/cell.dart';
import 'package:tic_tac_toe/widget/game/scrore.dart';

import 'package:tic_tac_toe/xo_icon.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  int currentPlayer = 1;
  List<int?> board = List<int?>.filled(9, null);
  String? winner;
  List<int> scores = [0, 0, 0];
  List<Map<String, int>> moves = [];

  void handleTap(int index) {
    if (board[index] == null && winner == null) {
      setState(() {
        board[index] = currentPlayer;
        moves.add({'player': currentPlayer, 'index': index});

        if (checkWin()) {
          winner = currentPlayer == 1 ? 'X' : 'O';
          scores[currentPlayer - 1]++;
        } else if (!board.contains(null)) {
          winner = 'Draw';
          scores[2]++;
        } else {
          currentPlayer = currentPlayer == 1 ? 2 : 1;
        }
      });
    }
  }

  bool checkWin() {
    const List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];

    for (var combo in winningCombinations) {
      if (board[combo[0]] != null &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]]) {
        return true;
      }
    }
    return false;
  }

  void resetGame() {
    setState(() {
      board = List<int?>.filled(9, null);
      print(board);
      currentPlayer = 1;
      winner = null;
    });
  }

  Future<void> replayGame() async {
    resetGame();
    for (var move in moves) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        board[move['index']!] = move['player'];
        currentPlayer = move['player'] == 1 ? 2 : 1;
      });
    }
    if (checkWin()) {
      winner = currentPlayer == 1 ? 'X' : 'O';
    } else if (!board.contains(null)) {
      winner = 'Draw';
    } else {
      currentPlayer = currentPlayer == 1 ? 2 : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Score(
              score: scores,
            ),
            const Spacer(),
            if (winner != null)
              Text(
                winner == 'Draw' ? 'It\'s a Draw!' : '$winner Wins!',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CustomPaint(
                    painter: TicTacToePainter(),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return TicTacToeCell(
                          index: index,
                          player: board[index],
                          onTap: () => handleTap(index),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                XO(text: currentPlayer == 1 ? 'X' : 'O'),
                Text('Turn'),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: resetGame,
              child: const Text('Restart Game'),
            ),
            ElevatedButton(
              onPressed: replayGame,
              child: const Text('Replay Game'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.home,
                size: 50,
              ),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
