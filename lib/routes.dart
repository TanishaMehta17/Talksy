import 'package:flutter/material.dart';
import 'package:talksy/auth/screens/login.dart';
import 'package:talksy/auth/screens/register.dart';
import 'package:talksy/screens/homeScreen.dart';




Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case SignUpScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) =>  SignUpScreen(),
      );
      case LoginScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) =>  LoginScreen(),
      );
    case HomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const HomeScreen(
        ),
      );
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${routeSettings.name}'),
          ),
        ),
      );
  }
}
