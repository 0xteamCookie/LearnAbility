import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my_first_app/providers/auth_provider.dart';
import 'package:my_first_app/accessibility_model.dart';
import 'package:my_first_app/repository/screens/splash/splashscreen.dart';

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
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});
  final ThemeData globalTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
      labelStyle: TextStyle(color: Colors.black),
      focusColor: Colors.blue,
      prefixIconColor: Colors.blue,
      suffixIconColor: Colors.blue,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      )
    ),
    
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black,        
      selectionColor: Colors.blue[100],
      selectionHandleColor: Colors.blue,
    ),

    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      menuStyle: MenuStyle(
        backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
      ),
    ),

    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.blue),
    ),
  );

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
      theme: widget.globalTheme,
      home: SplashScreen(),
    );
  }
}
