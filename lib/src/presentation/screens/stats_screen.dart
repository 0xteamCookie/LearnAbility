import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'accessibility_model.dart';
import './repository/widgets/global_navbar.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    // Set the correct index when this page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccessibilitySettings>(
        context,
        listen: false,
      ).setSelectedIndex(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return GlobalNavBar(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(color: Colors.white)),
          Column(
            children: [
              // Gradient Header
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
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              LucideIcons.arrowLeft,
                              size: 22,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Your Learning Progress",
                            style: TextStyle(
                              fontSize: 24 * settings.fontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily(),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              LucideIcons.calendar,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Show date range picker
                            },
                            tooltip: "Select time period",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Track your study habits and progress",
                      style: TextStyle(
                        fontSize: 16 * settings.fontSize,
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: fontFamily(),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStreakCard(settings, fontFamily()),
                      SizedBox(height: 24),
                      _buildSubjectsProgressCard(settings, fontFamily()),
                      SizedBox(height: 24),
                      _buildWeeklyActivityCard(settings, fontFamily()),

                      // Add extra padding at the bottom for the floating navbar
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(AccessibilitySettings settings, String fontFamily) {
    return Container(
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.flame,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Current Streak",
                style: TextStyle(
                  fontSize: 18 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "12 Days",
                style: TextStyle(
                  fontSize: 32 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF3C7).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFFD97706).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.target,
                      color: Color(0xFFD97706),
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Goal: 20 Lessons",
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontWeight: FontWeight.w500,
                        fontFamily: fontFamily,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsProgressCard(
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final Map<String, Map<String, dynamic>> subjects = {
      "Science": {"progress": 0.45, "color": Color(0xFF10B981)},
      "English": {"progress": 0.65, "color": Color(0xFF8B5CF6)},
      "History": {"progress": 0.30, "color": Color(0xFFEA580C)},
    };

    return Container(
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.barChart2,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Subject Progress",
                style: TextStyle(
                  fontSize: 18 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...subjects.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16 * settings.fontSize,
                          fontWeight: FontWeight.w500,
                          fontFamily: fontFamily,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        "${(entry.value["progress"] * 100).toInt()}%",
                        style: TextStyle(
                          fontSize: 16 * settings.fontSize,
                          fontWeight: FontWeight.w500,
                          fontFamily: fontFamily,
                          color: entry.value["color"],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: entry.value["progress"],
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.value["color"],
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityCard(
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final List<Map<String, dynamic>> weeklyActivity = [
      {"day": "Mon", "value": 0.3},
      {"day": "Tue", "value": 0.7},
      {"day": "Wed", "value": 0.5},
      {"day": "Thu", "value": 0.9},
      {"day": "Fri", "value": 0.4},
      {"day": "Sat", "value": 0.2},
      {"day": "Sun", "value": 0.6},
    ];

    return Container(
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.activity,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Weekly Activity",
                style: TextStyle(
                  fontSize: 18 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  weeklyActivity.map((activity) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 24,
                          height: activity["value"] * 100,
                          decoration: BoxDecoration(
                            color: Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          activity["day"],
                          style: TextStyle(
                            fontSize: 14 * settings.fontSize,
                            fontFamily: fontFamily,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xFFDBEAFE).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color(0xFF3B82F6).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.trophy, color: Color(0xFF3B82F6), size: 18),
                SizedBox(width: 8),
                Text(
                  "Total this week: 15 hours",
                  style: TextStyle(
                    fontSize: 14 * settings.fontSize,
                    fontWeight: FontWeight.w500,
                    fontFamily: fontFamily,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
