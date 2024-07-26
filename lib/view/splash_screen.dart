import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treegreens_task/controller/auth_service.dart';

import '../core/route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<String?> getUserIdFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    bool isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      String? userId = await getUserIdFromSharedPreferences();
      if (userId != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeRoute,
            arguments: {'userId': userId});
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0XFF1e319d),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/logo aca.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            Lottie.asset('assets/splash.json'),
            const SizedBox(height: 20),
            const Text(
              'Welcome to News App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your gateway to awesome features',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
