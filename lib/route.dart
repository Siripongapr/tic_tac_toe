import 'package:flutter/material.dart';
import 'package:tic_tac_toe/menu.dart';

class RouterScreen {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/menu':
        return MaterialPageRoute(
            settings: const RouteSettings(name: '/menu'),
            builder: (_) => const Menu());

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
