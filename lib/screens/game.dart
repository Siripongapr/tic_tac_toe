import 'package:flutter/material.dart';
import 'package:tic_tac_toe/controller/game_controller.dart';
import 'package:tic_tac_toe/widget/game/cell.dart';
import 'package:tic_tac_toe/xo_icon.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(onStateChanged: _updateState);
    _controller.fetchScores().then((_) {
      setState(() {});
    });
  }

  void _updateState() {
    setState(() {});
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
                  children: [const XO(text: 'X'), Text('${_controller.xWins} Wins')],
                ),
                Column(
                  children: [const XO(text: 'O'), Text('${_controller.oWins} Wins')],
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.balance,
                      size: 50,
                    ),
                    Text('${_controller.draws} Draws')
                  ],
                )
              ],
            ),
            ElevatedButton(
              onPressed: _showReplaysBottomSheet,
              child: const Text('Show Replays'),
            ),
            const Spacer(),
            if (_controller.winner != null)
              Text(
                _controller.winner == 'Draw'
                    ? 'It\'s a Draw!'
                    : '${_controller.winner} Wins!',
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
                          player: _controller.board[index],
                          onTap: () {
                            setState(() {
                              _controller.handleTap(index);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                XO(text: _controller.currentPlayer == 1 ? 'X' : 'O'),
                const Text('Turn'),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _controller.resetGame();
                });
              },
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
                  await _controller.deleteAllReplays();
                  setState(() {});
                }
              },
              child: const Text('Reset All Replays'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(
                Icons.home,
                size: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReplaysBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Replays',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _controller.db
                    .collection("replays")
                    .snapshots()
                    .map((snapshot) {
                  return snapshot.docs.map((doc) => doc.data()).toList();
                }),
                builder: (context, snapshot) {
                  if (_controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No replays found'));
                  }
                  final replays = snapshot.data!;
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: replays.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        final replay = replays[index];
                        final moves =
                            List<int>.from(replay['moves'] as List<dynamic>);
                        return ListTile(
                          title: Text('Replay ${index + 1}'),
                          subtitle: Text('Moves: ${moves.join(', ')}'),
                          trailing: Text('Winner: ${replay['winner']}'),
                          onTap: () async {
                            _controller.moves.clear();
                            _controller.moves.addAll(moves);
                            Navigator.of(context).pop();
                            await _controller.replayGame(moves);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
