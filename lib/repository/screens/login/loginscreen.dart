import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_first_app/repository/screens/signup/signupscreen.dart';
import 'package:my_first_app/repository/widgets/uihelper.dart';
import 'package:my_first_app/services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthServices authService = AuthServices();

  // Controllers for form fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // GlobalKey for form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void loginUser() {
    if (_formKey.currentState!.validate()) {
      // Validate form first
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      authService.loginUser(email: email, password: password, context: context);

      print("Signing up with: $email - $password");
    }
  }

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

              // 🛠 Wrap in Form Widget with GlobalKey
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(LucideIcons.moveRight),
                        labelText: "Enter your email",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email cannot be empty";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),

                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(LucideIcons.lock),
                        labelText: "Enter your password",
                        suffixIcon: Icon(LucideIcons.eye),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: loginUser,
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
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Signup",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
