import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_first_app/accessibility_model.dart';
import 'home_page.dart';

  void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AccessibilitySettings(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "LearnAbility",
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(useMaterial3: false),
      home: const HomePage(),
      // home: SplashScreen(),
    );
  }
}
