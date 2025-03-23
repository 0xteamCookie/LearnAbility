import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_first_app/repository/widgets/uihelper.dart';
import 'Lesson/lessons_page.dart';
import 'Quiz/quizzes_page.dart';
import 'accessibility_page.dart';
import 'ai_assistant_page.dart';
import 'videos_page.dart';
import 'articles_page.dart';
import 'generate_content_page.dart';
import 'settings_page.dart';
import 'stats_page.dart';
import 'package:provider/provider.dart';
import 'accessibility_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = -1;
  int _selectedIndexBottomNavBar = 2;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final double gridHeight = settings.fontSize == 1.5 ? 1.2 : 1.5;
    final bool isDyslexic = settings.openDyslexic;
    final String username = "Katty Doe";

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return Scaffold(
      key: _scaffoldKey,

      // NAVIGATION MENU
      endDrawer: NavigationDrawer(
        backgroundColor: Colors.white,
        children: <Widget>[
          SizedBox(
            height: 90.0,
            child: const DrawerHeader(
              child: Text(
                'LearnAbility',
                style: TextStyle(color: Colors.deepPurple, fontSize: 24),
              ),
            ),
          ),

          // My Stats
          // ListTile(
          //   leading: Icon(Icons.bar_chart_outlined),
          //   title: Text('My Stats'),
          //   tileColor:
          //       _selectedIndex == 0 ? Colors.deepPurple.withValues(alpha: .2) : null,
          //   onTap: () {
          //     setState(() {
          //       _selectedIndex = 0;
          //     });
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => StatsPage()),
          //     );
          //   },
          // ),

          // // Accessibility
          // ListTile(
          //   leading: Icon(Icons.accessibility_outlined),
          //   title: Text('Accessibility'),
          //   tileColor:
          //       _selectedIndex == 1 ? Colors.deepPurple.withValues(alpha: .2) : null,
          //   onTap: () {
          //     setState(() {
          //       _selectedIndex = 1;
          //     });
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => AccessibilityPage()),
          //     );
          //   },
          // ),

          // // Settings
          // ListTile(
          //   leading: Icon(Icons.settings_outlined),
          //   title: Text('Settings'),
          //   tileColor:
          //       _selectedIndex == 2 ? Colors.deepPurple.withValues(alpha: .2) : null,
          //   onTap: () {
          //     setState(() {
          //       _selectedIndex = 2;
          //     });
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => SettingsPage()),
          //     );
          //   },
          // ),

          // const Divider(indent: 28, endIndent: 28),

          // Tools Section
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Tools', style: Theme.of(context).textTheme.titleSmall),
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

          const Divider(indent: 28, endIndent: 28),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            tileColor:
                _selectedIndex == 9 ? Colors.red.withValues(alpha: .2) : null,
            onTap: () {
              setState(() {
                _selectedIndex = 9;
              });
              Navigator.pop(context);
              // Handle logout logic here
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // gradient: LinearGradient(
              //   colors: [Color.fromARGB(255, 129, 194, 248), Colors.white],
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              // ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Pushes items apart
                    children: [
                      // Left side: Username and grade (wrapped in Column)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 20 * settings.fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: fontFamily(),
                            ),
                          ),
                          Uihelper.CustomText(
                            text: "12th grade",
                            color: const Color.fromARGB(255, 29, 28, 28),
                            fontweight: FontWeight.bold,
                            fontsize: 16,
                          ),
                        ],
                      ),

                      // Right side: Icon
                      CircleAvatar(
                        backgroundColor: Color(0xFFEDE7F6), // Light purple
                        radius: 20,
                        child: Icon(
                          LucideIcons.user, // Change this to any icon
                          size: 28,
                          color: Colors.black,
                        ),
                      ),
                      
                    ],
                  ),

                  // WELCOME TEXT
                  SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Uihelper.CustomText(
                        text: "Next Lesson",
                        color: Colors.black,
                        fontweight: FontWeight.bold,
                        fontsize: 18,
                      ),
                      Uihelper.CustomText(
                        text: "See all >",
                        color: Colors.deepPurple,
                        fontweight: FontWeight.bold,
                        fontsize: 16,
                      ),
                    ],
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Color(0xFFEDE7F6), // Light purple background
                    // color: Color(0xFFD1C4E9),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row with Icon and Badge
                          Row(
                            children: [
                              // Calendar Icon
                              CircleAvatar(
                                backgroundColor: Colors.white, // Light purple
                                radius: 20,
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Colors.black,
                                  size: 18,
                                ),
                              ),
                              Spacer(),
                              // Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Get Started",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),

                          // Title & Time
                          Text(
                            "Web Development Fundamentals",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Today, 16:00",
                            style: TextStyle(color: Colors.black),
                          ),

                          SizedBox(height: 10),

                          // Profile Row
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(""),
                                radius: 14,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "CS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // STATISTICS GRID
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: gridHeight,
                    children: [
                      _buildStatCard(
                        "Study Streak",
                        "7",
                        " days",
                        Icons.local_fire_department,
                      ),
                      _buildStatCard(
                        "Completed Lessons",
                        "24",
                        " lessons",
                        Icons.emoji_events,
                      ),
                      _buildStatCard(
                        "Weekly Progress",
                        "12.5",
                        " hours",
                        Icons.timer,
                      ),
                      _buildStatCard(
                        "Quiz Average",
                        "85",
                        " %",
                        Icons.track_changes,
                      ),
                    ],
                  ),

                  // SHOW LESSONS IN PROGRESS
                  // Text(
                  //   "Continue Learning",
                  //   style: TextStyle(
                  //     fontSize: 10.0 * settings.fontSize,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black,
                  //     fontFamily: fontFamily(),
                  //   ),
                  // ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Uihelper.CustomText(
                        text: "My Materials",
                        color: Colors.black,
                        fontweight: FontWeight.bold,
                        fontsize: 18,
                      ),
                      // Text(
                      //   "Pick up where you left off",
                      //   style: TextStyle(
                      //     fontSize: 20.0 * settings.fontSize,
                      //     fontWeight: FontWeight.w600,
                      //     color: Colors.grey[700],
                      //     fontFamily: fontFamily(),
                      //   ),
                      // ),
                      TextButton(
                        onPressed: () {
                          // Navigate to view all lessons
                        },
                        child: Text(
                          'See more →',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 16.0 * settings.fontSize,
                            fontFamily: fontFamily(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Color(0xFFEDE7F6), // Light purple background
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row with Icon and Badge
                          Row(
                            children: [
                              // Calendar Icon
                              // Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Ready",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),

                          // Title & Time
                          Text(
                            "Science Syllabus",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Today, 16:00",
                            style: TextStyle(color: Colors.grey[600]),
                          ),

                          SizedBox(height: 10),

                          // Profile Row
                          Row(
                            children: [
                              Text(
                                "Science",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Color(0xFFEDE7F6), // Light purple background
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row with Icon and Badge
                          Row(
                            children: [
                              // Calendar Icon
                              // Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Ready",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),

                          // Title & Time
                          Text(
                            "English poem",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Today, 16:00",
                            style: TextStyle(color: Colors.grey[600]),
                          ),

                          SizedBox(height: 10),

                          // Profile Row
                          Row(
                            children: [
                              Text(
                                "Englis",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // _buildLessonCard(
                  //   subject: 'Science',
                  //   category: 'Biology',
                  //   title: 'Science Syllabus',
                  // ),
                  // SizedBox(height: 16.0),

                  // _buildLessonCard(
                  //   subject: 'English',
                  //   category: 'Writing',
                  //   title: 'Some Poem',
                  // ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        width: double.infinity,
        height: 65.0,
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1), // Subtle shadow
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0), // Match the container's border radius
          child: BottomAppBar(
            shape: CircularNotchedRectangle(),
            color: Colors.white,
            elevation: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // SETTINGS ICON
                _buildNavBarItem(
                  icon: Icons.settings,
                  isSelected: _selectedIndexBottomNavBar == 0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                    setState(() {
                      _selectedIndexBottomNavBar = 0;
                    });
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
  required IconData icon,
  required bool isSelected,
  required VoidCallback onPressed,
}) {
  return IconButton(
    icon: Icon(
      icon,
      color: isSelected ? Colors.deepPurple : Colors.grey[600], // Selected: purple, Unselected: grey
      size: 24.0,
    ),
    onPressed: onPressed,
  );
}

  // STATCARD WIDGET TEMPLATE
  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final double iconSize = settings.fontSize == 1.5 ? 20.0 : 25.0;
    final double boxWidth = settings.fontSize == 1.5 ? 4.0 : 8.0;
    final double padding = settings.fontSize == 1.0 ? 10.0 : 16.0;
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFEDE7F6),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              // spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white, // Light purple
                  radius: 18,
                  child: Icon(
                    icon,
                    color: Colors.black,
                    size: iconSize * settings.fontSize,
                    
                  ),
                ),
                // Icon(
                //   icon,
                //   // color: Colors.indigo,
                //   // color: Colors.orange[800],
                //   color: Colors.deepPurple,
                //   size: iconSize * settings.fontSize,
                // ),
                SizedBox(width: boxWidth),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0 * settings.fontSize,
                      height: 1,
                      fontFamily: fontFamily(),
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.deepPurple,
                    // color: Colors.indigo,
                    // color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                ),
                Flexible(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 15.0 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // LESSON CARD WIDGET TEMPLATE
  Widget _buildLessonCard({
    required String subject,
    required String category,
    required String title,
  }) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: double.infinity),
            Text(
              subject,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.0 * settings.fontSize,
                fontFamily: fontFamily(),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily(),
              ),
            ),
            Text(
              category,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.0 * settings.fontSize,
                fontFamily: fontFamily(),
              ),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                // Continue action
              },
              child: Text(
                'Continue',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16.0 * settings.fontSize,
                  fontFamily: fontFamily(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
