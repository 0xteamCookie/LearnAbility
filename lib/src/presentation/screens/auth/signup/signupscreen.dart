import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_first_app/src/presentation/screens/auth/login/loginscreen.dart';
import 'package:my_first_app/src/presentation/widgets/uihelper.dart';
import 'package:my_first_app/src/data/repositories/auth_repository.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthServices authService = AuthServices();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController interestController = TextEditingController();

  // GlobalKey for form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Standard selection
  String? selectedStandard;
  List<String> standards = ["10th", "11th", "12th", "College"];

  // Interests list
  List<String> interests = [];

  void addInterest() {
    if (interestController.text.isNotEmpty) {
      setState(() {
        interests.add(interestController.text.trim());
        interestController.clear();
      });
    }
  }

  void removeInterest(int index) {
    setState(() {
      interests.removeAt(index);
    });
  }

  void signupUser() {
    if (_formKey.currentState!.validate()) {
      String name = nameController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      if (selectedStandard == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please select your standard")));
        return;
      }

      if (interests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please add at least one interest")),
        );
        return;
      }

      authService.signupUser(
        name: name,
        email: email,
        password: password,
        standard: selectedStandard!,
        interests: interests,
        context: context,
      );

      print(
        "Signing up with: $name - $email - $password - $selectedStandard - $interests",
      );
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
              SizedBox(height: 20),
              Column(
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Uihelper.CustomImage(img: "logo.png"),
                  ),
                  SizedBox(height: 8),
                  Uihelper.CustomText(
                    text: "Create a new account",
                    color: Colors.black,
                    fontweight: FontWeight.bold,
                    fontsize: 20,
                    fontfamily: "regular",
                  ),
                ],
              ),
              SizedBox(height: 28),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Full Name
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(LucideIcons.user),
                        labelText: "Enter your full name",
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty ? "Name cannot be empty" : null,
                    ),
                    SizedBox(height: 8),

                    // Email
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(LucideIcons.mail),
                        labelText: "Enter your email",
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty ? "Email cannot be empty" : null,
                    ),
                    SizedBox(height: 8),

                    // Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(LucideIcons.lock),
                        labelText: "Enter your password",
                        suffixIcon: Icon(LucideIcons.eye),
                      ),
                      validator:
                          (value) =>
                              value != null && value.length < 6
                                  ? "Password must be at least 6 characters"
                                  : null,
                    ),
                    SizedBox(height: 16),

                    // Standard Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedStandard,
                      decoration: InputDecoration(
                        prefixIcon: Icon(LucideIcons.book),
                        labelText: "Select your standard",
                      ),
                      items:
                          standards.map((String standard) {
                            return DropdownMenuItem(
                              value: standard,
                              child: Text(standard),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStandard = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Interests Input
                    TextFormField(
                      controller: interestController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(LucideIcons.plus),
                        labelText: "Enter an interest",
                        suffixIcon: IconButton(
                          icon: Icon(LucideIcons.plusCircle),
                          onPressed: addInterest,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Display Interests List
                    Wrap(
                      spacing: 8,
                      children:
                          interests.map((interest) {
                            int index = interests.indexOf(interest);
                            return Chip(
                              label: Text(interest),
                              onDeleted: () => removeInterest(index),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 16),

                    // Signup Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: signupUser,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          side: BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Uihelper.CustomText(
                          text: "Sign Up",
                          color: Colors.white,
                          fontweight: FontWeight.bold,
                          fontsize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Already have an account? Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Login",
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
