// import 'package:tic_tac_toe/controller/game_controller.dart';

// class MinimaxAI {
//   final GameController _controller;

//   MinimaxAI(this._controller);

//   Future<int> makeMove() async {
//     List<int> bestMove = [];
//     int bestScore = -10000;

//     for (int i = 0; i < 9; i++) {
//       if (_controller.board[i] == null) {
//         _controller.board[i] = 2;
//         int score = await minimax(2, -10000, 10000);
//         _controller.board[i] = null;
//         if (score > bestScore) {
//           bestScore = score;
//           bestMove = [i];
//         } else if (score == bestScore) {
//           bestMove.add(i);
//         }
//       }
//     }

//     return Future.value(bestMove.first);
//   }

//   int minimax(int player, int alpha, int beta)  {
//     if (_controller.winner != null) {
//       if (_controller.winner == 'X') {
//         return 1;
//       } else if (_controller.winner == 'O') {
//         return -1;
//       } else {
//         return ;
//       }
//     }

//     List<int> bestMoves = [];
//     int bestScore = -10000;

//     for (int i = 0; i < 9; i++) {
//       if (_controller.board[i] == null) {
//         _controller.board[i] = player;
//         int score =  minimax(player == 1 ? 2 : 1, alpha, beta);
//         _controller.board[i] = null;
//         if (player == 1 && score > bestScore) {
//           bestScore = score;
//           bestMoves = [i];
//         } else if (player == 1 && score == bestScore) {
//           bestMoves.add(i);
//         } else if (player == 2 && score < bestScore) {
//           bestScore = score;
//           bestMoves = [i];
//         } else if (player == 2 && score == bestScore) {
//           bestMoves.add(i);sh
//         }

//         if (player == 1) alpha = max(alpha, score);
//         if (player == 2) beta = min(beta, score);
//         if (beta <= alpha) break;
//       }
//     }

//     return bestScore;
//   }

//   int max(int a, int b) => b > a ? b : a;

//   int min(int a, int b) => a < b ? a : b;
// }
