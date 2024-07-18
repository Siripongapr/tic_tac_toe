import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
              Text("Tic Tac Toe"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [XO(text: 'X'), XO(text: 'O')],
              ),
              Text("Choose your play mode"),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/game');
                        },
                        child: Text('With a friend')),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: null, child: Text('With AI'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
