import 'package:flutter/material.dart';

import '../core/route.dart';
import '../core/route_manager.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Vinsup Digital',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splashRoute,
      onGenerateRoute: RouteManager.generateRoute,
    );
  }
}