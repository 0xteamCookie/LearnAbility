import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import "package:provider/provider.dart";
import 'package:my_first_app/repository/widgets/uihelper.dart';
import 'package:my_first_app/services/auth_services.dart';
import "package:my_first_app/accessibility_model.dart";
import 'package:easy_localization/easy_localization.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthServices authService = AuthServices();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController interestController = TextEditingController();

  // GlobalKey for form validation
  final GlobalKey<FormState> _page1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _page2FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _page3FormKey = GlobalKey<FormState>();

  // Standard selection
  String? selectedStandard;
  List<String> standards = ["6th", "7th", "8th", "9th", "10th", "11th", "12th", "College"];

  //Language selection
  String? selectedLanguage;
  List<String> languages = ["English", "Hindi"];

  //Subject list
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

  //Special Needs list
  List<String> selectedNeeds = [];
  List<Map<String, dynamic>> accessibilityOptions = [
    {
      'title': 'Visual Impairment',
      'desc': 'Screen magnification, Text-to-speech',
      'icon': 'visibility',
    },
    {
      'title': 'Motor Impairment',
      'desc': 'Speech-to-speech, Text-to-speech',
      'icon': 'hearing',
    },
    {
      'title': 'Dyslexia',
      'desc': 'Special fonts, Screen magnification',
      'icon': 'spellcheck',
    },
    {
      'title': 'ADHD',
      'desc': 'Visual timers, Reminders',
      'icon': 'alarm',
    },
    {
      'title': 'Autism',
      'desc': 'Visual timers, Reminders',
      'icon': 'emoji_people',
    },
    {
      'title': 'Down Syndrome',
      'desc': 'Visual timers, Reminders',
      'icon': 'accessibility',
    },
  ];

  void _nextPage() {
    bool isValid = true;
    switch (_currentPage) {
      case 0:
        isValid = _page1FormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _page2FormKey.currentState?.validate() ?? false;
        break;
    }
    if (isValid && _currentPage < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  void signupUser() {
    if (_page3FormKey.currentState!.validate()) {
      if (interests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please add at least one interest")),
        );
        return;
      }

      String name = nameController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      if (selectedStandard == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please select your standard")));
        return;
      }

      if (selectedLanguage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please select your preferred language")));
        return;
      }

      authService.signupUser(
        name: name,
        email: email,
        password: password,
        standard: selectedStandard!,
        language: selectedLanguage!,
        interests: interests,
        selectedNeeds: selectedNeeds,
        context: context,
      );

      print(
        "Signing up with: $name - $email - $password - $selectedStandard - $selectedLanguage - $interests - $selectedNeeds",
      );
    }
  }

  Widget buildCard(Map<String, dynamic> item) {
    final isSelected = selectedNeeds.contains(item['title']);
    return GestureDetector(
      onTap: () {
        final settings = Provider.of<AccessibilitySettings>(context, listen: false);
        setState(() {

          if (item['title'] == 'Dyslexia') {
          settings.setDyslexic(true);
        } else if (item['title'] == 'Visual Impairment'){
          settings.setFontSize(1.25);
          settings.setTextToSpeech(true);
        } else if(item['title'] == "ADHD" || item['title'] == "Autism" || item['title'] == "Down Syndrome"){
          settings.setPomodoro(true);
          settings.setReminders(true);
        }
          isSelected ? selectedNeeds.remove(item['title']) : selectedNeeds.add(item['title']!);
        });
      },
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconsMap[item['icon']] ?? Icons.help, size: 36, color: Colors.blue),
              SizedBox(height: 8),
              Text(item['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(item['desc']!, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  static const Map<String, IconData> iconsMap = {
    'visibility': Icons.visibility,
    'hearing': Icons.hearing,
    'accessibility': Icons.accessibility,
    'spellcheck': Icons.spellcheck,
    'alarm': Icons.alarm,
    'emoji_people': Icons.emoji_people,
  };

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 56, left: 24, bottom: 24, right: 24),
          child: Column(
            children: [
              // Logo and title
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

              // Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    width: _currentPage == index ? 24 : 12,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage >= index
                          ? Colors.blue
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),

              // PageView with Expanded
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    // Page 1: Basic Information
                    SingleChildScrollView(
                      child: Form(
                        key: _page1FormKey,
                        child: Column(
                          children: [
                            // Full Name
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(LucideIcons.user),
                                labelText: "Enter your full name",
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Name cannot be empty" : null,
                            ),
                            SizedBox(height: 16),

                            // Email
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(LucideIcons.mail),
                                labelText: "Enter your email",
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Email cannot be empty" : null,
                            ),
                            SizedBox(height: 16),

                            // Password
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(LucideIcons.lock),
                                labelText: "Enter your password",
                                suffixIcon: Icon(LucideIcons.eye),
                              ),
                              validator: (value) => value != null && value.length < 6
                                  ? "Password must be at least 6 characters"
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Page 2: Education
                    SingleChildScrollView(
                      child: Form(
                        key: _page2FormKey,
                        child: Column(
                          children: [
                            // Standard Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedStandard,
                              decoration: InputDecoration(
                                prefixIcon: Icon(LucideIcons.book),
                                labelText: "Select your standard",
                              ),
                              items: standards.map((String standard) {
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
                              validator: (value) =>
                                  value == null ? "Please select your standard" : null,
                            ),
                            SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              value: selectedLanguage,
                              decoration: InputDecoration(
                                prefixIcon: Icon(LucideIcons.languages),
                                labelText: "Select your preferred language",
                              ),
                              items: languages.map((String language) {
                                return DropdownMenuItem(
                                  value: language,
                                  child: Text(language),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedLanguage = value;
                                    settings.setLanguage(value);
                                    context.setLocale(value == "English" ? const Locale('en') : const Locale('hi'));
                                  });
                                }
                              },
                              validator: (value) =>
                                  value == null ? "Please select your preferred language" : null,
                            ),
                            SizedBox(height: 16),

                            // Interests Input
                            TextFormField(
                              controller: interestController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(LucideIcons.library),
                                labelText: "Enter your Interests",
                                suffixIcon: IconButton(
                                  icon: Icon(LucideIcons.plusCircle),
                                  onPressed: addInterest,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Display Interests List
                            Wrap(
                              spacing: 8,
                              children: interests.map((interest) {
                                int index = interests.indexOf(interest);
                                return Chip(
                                  label: Text(interest),
                                  onDeleted: () => removeInterest(index),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Page 3: Special Needs
                    Form(
                      key: _page3FormKey,
                      child: Column(
                        children: [
                          // Special Needs Title
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Select any special needs (optional):",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),

                          // Special Needs Grid
                          Expanded(
                            child: SingleChildScrollView(
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                childAspectRatio: 1.2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                children: accessibilityOptions
                                    .map((item) => buildCard(item))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          foregroundColor: MaterialStateProperty.all(Colors.blue),
                        ),
                        onPressed: _previousPage,
                        child: Text("Back"),
                      )
                    else
                      SizedBox(width: 80),

                    if (_currentPage < 2)
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          foregroundColor: MaterialStateProperty.all(Colors.blue),
                        ),
                        onPressed: _nextPage,
                        child: Text("Next"),
                      )
                    else
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.blue),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                        ),
                        child: Text("Sign up"),
                        onPressed: () {
                          signupUser();
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => GenerateContentPage()),
                          // );
                        },
                      )
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
