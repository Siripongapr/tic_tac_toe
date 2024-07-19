import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/db/db.dart';
import 'package:tic_tac_toe/widget/game/cell.dart';
import 'package:tic_tac_toe/widget/game/scrore.dart';
import 'package:tic_tac_toe/xo_icon.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final DatabaseService _databaseService = DatabaseService();
  int currentPlayer = 1;
  List<int?> board = List<int?>.filled(9, null);
  String? winner;
  List<int> scores = [0, 0, 0];
  List<int> moves = [];
  int xWins = 0;
  int oWins = 0;
  int draws = 0;
  bool _isLoading = true; // Add a loading flag

  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchScores();
  }

  Future<void> _fetchScores() async {
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

      setState(() {
        _isLoading = false; // Set loading to false once data is fetched
      });
    } catch (e) {
      print('Error fetching scores: $e');
      setState(() {
        _isLoading = false; // Set loading to false in case of an error
      });
    }
  }

  void handleTap(int index) {
    if (board[index] == null && winner == null) {
      setState(() {
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
      currentPlayer = 1;
      winner = null;
      moves = [];
    });
  }

  Future<void> replayGame(List<int> replayMoves) async {
    resetGame();
    for (var move in replayMoves) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
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
      });
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
      _fetchScores(); // Update scores after saving
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
      _fetchScores(); // Update scores after deletion
    } catch (e) {
      print('Error deleting replays: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 70.0, bottom: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [XO(text: 'X'), Text('$xWins Wins')],
                ),
                Column(
                  children: [XO(text: 'O'), Text('$oWins Wins')],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.balance,
                      size: 50,
                    ),
                    Text('$draws Draws')
                  ],
                )
              ],
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _databaseService.getReplays(),
                builder: (context, snapshot) {
                  if (_isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No replays found'));
                  }

                  final replays = snapshot.data!;

                  return ListView.builder(
                    itemCount: replays.length,
                    itemBuilder: (context, index) {
                      final replay = replays[index];

                      final moves =
                          List<int>.from(replay['moves'] as List<dynamic>);

                      return ListTile(
                        title: Text('Replay ${index + 1}'),
                        subtitle: Text('Moves: ${moves.join(', ')}'),
                        trailing: Text('Winner: ${replay['winner']}'),
                        onTap: () async {
                          this.moves.clear();
                          this.moves.addAll(moves);

                          await replayGame(moves);
                        },
                      );
                    },
                  );
                },
              ),
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
              onPressed: () async {
                bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm'),
                        content: const Text(
                            'Are you sure you want to delete all replays?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete All'),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (confirm) {
                  await deleteAllReplays();
                }
              },
              child: const Text('Reset All Replays'),
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
