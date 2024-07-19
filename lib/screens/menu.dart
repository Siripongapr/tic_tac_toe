import 'package:flutter/material.dart';
import 'package:tic_tac_toe/xo_icon.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.3),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Tic Tac Toe"),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [XO(text: 'X'), XO(text: 'O')],
              ),
              const Text("Choose your play mode"),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/game');
                        },
                        child: const Text('With a friend')),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/gameWithAI');
                          },
                          child: Text('With AI'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
