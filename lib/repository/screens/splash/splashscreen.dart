import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_first_app/domain/constants/appcolors.dart';
import 'package:my_first_app/repository/screens/login/loginscreen.dart';
import 'package:my_first_app/home_page.dart';
import 'package:my_first_app/providers/auth_provider.dart';
import 'package:my_first_app/repository/widgets/uihelper.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus(); // ✅ Ensure we check auth first

      Timer(Duration(seconds: 2), () {
        if (authProvider.isLoggedIn) {
          print("✅ User logged in, redirecting to HomePage...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          print("❌ No user logged in, redirecting to LoginScreen...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Uihelper.CustomImage(img: "logo.png"),
            ),
            SizedBox(height: 10),
            Uihelper.CustomText(
              text: "LearnAbility",
              color: Colors.black,
              fontweight: FontWeight.bold,
              fontsize: 20,
              fontfamily: "bold",
            ),
          ],
        ),
      ),
    );
  }
}
