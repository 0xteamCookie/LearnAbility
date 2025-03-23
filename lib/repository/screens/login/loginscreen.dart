import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_first_app/repository/widgets/uihelper.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 56, left: 24, bottom: 24, right: 24),
          child: Column(
            children: [
              SizedBox(height: 80),
              Column(
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Uihelper.CustomImage(img: "logo.png"),
                  ),
                  SizedBox(height: 8),
                  Uihelper.CustomText(
                    text: "Welcome back!",
                    color: Colors.black,
                    fontweight: FontWeight.bold,
                    fontsize: 20,
                    fontfamily: "regular",
                  ),
                ],
              ),

              SizedBox(height: 28),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(LucideIcons.moveRight),
                        labelText: "Enter your email",
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(LucideIcons.lock),
                        labelText: "Enter your password",
                        suffixIcon: Icon(LucideIcons.eye),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          side: BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Uihelper.CustomText(
                          text: "Login",
                          color: Colors.white,
                          fontweight: FontWeight.bold,
                          fontsize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
