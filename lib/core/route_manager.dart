import 'package:flutter/material.dart';
import 'package:treegreens_task/core/route.dart';
import 'package:treegreens_task/view/home_screen.dart';

import '../view/login_screen.dart';
import '../view/registration_screen.dart';
import '../view/splash_screen.dart';

class InstantPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  InstantPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
}
class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splashRoute:
        return InstantPageRoute(page: const SplashScreen());
      case AppRoutes.loginRoute:
        return InstantPageRoute(page: const LoginScreen());
      case AppRoutes.registrationRoute:
        return InstantPageRoute(page: const SignUpScreen());
      case AppRoutes.homeRoute:
        final args = settings.arguments as Map<String, dynamic>;
        final userId = args['userId'] as String;
        return InstantPageRoute(page: HomeScreen(userId: userId));

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Unknown Route')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
