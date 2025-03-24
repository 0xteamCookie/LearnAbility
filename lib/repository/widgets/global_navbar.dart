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

class GlobalNavBar extends StatefulWidget {
  final Widget body; 

  const GlobalNavBar({Key? key, required this.body}) : super(key: key);

  @override
  State<GlobalNavBar> createState() => _GlobalNavBarState();
}

class _GlobalNavBarState extends State<GlobalNavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndexBottomNavBar = 2;
  int _selectedIndex = -1;

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
                _selectedIndex == 3 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                _selectedIndex = 3;
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
                _selectedIndex == 4 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                _selectedIndex = 4;
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
                _selectedIndex == 5 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                _selectedIndex = 5;
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
                _selectedIndex == 10 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                _selectedIndex = 10;
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
                _selectedIndex == 6 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                _selectedIndex = 6;
              });
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LessonsPage()),
              );
            },
          ),

          // Videos
          ListTile(
            leading: Icon(Icons.movie_outlined),
            title: Text('Videos'),
            tileColor:
                _selectedIndex == 7 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                _selectedIndex = 7;
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
                _selectedIndex == 8 ? Color(0xFFEDE7F6) : null,
            onTap: () {
              setState(() {
                _selectedIndex = 8;
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
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 65.0,
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            color: Colors.white,
            elevation: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavBarItem(
                  icon: Icons.settings,
                  isSelected: _selectedIndexBottomNavBar == 0,
                  onPressed: () {
                    setState(() {
                      _selectedIndexBottomNavBar = 0;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
                // BAR CHART ICON
                _buildNavBarItem(
                  icon: Icons.bar_chart,
                  isSelected: _selectedIndexBottomNavBar == 1,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StatsPage()),
                    );
                    setState(() {
                      _selectedIndexBottomNavBar = 1;
                    });
                  },
                ),
                // HOME ICON
                _buildNavBarItem(
                  icon: Icons.home,
                  isSelected: _selectedIndexBottomNavBar == 2,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                    setState(() {
                      _selectedIndexBottomNavBar = 2;
                    });
                  },
                ),
                // ACCESSIBILITY ICON
                _buildNavBarItem(
                  icon: Icons.accessibility,
                  isSelected: _selectedIndexBottomNavBar == 3,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AccessibilityPage()),
                    );
                    setState(() {
                      _selectedIndexBottomNavBar = 3;
                    });
                  },
                ),
                // MENU ICON
                _buildNavBarItem(
                  icon: Icons.menu,
                  isSelected: _selectedIndexBottomNavBar == 4,
                  onPressed: () {
                    setState(() {
                      _selectedIndexBottomNavBar = 4;
                    });
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                ),
                // Add more icons and their corresponding onPressed logic...
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for the bottom nav items
  Widget _buildNavBarItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: isSelected ? Colors.deepPurple : Colors.grey),
      onPressed: onPressed,
    );
  }
}
