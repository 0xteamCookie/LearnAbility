import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_first_app/repository/widgets/global_navbar.dart';
import 'package:my_first_app/providers/auth_provider.dart';
import 'package:my_first_app/repository/screens/login/loginscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'accessibility_model.dart';
import 'utils/constants.dart';
import 'subjects.dart';
import 'generate_content_page.dart';
import 'Lesson/lesson_page.dart';
import 'Quiz/quizzes_page.dart';
import 'services/start_service.dart';

class UserStats {
  final String id;
  final String userId;
  final int studyStreak;
  final int completedLessons;
  final int weeklyProgress;
  final double? quizAverage;
  final DateTime? lastStudiedAt;

  UserStats({
    required this.id,
    required this.userId,
    required this.studyStreak,
    required this.completedLessons,
    required this.weeklyProgress,
    this.quizAverage,
    this.lastStudiedAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      id: json['id'],
      userId: json['userId'],
      studyStreak: json['studyStreak'],
      completedLessons: json['completedLessons'],
      weeklyProgress: json['weeklyProgress'],
      quizAverage: json['quizAverage']?.toDouble(),
      lastStudiedAt:
          json['lastStudiedAt'] != null
              ? DateTime.parse(json['lastStudiedAt'])
              : null,
    );
  }
}

class NextLesson {
  final String id;
  final String title;
  final String subjectName;
  final String subjectId;
  final String? description;
  final String? duration;
  final String? level;
  final int? progress;

  NextLesson({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.subjectId,
    this.description,
    this.duration,
    this.level,
    this.progress,
  });
}

class Material {
  final String id;
  final String name;
  final String type;
  final String fileType;
  final int size;
  final String uploadDate;
  final String subjectId;
  final String subjectName;
  final String? thumbnail;
  final String status;

  Material({
    required this.id,
    required this.name,
    required this.type,
    required this.fileType,
    required this.size,
    required this.uploadDate,
    required this.subjectId,
    required this.subjectName,
    this.thumbnail,
    required this.status,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      fileType: json['fileType'],
      size: json['size'],
      uploadDate: json['uploadDate'],
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      thumbnail: json['thumbnail'],
      status: json['status'],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UserStats? _userStats;
  NextLesson? _nextLesson;
  List<Material> _materials = [];
  bool _isLoading = true;
  late TabController _tabController;

  // New variables for enhanced UI

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set the correct index when this page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccessibilitySettings>(
        context,
        listen: false,
      ).setSelectedIndex(2);

      // Fetch data
      _fetchUserStats();
      _fetchNextLesson();
      _fetchMaterials();

      // Track user activity - viewing homepage
      _trackActivity("browsing", 1);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await StatsService.getUserStats();
      if (stats != null) {
        setState(() {
          _userStats = UserStats.fromJson(stats);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user stats: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNextLesson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) return;

    try {
      // First fetch subjects
      final subjectsResponse = await http.get(
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (subjectsResponse.statusCode == 200) {
        final Map<String, dynamic> subjectsData = jsonDecode(
          subjectsResponse.body,
        );
        final List subjects = subjectsData['subjects'];

        if (subjects.isNotEmpty) {
          // Get the first subject
          final subject = subjects[0];
          final String subjectId = subject['id'];
          final String subjectName = subject['name'];

          // Fetch lessons for this subject
          final lessonsResponse = await http.get(
            Uri.parse(
              '${Constants.uri}/api/v1/pyos/subjects/$subjectId/lessons',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (lessonsResponse.statusCode == 200) {
            final Map<String, dynamic> lessonsData = jsonDecode(
              lessonsResponse.body,
            );
            final List lessons = lessonsData['lessons'];

            if (lessons.isNotEmpty) {
              // Get the first lesson
              final lesson = lessons[0];
              setState(() {
                _nextLesson = NextLesson(
                  id: lesson['id'],
                  title: lesson['title'],
                  subjectName: subjectName,
                  subjectId: subjectId,
                  description: lesson['description'],
                  duration: lesson['duration'],
                  level: lesson['level'] ?? 'Beginner',
                  progress: lesson['progress'] ?? 0,
                );
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching next lesson: $e");
    }
  }

  Future<void> _fetchMaterials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/pyos/materials'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _materials =
              (data['materials'] as List)
                  .map((json) => Material.fromJson(json))
                  .toList();

          // Limit to 3 materials for display
          if (_materials.length > 3) {
            _materials = _materials.sublist(0, 3);
          }
        });
      }
    } catch (e) {
      print("Error fetching materials: $e");
    }
  }

  Future<void> _trackActivity(String activityType, int duration) async {
    await StatsService.trackActivity(activityType, duration);
  }

  Future<void> _markLessonAsCompleted(String lessonId) async {
    final success = await StatsService.markLessonAsCompleted(lessonId);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lesson marked as completed!")));

      // Refresh stats
      _fetchUserStats();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to mark lesson as completed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String username = authProvider.user?.name ?? "Guest";
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return GlobalNavBar(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(color: Colors.white)),
          RefreshIndicator(
            onRefresh: () async {
              await _fetchUserStats();
              await _fetchNextLesson();
              await _fetchMaterials();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with gradient background
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0XFF6366F1), Color(0XFF8B5CF6)],
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Improved greeting section with better layout
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Username section with better overflow handling
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Greeting with time-based message
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontSize: 16 * settings.fontSize,
                                      color: Colors.white.withOpacity(0.9),
                                      fontFamily: fontFamily(),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // Username with proper overflow handling
                                  Text(
                                    username,
                                    style: TextStyle(
                                      fontSize: 22 * settings.fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: fontFamily(),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Profile icon with proper menu
                            GestureDetector(
                              onTap: () {
                                // Show bottom sheet instead of direct logout
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder:
                                      (context) => Container(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: Icon(LucideIcons.user),
                                              title: Text(
                                                "Profile",
                                                style: TextStyle(
                                                  fontFamily: fontFamily(),
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                                // Navigate to profile page when implemented
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                LucideIcons.settings,
                                              ),
                                              title: Text(
                                                "Settings",
                                                style: TextStyle(
                                                  fontFamily: fontFamily(),
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                                // Navigate to settings page when implemented
                                              },
                                            ),
                                            Divider(),
                                            ListTile(
                                              leading: Icon(LucideIcons.logOut),
                                              title: Text(
                                                "Logout",
                                                style: TextStyle(
                                                  fontFamily: fontFamily(),
                                                ),
                                              ),
                                              onTap: () async {
                                                await Provider.of<AuthProvider>(
                                                  context,
                                                  listen: false,
                                                ).logout();
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            LoginScreen(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  LucideIcons.user,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Motivational message
                        Text(
                          "Let's continue learning",
                          style: TextStyle(
                            fontSize: 16 * settings.fontSize,
                            color: Colors.white.withOpacity(0.9),
                            fontFamily: fontFamily(),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSimpleStat(
                              "${_userStats?.studyStreak ?? 0}",
                              "Streak",
                              Icons.local_fire_department,
                              settings,
                              fontFamily(),
                            ),
                            _buildSimpleStat(
                              "${_userStats?.completedLessons ?? 0}",
                              "Lessons",
                              Icons.school,
                              settings,
                              fontFamily(),
                            ),
                            _buildSimpleStat(
                              "${_userStats?.quizAverage?.toStringAsFixed(1) ?? 0}%",
                              "Average",
                              Icons.analytics,
                              settings,
                              fontFamily(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quick Actions Section
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quick Actions",
                          style: TextStyle(
                            fontSize: 20 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily(),
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Quick Actions Grid - 2x2
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _buildSimpleActionCard(
                              "Subjects",
                              Icons.book,
                              Color(0xFFE0E7FF),
                              Color(0xFF6366F1),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubjectsPage(),
                                  ),
                                );
                              },
                              settings,
                              fontFamily(),
                            ),
                            _buildSimpleActionCard(
                              "Quizzes",
                              Icons.quiz,
                              Color(0xFFDCFCE7),
                              Color(0xFF10B981),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizzesPage(),
                                  ),
                                );
                              },
                              settings,
                              fontFamily(),
                            ),
                            _buildSimpleActionCard(
                              "Materials",
                              Icons.folder,
                              Color(0xFFFFF7ED),
                              Color(0xFFEA580C),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GenerateContentPage(),
                                  ),
                                );
                              },
                              settings,
                              fontFamily(),
                            ),
                            _buildSimpleActionCard(
                              "Progress",
                              Icons.insights,
                              Color(0xFFDBEAFE),
                              Color(0xFF3B82F6),
                              () {
                                // Progress page will be implemented later
                              },
                              settings,
                              fontFamily(),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        // Continue Learning Section
                        Text(
                          "Continue Learning",
                          style: TextStyle(
                            fontSize: 20 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily(),
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 16),

                        _nextLesson != null
                            ? _buildSimpleLearningCard(settings, fontFamily())
                            : _buildNoLessonsCard(settings, fontFamily()),

                        SizedBox(height: 24),

                        // Recent Materials Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Materials",
                              style: TextStyle(
                                fontSize: 20 * settings.fontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily(),
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GenerateContentPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "See all",
                                style: TextStyle(
                                  color: Color(0XFF6366F1),
                                  fontSize: 16 * settings.fontSize,
                                  fontFamily: fontFamily(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Materials list
                        _materials.isNotEmpty
                            ? Column(
                              children:
                                  _materials.map((material) {
                                    return _buildSimpleMaterialItem(
                                      material,
                                      settings,
                                      fontFamily(),
                                    );
                                  }).toList(),
                            )
                            : _buildNoMaterialsCard(settings, fontFamily()),

                        // Add extra padding at the bottom to prevent overflow with the navbar
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Replace the header stat widget with a simpler version
  Widget _buildSimpleStat(
    String value,
    String label,
    IconData icon,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20 * settings.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: fontFamily,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            color: Colors.white.withOpacity(0.9),
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  // Replace the action card with a simpler version
  Widget _buildSimpleActionCard(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Replace the continue learning card with a simpler version
  Widget _buildSimpleLearningCard(
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return GestureDetector(
      onTap: () {
        if (_nextLesson != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => LessonContentPage(
                    lessonId: _nextLesson!.id,
                    subjectId: _nextLesson!.subjectId,
                  ),
            ),
          ).then((_) {
            _markLessonAsCompleted(_nextLesson!.id);
          });
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course code and level
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.school,
                          color: Color(0XFF6366F1),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _nextLesson?.subjectName ?? "MAT1008",
                        style: TextStyle(
                          fontSize: 16 * settings.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF6366F1),
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _nextLesson?.level ?? "Beginner",
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lesson title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _nextLesson?.title ?? "Ordinary Differential Equations",
                style: TextStyle(
                  fontSize: 18 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  fontFamily: fontFamily,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: 8),

            // Duration
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _nextLesson?.duration ?? "45 minutes",
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      color: Colors.grey.shade600,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Continue button
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nextLesson != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => LessonContentPage(
                                lessonId: _nextLesson!.id,
                                subjectId: _nextLesson!.subjectId,
                              ),
                        ),
                      ).then((_) {
                        _markLessonAsCompleted(_nextLesson!.id);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFF6366F1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Replace the material item with a simpler version
  Widget _buildSimpleMaterialItem(
    Material material,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    IconData getFileIcon() {
      switch (material.fileType.toLowerCase()) {
        case 'pdf':
          return Icons.picture_as_pdf;
        case 'jpg':
        case 'jpeg':
        case 'png':
          return Icons.image;
        case 'doc':
        case 'docx':
          return Icons.description;
        case 'xls':
        case 'xlsx':
          return Icons.table_chart;
        case 'ppt':
        case 'pptx':
          return Icons.slideshow;
        default:
          return Icons.insert_drive_file;
      }
    }

    Color getFileColor() {
      switch (material.fileType.toLowerCase()) {
        case 'pdf':
          return Colors.red.shade700;
        case 'jpg':
        case 'jpeg':
        case 'png':
          return Colors.teal.shade700;
        case 'doc':
        case 'docx':
          return Colors.blue.shade700;
        case 'xls':
        case 'xlsx':
          return Colors.green.shade700;
        case 'ppt':
        case 'pptx':
          return Colors.orange.shade700;
        default:
          return Colors.grey.shade700;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: getFileColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(getFileIcon(), color: getFileColor(), size: 24),
        ),
        title: Text(
          material.name,
          style: TextStyle(
            fontSize: 16 * settings.fontSize,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          material.subjectName,
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            color: Colors.grey.shade600,
            fontFamily: fontFamily,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildNoLessonsCard(
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 48, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "No lessons available",
            style: TextStyle(
              fontSize: 18 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Explore subjects to find lessons",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16 * settings.fontSize,
              color: Colors.grey.shade700,
              fontFamily: fontFamily,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubjectsPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0XFF6366F1),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Explore Subjects",
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMaterialsCard(
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_outlined, size: 48, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "No materials yet",
            style: TextStyle(
              fontSize: 18 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Add materials to get started",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16 * settings.fontSize,
              color: Colors.grey.shade700,
              fontFamily: fontFamily,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GenerateContentPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0XFF6366F1),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Add Materials",
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this helper method to the _HomePageState class
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning,";
    } else if (hour < 17) {
      return "Good afternoon,";
    } else {
      return "Good evening,";
    }
  }
}
