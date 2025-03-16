import 'package:flutter/material.dart';
import 'lesson_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //TOP APPBAR
        appBar: AppBar(
          backgroundColor: Colors.blue,

          //APP NAME
          title: Text(
            "LearnAbility",
              style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
          ),

          //BACK BUTTON
          actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const LessonPage(),
              ));
            },
          ),
        ],
        ),
          
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                
                //WELCOME TEXT
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                
                Text(
                  "Continue your Learning Journey",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  )
                ),
                SizedBox(height:30),
            
                //LESSON PAGE NAVIGATION BUTTON
                ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LessonPage(),
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
                      fontSize: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                //STATISTICS GRID
                GridView.count(
                  shrinkWrap: true,
                  
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 4/2,
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
                    fontSize: 24.0,
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
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                Text(
                  "Pick up where you left off",
                  style: TextStyle(
                    fontSize: 20.0,
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
                      fontSize: 16.0,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
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
              fontSize: 16.0,
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
                  fontSize: 21.0,
                ),
              ),

              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15.0
                ),
              )
          ],)
        ],
      ),
    );
  }

  //SUBJECT BUTTON WIDGET TEMPLATE
  Widget _buildSubjectButton(String subject){
    return ElevatedButton(
      onPressed: (){},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue[100],
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical:12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 5,
        shadowColor: Colors.grey.withValues(alpha: 0.5),
      ),
      child: Text(
        subject,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
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
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 8.0),

            Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              category,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.0,
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
                    fontSize: 14.0,
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
                      fontSize: 16.0,
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
