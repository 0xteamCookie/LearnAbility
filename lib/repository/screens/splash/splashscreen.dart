import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_first_app/domain/constants/appcolors.dart';
import 'package:my_first_app/repository/screens/login/loginscreen.dart';
import 'package:my_first_app/repository/widgets/uihelper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenSatate();
}

class _SplashScreenSatate extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (builder) => LoginScreen()),
      );
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
