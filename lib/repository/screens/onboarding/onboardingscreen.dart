import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Page 1 controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _subjectsController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();

  // Page 2 selections
  final List<String> selectedNeeds = [];

  final List<Map<String, dynamic>> accessibilityOptions = [
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

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _submit() {
    // Handle form submission or navigation
    print("Name: ${_nameController.text}");
    print("Accessibility needs: $selectedNeeds");
  }

  Widget buildCard(Map<String, String> item) {
    final isSelected = selectedNeeds.contains(item['title']);
    return GestureDetector(
      onTap: () {
        setState(() {
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
              Icon(IconsMap[item['icon']] ?? Icons.help, size: 36, color: Colors.blue),
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

  static const Map<String, IconData> IconsMap = {
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
      appBar: AppBar(title: Text("Let's get to know you!")),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text("About Me"),
                SizedBox(height: 16),
                TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name")),
                TextField(controller: _classController, decoration: InputDecoration(labelText: "Class")),
                TextField(controller: _subjectsController, decoration: InputDecoration(labelText: "Subjects Interested In")),
                TextField(controller: _languageController, decoration: InputDecoration(labelText: "Language Comfortable In")),
                SizedBox(height: 20),
                ElevatedButton(onPressed: _nextPage, child: Text("Next")),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Please select your accessibility needs to personalize your learning experience"
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: accessibilityOptions.map(buildCard).toList(),
                  ),
                ),
                ElevatedButton(onPressed: _submit, child: Text("Finish"))
              ],
            ),
          )
        ],
      ),
    );
  }
}