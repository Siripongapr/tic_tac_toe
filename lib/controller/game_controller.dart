import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameController {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final VoidCallback onStateChanged;

  GameController({required this.onStateChanged});

  int currentPlayer = 1;
  List<int?> board = List<int?>.filled(9, null);
  String? winner;
  List<int> scores = [0, 0, 0];
  List<int> moves = [];
  int xWins = 0;
  int oWins = 0;
  int draws = 0;
  bool _isLoading = true;
  bool isAI = false;
  bool get isLoading => _isLoading;

  Future<void> fetchScores() async {
    try {
      final replays = await db.collection("replays").get();
      xWins = 0;
      oWins = 0;
      draws = 0;
      for (var doc in replays.docs) {
        final data = doc.data();
        if (data['winner'] == 'X') {
          xWins++;
        } else if (data['winner'] == 'O') {
          oWins++;
        } else if (data['winner'] == 'Draw') {
          draws++;
        }
      }
      _isLoading = false;
    } catch (e) {
      print('Error fetching scores: $e');
      _isLoading = false;
    }
    onStateChanged();
  }

  void handleTap(int index) {
    if (board[index] == null && winner == null) {
      board[index] = currentPlayer;
      moves.add(index);
      if (checkWin()) {
        winner = currentPlayer == 1 ? 'X' : 'O';
        scores[currentPlayer - 1]++;
        saveReplay();
      } else if (!board.contains(null)) {
        winner = 'Draw';
        scores[2]++;
        saveReplay();
      } else {
        currentPlayer = currentPlayer == 1 ? 2 : 1;
        if (isAI) {
          if (currentPlayer == 2) {
            int? bestMove = findBestMove();
            if (bestMove != null) {
              handleTap(bestMove);
            }
          }
        }
      }
    }
    onStateChanged();
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
    board = List<int?>.filled(9, null);
    currentPlayer = 1;
    winner = null;
    moves = [];
    onStateChanged();
  }

  Future<void> replayGame(List<int> replayMoves) async {
    resetGame();
    for (var move in replayMoves) {
      await Future.delayed(const Duration(milliseconds: 500));
      board[move] = currentPlayer;
      if (checkWin()) {
        winner = currentPlayer == 1 ? 'X' : 'O';
        scores[currentPlayer - 1]++;
      } else if (!board.contains(null)) {
        winner = 'Draw';
        scores[2]++;
      } else {
        currentPlayer = currentPlayer == 1 ? 2 : 1;
      }
      onStateChanged();
    }
  }

  void saveReplay() {
    db.collection("replays").add({
      "moves": moves,
      "winner": winner,
      "scores": scores,
      "timestamp": FieldValue.serverTimestamp()
    }).then((DocumentReference doc) {
      print('DocumentSnapshot added with ID: ${doc.id}');
      fetchScores(); // Update scores after saving
    }).catchError((error) {
      print('Failed to add document: $error');
    });
  }

  Future<void> deleteAllReplays() async {
    try {
      final replays = await db.collection("replays").get();
      for (var doc in replays.docs) {
        await doc.reference.delete();
      }
      print('All replays deleted successfully');
      fetchScores(); // Update scores after deletion
    } catch (e) {
      print('Error deleting replays: $e');
    }
  }

  int? findBestMove() {
    int? bestMove;
    int bestValue = -1000;
    for (int i = 0; i < board.length; i++) {
      if (board[i] == null) {
        board[i] = 2; // AI's move
        int moveValue = minimax(board, 0, false, -1000, 1000);
        board[i] = null; // Undo move

        if (moveValue > bestValue) {
          bestValue = moveValue;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }

  int minimax(
      List<int?> board, int depth, bool isMaximizing, int alpha, int beta) {
    String? result = checkGameResult();
    if (result != null) {
      if (result == 'X') return -10;
      if (result == 'O') return 10;
      return 0; // Draw
    }

    if (isMaximizing) {
      int bestValue = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == null) {
          board[i] = 2; // AI's move
          int value = minimax(board, depth + 1, false, alpha, beta);
          board[i] = null; // Undo move
          bestValue = max(bestValue, value);
          alpha = max(alpha, bestValue);
          if (beta <= alpha) break; // Beta cut-off
        }
      }
      return bestValue;
    } else {
      int bestValue = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == null) {
          board[i] = 1; // Human's move
          int value = minimax(board, depth + 1, true, alpha, beta);
          board[i] = null; // Undo move
          bestValue = min(bestValue, value);
          beta = min(beta, bestValue);
          if (beta <= alpha) break; // Alpha cut-off
        }
      }
      return bestValue;
    }
  }

  String? checkGameResult() {
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
        return board[combo[0]] == 1 ? 'X' : 'O';
      }
    }
    if (board.contains(null)) return null; // Game is still ongoing
    return 'Draw'; // Board is full and no winner
  }
}
