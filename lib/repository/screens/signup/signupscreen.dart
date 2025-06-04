import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_first_app/repository/screens/login/loginscreen.dart';
import '../../../accessibility_page.dart';
import "package:provider/provider.dart";
import '../../../subjects.dart';
import 'package:my_first_app/repository/widgets/uihelper.dart';
import 'package:my_first_app/services/auth_services.dart';
import "package:my_first_app/accessibility_model.dart";

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
  final TextEditingController subjectController = TextEditingController();

  // GlobalKey for form validation
  final GlobalKey<FormState> _page1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _page2FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _page3FormKey = GlobalKey<FormState>();

  // Standard selection
  String? selectedStandard;
  List<String> standards = ["10th", "11th", "12th", "College"];
  String? selectedLanguage;
  List<String> languages = ["English", "Hindi"];

  //Special Needs list
  List<String> selectedNeeds = [];
  List<Map<String, dynamic>> accessibilityOptions = [
    {
      'title': 'Visual Impairment',
      'desc': 'Screen magnification, text-to-speech, high-contrast options',
      'icon': 'visibility',
    },
    {
      'title': 'Auditory Processing',
      'desc': 'Visual aids, transcripts, and captions',
      'icon': 'hearing',
    },
    {
      'title': 'Down Syndrome',
      'desc': 'Simplified interfaces, visual instructions, adaptive content',
      'icon': 'accessibility',
    },
    {
      'title': 'Dyslexia',
      'desc': 'Special fonts, word prediction, color overlays',
      'icon': 'spellcheck',
    },
    {
      'title': 'ADHD',
      'desc': 'Visual timers, reminders, distraction-free interfaces',
      'icon': 'alarm',
    },
    {
      'title': 'Autism',
      'desc': 'Predictable routines, sensory adjustments, clear instructions',
      'icon': 'emoji_people',
    },
  ];

  // Subjects list
  List<String> subjects = [];

  void addSubject() {
    if (subjectController.text.isNotEmpty) {
      setState(() {
        subjects.add(subjectController.text.trim());
        subjectController.clear();
      });
    }
  }

  void removeSubject(int index) {
    setState(() {
      subjects.removeAt(index);
    });
  }

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
      if (subjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please add at least one subject")),
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
        subjects: subjects,
        selectedNeeds: selectedNeeds,
        context: context,
      );

      print(
        "Signing up with: $name - $email - $password - $selectedStandard - $selectedLanguage - $subjects - $selectedNeeds",
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
          settings.setDyslexic(!isSelected);
        } else if (item['title'] == 'Visual Impairment'){
          settings.setFontSize(1.25);
        
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
    return Scaffold(
      backgroundColor: Colors.white,
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

              Container(
                height: 530,
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(), // Disable swipe
                  children: [
                    // Page 1: Basic Information
                    Form(
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

                    // Page 2: Education
                    Form(
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
                              setState(() {
                                selectedLanguage = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? "Please select your preferred language" : null,
                          ),
                          SizedBox(height: 16),

                          // Subjects Input
                          TextFormField(
                            controller: subjectController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(LucideIcons.library),
                              labelText: "Enter your Subjects",
                              suffixIcon: IconButton(
                                icon: Icon(LucideIcons.plusCircle),
                                onPressed: addSubject,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Display Subjects List
                          Wrap(
                            spacing: 8,
                            children: subjects.map((subject) {
                              int index = subjects.indexOf(subject);
                              return Chip(
                                label: Text(subject),
                                onDeleted: () => removeSubject(index),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                        ],
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
                    SizedBox(height: 20),
                  ],
                ),
              ),
                  
              // Navigation Buttons
              Row(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccessibilityPage()),
                      );
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
