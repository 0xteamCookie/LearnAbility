import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my_first_app/providers/auth_provider.dart';
import 'package:my_first_app/accessibility_model.dart';
import 'package:my_first_app/repository/screens/splash/splashscreen.dart';
import 'package:my_first_app/repository/screens/onboarding/onboardingscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('hi')],
      path: 'assets/lang',
      fallbackLocale: Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AuthProvider()..checkAuthStatus(),
          ),
          ChangeNotifierProvider(create: (context) => AccessibilitySettings()),
        ],
        child: const MyApp(),
      ),
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
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: OnboardingScreen(),
    );
  }
}
