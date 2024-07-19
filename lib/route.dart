import 'package:flutter/material.dart';
import 'package:tic_tac_toe/screens/game.dart';
import 'package:tic_tac_toe/screens/menu.dart';

class RouterScreen {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            settings: const RouteSettings(name: '/'),
            builder: (_) => const Menu());
      case '/game':
        return MaterialPageRoute(
            settings: const RouteSettings(name: '/game'),
            builder: (_) => const Game(
                  isAI: false,
                ));
      case '/gameWithAI':
        return MaterialPageRoute(
            settings: const RouteSettings(name: '/gameWithAI'),
            builder: (_) => const Game(
                  isAI: true,
                ));

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
