import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my_first_app/providers/auth_provider.dart';
import 'package:my_first_app/accessibility_model.dart';
import 'package:my_first_app/repository/screens/splash/splashscreen.dart';

import 'localization/hybrid_asset_loader.dart';

List<Locale> _generateSupportedLocales() {
  const List<String> supportedLanguageCodes = [
    'ar',
    'bn',
    'bg',
    'zh-CN',
    'zh-TW',
    'hr',
    'cs',
    'da',
    'nl',
    'en',
    'et',
    'fa',
    'fi',
    'fr',
    'de',
    'el',
    'gu',
    'he',
    'hi',
    'hu',
    'id',
    'it',
    'ja',
    'kn',
    'ko',
    'lv',
    'lt',
    'ms',
    'ml',
    'mr',
    'no',
    'pl',
    'pt',
    'ro',
    'ru',
    'sr',
    'sk',
    'sl',
    'es',
    'sw',
    'sv',
    'ta',
    'te',
    'th',
    'tr',
    'uk',
    'ur',
    'vi',
  ];

  List<Locale> locales = [];
  for (String code in supportedLanguageCodes) {
    if (code.contains('-')) {
      var parts = code.split('-');
      locales.add(Locale(parts[0], parts[1]));
    } else {
      locales.add(Locale(code));
    }
  }
  return locales;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final List<Locale> supportedLocales = _generateSupportedLocales();

  Locale startLocale = const Locale('en');
  if (!supportedLocales.contains(startLocale)) {
    if (supportedLocales.isNotEmpty) {
      startLocale = supportedLocales.first;
    } else {
      startLocale = const Locale('en');
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: supportedLocales,

      path: 'assets/lang',
      fallbackLocale: startLocale,
      startLocale: startLocale,
      assetLoader: const HybridAssetLoader(),
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
      ),
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
      bodyMedium: TextStyle(color: Colors.black),
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
