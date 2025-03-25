import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Lesson/lessons_page.dart';
import '../../Quiz/quizzes_page.dart';
import '../../accessibility_model.dart';
import '../../accessibility_page.dart';
import '../../ai_assistant_page.dart';
import '../../articles_page.dart';
import '../../generate_content_page.dart';
import '../../home_page.dart';
import '../../my_materials_page.dart';
import '../../settings_page.dart';
import '../../stats_page.dart';
import '../../videos_page.dart';
import '../../subjects.dart';

class GlobalNavBar extends StatefulWidget {
  final Widget body; 

  const GlobalNavBar({Key? key, required this.body}) : super(key: key);

  @override
  State<GlobalNavBar> createState() => _GlobalNavBarState();
}

class _GlobalNavBarState extends State<GlobalNavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
 
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);

    return Scaffold(
      key: _scaffoldKey,

      // NAVIGATION MENU
      endDrawer: NavigationDrawer(
        backgroundColor: Colors.white,
        children: <Widget>[
          const DrawerHeader(
            child: Text(
              'LearnAbility',
              style: TextStyle(color: Colors.deepPurple, fontSize: 24),
            ),
          ),

          // Quiz
          ListTile(
            leading: Icon(Icons.quiz_outlined),
            title: Text('Quiz'),
            tileColor:
                selectedIndex == 3 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                selectedIndex = 3;
              });
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizzesPage()),
              );
            },
          ),

          // Upload Content
          ListTile(
            leading: Icon(Icons.generating_tokens_outlined),
            title: Text('Generate Lessons'),
            tileColor:
                selectedIndex == 4 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                selectedIndex = 4;
              });
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GenerateContentPage()),
              );
            },
          ),

          // AI Assistant
          ListTile(
            leading: Icon(Icons.assistant_outlined),
            title: Text('AI Assistant'),
            tileColor:
                selectedIndex == 5 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                selectedIndex = 5;
              });
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AiAssistantPage()),
              );
            },
          ),

          // AI Voice Assistant
          ListTile(
            leading: Icon(Icons.assistant_outlined),
            title: Text('AI Voice Assistant'),
            tileColor:
                selectedIndex == 10 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                selectedIndex = 10;
              });
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AiAssistantPage()),
              );
            },
          ),

          const Divider(indent: 28, endIndent: 28),

          // Study Materials Section
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'Study Materials',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),

          // Lessons
          ListTile(
            leading: Icon(Icons.book_outlined),
            title: Text('Lessons'),
            tileColor:
                selectedIndex == 6 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                selectedIndex = 6;
              });
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LessonsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.quiz_outlined),
            title: Text('Subjects'),
            tileColor:
                selectedIndex == 9 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                selectedIndex = 9;
              });
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Subjects()),
              );
            },
          ),

          // Videos
          ListTile(
            leading: Icon(Icons.movie_outlined),
            title: Text('Videos'),
            tileColor:
                selectedIndex == 7 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                selectedIndex = 7;
              });
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideosPage()),
              );
            },
          ),

          // Articles
          ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Articles'),
            tileColor:
                selectedIndex == 8 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                selectedIndex = 8;
              });
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArticlesPage()),
              );
            },
          ),
          
        ],
      ),

      body: widget.body,
      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: settings.selectedIndexBottomNavBar,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: (index) {
            settings.setSelectedIndex(index);

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StatsPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccessibilityPage()),
            );
          } else if (index == 4) {
            _scaffoldKey.currentState?.openEndDrawer();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility),
            label: 'Access',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}
