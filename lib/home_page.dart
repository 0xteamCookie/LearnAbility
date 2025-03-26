import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_first_app/repository/widgets/global_navbar.dart';
import 'package:my_first_app/providers/auth_provider.dart';
import 'package:my_first_app/repository/screens/login/loginscreen.dart';
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
  final int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    // Set the correct index when this page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccessibilitySettings>(
        context,
        listen: false,
      ).setSelectedIndex(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    print("🔍 Checking user in HomePage: ${authProvider.user?.toJson()}");

    final String username = authProvider.user?.name ?? "Guest";
    // final String username = Provider.of<UserProvider>(context).username;
    final settings = Provider.of<AccessibilitySettings>(context);
    final double gridHeight = settings.fontSize == 1.5 ? 1.2 : 1.5;
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return SafeArea(
      child: GlobalNavBar(
        key: _scaffoldKey,
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
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Pushes items apart
                      children: [
                        // Left side: Username and grade (wrapped in Column)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
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
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'logout') {
                              await Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).logout();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.logOut,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 4),
                                  Text("Logout"),
                                ],
                              ),
                            ),
                          ],
                          child: Icon(
                            LucideIcons.user,
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
                          text: "See all →",
                          // color: const Color.fromARGB(255, 71, 70, 70),
                          color: Colors.blue,
                          fontweight: FontWeight.bold,
                          fontsize: 16,
                        ),
                      ],
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // color: Color(0xFFEDE7F6), // Light purple background
                      color: Color(0xFFFAF5FF),
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
                                    color: Color(0xFF7E22CE),
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
                                fontSize: 18 * settings.fontSize,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily(),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Today, 16:00",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14 * settings.fontSize,
                                fontFamily: fontFamily(),
                              ),
                            ),

                            SizedBox(height: 10),

                            // Profile Row
                            Row(
                              children: [
                                // SizedBox(width: 8),
                                Text(
                                  "CS",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16 * settings.fontSize,
                                    fontFamily: fontFamily(),
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
                          Color(0XFF3B82F6),
                        ),
                        _buildStatCard(
                          "Completed Lessons",
                          "24",
                          " lessons",
                          Icons.emoji_events,
                          Color(0XFF06B6D4),
                        ),
                        _buildStatCard(
                          "Weekly Progress",
                          "12.5",
                          " hours",
                          Icons.timer,
                          Color(0XFF6366F1),
                        ),
                        _buildStatCard(
                          "Quiz Average",
                          "85",
                          " %",
                          Icons.track_changes,
                          Color(0XFF14B8A6),
                        ),
                      ],
                    ),

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
                      color: Color(0xFFFFF7ED),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFEDD5),
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

                            Text(
                              "Science Syllabus",
                              style: TextStyle(
                                fontSize: 18 * settings.fontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily(),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Today, 16:00",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14 * settings.fontSize,
                                fontFamily: fontFamily(),
                              ),
                            ),

                            SizedBox(height: 10),

                            Row(
                              children: [
                                Text(
                                  "Science",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16 * settings.fontSize,
                                    fontFamily: fontFamily(),
                                  ),
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
                      color: Color(0xFFFFF7ED),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFEDD5),
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

                            Text(
                              "English poem",
                              style: TextStyle(
                                fontSize: 18 * settings.fontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily(),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Today, 16:00",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14 * settings.fontSize,
                                fontFamily: fontFamily(),
                              ),
                            ),

                            SizedBox(height: 10),

                            Row(
                              children: [
                                Text(
                                  "Englis",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16 * settings.fontSize,
                                    fontFamily: fontFamily(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STATCARD WIDGET TEMPLATE
  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final double iconSize = settings.fontSize == 1.5 ? 20.0 : 25.0;
    final double boxWidth = settings.fontSize == 1.0 ? 4.0 : 8.0;
    final double padding = settings.fontSize == 1.0 ? 10.0 : 16.0;
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Color(0XFFE5E7Eb),
              blurRadius: 4,
            ),
          ],
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: iconSize * settings.fontSize,
                ),
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
                    color: color,
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
    required Color color,
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