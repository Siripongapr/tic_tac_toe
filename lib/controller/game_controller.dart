import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class GameController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  int currentPlayer = 1;
  List<int?> board = List<int?>.filled(9, null);
  String? winner;
  List<int> scores = [0, 0, 0];
  List<int> moves = [];
  int xWins = 0;
  int oWins = 0;
  int draws = 0;
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  void Function()? onStateChanged;

  GameController({this.onStateChanged});

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
      onStateChanged?.call();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching scores: $e');
      }
      _isLoading = false;
    }
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
        fetchScores();
      } else {
        currentPlayer = currentPlayer == 1 ? 2 : 1;
      }
      onStateChanged?.call();
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
    board = List<int?>.filled(9, null);
    currentPlayer = 1;
    winner = null;
    moves = [];
    onStateChanged?.call();
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
      onStateChanged?.call();
    }
  }

  void saveReplay() {
    db.collection("replays").add({
      "moves": moves,
      "winner": winner,
      "scores": scores,
      "timestamp": FieldValue.serverTimestamp()
    }).then((DocumentReference doc) {
      if (kDebugMode) {
        print('DocumentSnapshot added with ID: ${doc.id}');
      }
      fetchScores();
    }).catchError((error) {
      if (kDebugMode) {
        print('Failed to add document: $error');
      }
    });
  }

  Future<void> deleteAllReplays() async {
    try {
      final replays = await db.collection("replays").get();
      for (var doc in replays.docs) {
        await doc.reference.delete();
      }
      if (kDebugMode) {
        print('All replays deleted successfully');
      }
      fetchScores();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting replays: $e');
      }
    }
  }
}
