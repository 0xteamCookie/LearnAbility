import 'package:flutter/material.dart';
import 'Lesson/lessons_page.dart';
import 'Quiz/quizzes_page.dart';
import 'accessibility_page.dart';
import 'ai_assistant_page.dart';
import 'videos_page.dart';
import 'articles_page.dart';
import 'generate_content_page.dart';
import 'my_materials_page.dart';
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

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    return Scaffold(
      key: _scaffoldKey,

      //TOP APPBAR
      appBar: AppBar(
        backgroundColor: Colors.blue,

        //APP NAME
        title: Text(
          "LearnAbility",
          style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
        ),

        //NAVIGATION BAR BUTTON
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            }
          ),
        ],
      ),

      // NAVIGATION MENU
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // HEADER
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'LearnAbility',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24 * settings.fontSize,
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text(
                'My Stats',
                style: TextStyle(fontSize: 16.0 * settings.fontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatsPage()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.accessibility),
              title: Text(
                'Accessibility',
                style: TextStyle(fontSize: 16.0 * settings.fontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccessibilityPage()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Settings',
                style: TextStyle(fontSize: 16.0 * settings.fontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            SizedBox(height: 22),

            //LEARNING TOOLS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Tools',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * settings.fontSize,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.quiz),
              title: Text(
                'Quiz',
                style: TextStyle(fontSize: 16.0 * settings.fontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizzesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.generating_tokens),
              title: Text(
                'Generate content',
                style: TextStyle(fontSize: 16.0 * settings.fontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GenerateContentPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assistant),
              title: Text(
                'AI Assistant',
                style: TextStyle(fontSize: 16.0 * settings.fontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AiAssistantPage()),
                );
              },
            ),
            SizedBox(height: 22),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Study Materials',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * settings.fontSize,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text(
                'My Materials',
                style: TextStyle(fontSize: 16.0 * settings.fontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyMaterialsPage()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.movie),
              title: Text(
                'Videos',
                style: TextStyle(fontSize: 16.0 * settings.fontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VideosPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text(
                'Articles',
                style: TextStyle(fontSize: 16.0 * settings.fontSize),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArticlesPage()),
                );
              },
            ),
            SizedBox(height: 35),

            ListTile(
              leading: Icon(
                color: Colors.red,
                Icons.logout),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0 * settings.fontSize,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[

              //WELCOME TEXT
              Text(
                "Welcome Katty!",
                style: TextStyle(
                  fontSize: 32 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),

              Text(
                "Continue your Learning Journey",
                style: TextStyle(
                  fontSize: 24.0 * settings.fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                )
              ),
              SizedBox(height:30),

              //LESSON PAGE NAVIGATION BUTTON
              ElevatedButton(
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LessonsPage(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Continue Learning",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0 * settings.fontSize,
                  ),
                ),
              ),
              SizedBox(height: 20),

              //STATISTICS GRID
              GridView.count(
                shrinkWrap: true, // Add this
                physics: NeverScrollableScrollPhysics(), // Add this
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 4 / 2,
                children: [
                  _buildStatCard("Study Streak", "7", " days"),
                  _buildStatCard("Completed Lessons", "24", " lessons"),
                  _buildStatCard("Weekly Progress", "12.5", " hours"),
                  _buildStatCard("Quiz Average", "85", " %"),
                ],
              ),

              //SUBJECT OPTIONS
              Text(
                "Subjects to choose from:",
                style: TextStyle(
                  fontSize: 24.0 * settings.fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                )
              ),
              SizedBox(height:20),
              Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                children: [
                  _buildSubjectButton("Maths"),
                  _buildSubjectButton("Physics"),
                  _buildSubjectButton("Chemistry"),
                  _buildSubjectButton("Computer"),
                  _buildSubjectButton("English"),
                  _buildSubjectButton("Biology"),

                ],
              ),
              SizedBox(height: 30),

              //SHOW LESSONS IN PROGRESS
              Text(
                "Continue Learning",
                style: TextStyle(
                  fontSize: 32.0 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              Text(
                "Pick up where you left off",
                style: TextStyle(
                  fontSize: 20.0 * settings.fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                )
              ),
              SizedBox(height:20),

              _buildLessonCard(
                subject: 'Science',
                category: 'Biology',
                title: 'Introduction to Photosynthesis',
                lastAccessed: '2 hours ago',
              ),
              SizedBox(height: 16.0),

              _buildLessonCard(
                subject: 'English',
                category: 'Writing',
                title: 'Essay Structure and Planning',
                lastAccessed: 'Yesterday',
              ),
              SizedBox(height: 16.0),

              TextButton(
                onPressed: () {
                  // Navigate to view all lessons
                },
                child: Text(
                  'View All Lessons →',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16.0 * settings.fontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //STATCARD WIDGET TEMPLATE
  Widget _buildStatCard(String title, String value, String subtitle){
    final settings = Provider.of<AccessibilitySettings>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(13.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16.0 * settings.fontSize,
            ),
          ),
          SizedBox(height: 5.0),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 21.0 * settings.fontSize,
                ),
              ),

              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15.0 * settings.fontSize,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  //SUBJECT BUTTON WIDGET TEMPLATE
  Widget _buildSubjectButton(String subject){
    final settings = Provider.of<AccessibilitySettings>(context);

    return ElevatedButton(
      onPressed: (){},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue[100],
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical:12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 5,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      child: Text(
        subject,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.0 * settings.fontSize,
        )
      ),
    );
  }

  //LESSON CARD WIDGET TEMPLATE
  Widget _buildLessonCard({
    required String subject,
    required String category,
    required String title,
    required String lastAccessed,
  }){

    final settings = Provider.of<AccessibilitySettings>(context);

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.0 * settings.fontSize,
              ),
            ),
            SizedBox(height: 8.0),

            Text(
              title,
              style: TextStyle(
                fontSize: 20.0 * settings.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              category,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.0 * settings.fontSize,
              ),
            ),
            SizedBox(height: 16.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last accessed: $lastAccessed',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.0 * settings.fontSize,
                  ),
                ),

                TextButton(
                  onPressed: () {
                    // Continue action
                  },
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0 * settings.fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
