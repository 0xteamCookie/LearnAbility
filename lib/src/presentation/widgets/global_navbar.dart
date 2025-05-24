import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_first_app/src/presentation/screens/ai_voice_screen.dart';
import 'package:my_first_app/src/presentation/screens/videos_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_first_app/src/presentation/screens/quiz/quizzes_page.dart';
import 'package:my_first_app/src/presentation/providers/accessibility_settings_provider.dart';
import 'package:my_first_app/src/presentation/screens/accessibility_screen.dart';
import 'package:my_first_app/src/presentation/screens/ai_assistant_screen.dart';
import 'package:my_first_app/src/presentation/screens/articles_screen.dart';
import 'package:my_first_app/src/presentation/screens/generate_content_screen.dart';
import 'package:my_first_app/src/presentation/screens/home/home_screen.dart';
import 'package:my_first_app/src/presentation/screens/settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my_first_app/src/presentation/screens/stats_screen.dart';
import 'package:my_first_app/src/presentation/screens/subjects/subjects_screen.dart';

class GlobalNavBar extends StatefulWidget {
  final Widget body;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const GlobalNavBar({super.key, required this.body, this.scaffoldKey});

  @override
  State<GlobalNavBar> createState() => _GlobalNavBarState();
}

class _GlobalNavBarState extends State<GlobalNavBar> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = widget.scaffoldKey ?? GlobalKey<ScaffoldState>();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,

      // NAVIGATION MENU - Modern, clean design with requested color scheme
      endDrawer: Drawer(
        elevation: 0,
        width: MediaQuery.of(context).size.width * 0.75,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        // Wrap the SafeArea with a Container that has the gradient
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0XFF6366F1), Color(0XFF8B5CF6)],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    children: [
                      // Main menu section
                      _buildMenuSection(
                        'Main Menu',
                        [
                          _MenuItem(
                            icon: LucideIcons.bookOpen,
                            title: 'subjects'.tr(),
                            index: 9,
                            onTap: () => _navigateTo(SubjectsPage(), 9),
                          ),
                          _MenuItem(
                            icon: LucideIcons.folderOpen,
                            title: 'my_materials'.tr(),
                            index: 4,
                            onTap: () => _navigateTo(GenerateContentPage(), 4),
                          ),
                          _MenuItem(
                            icon: LucideIcons.clipboardCheck,
                            title: 'quizzes'.tr(),
                            index: 3,
                            onTap: () => _navigateTo(QuizzesPage(), 3),
                          ),
                          _MenuItem(
                            icon: LucideIcons.brain,
                            title: 'ai_assistant'.tr(),
                            index: 5,
                            onTap: () => _navigateTo(AIAssistantPage(), 5),
                          ),
                          _MenuItem(
                            icon: LucideIcons.brain,
                            title: 'ai_voice_assistant'.tr(),
                            index: 6,
                            onTap: () => _navigateTo(VoiceAiChat(), 6),
                          ),
                        ],
                        settings,
                        fontFamily(),
                      ),

                      SizedBox(height: 24),

                      // Study Materials section
                      _buildMenuSection(
                        'Study Materials',
                        [
                          _MenuItem(
                            icon: LucideIcons.video,
                            title: 'videos'.tr(),
                            index: 7,
                            onTap: () => _navigateTo(VideosPage(), 7),
                          ),
                          _MenuItem(
                            icon: LucideIcons.fileText,
                            title: 'articles'.tr(),
                            index: 8,
                            onTap: () => _navigateTo(ArticlesPage(), 8),
                          ),
                        ],
                        settings,
                        fontFamily(),
                      ),
                    ],
                  ),
                ),

                // Version info at bottom
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // Main content
          widget.body,

          // Floating bottom navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildFloatingNavBar(settings, fontFamily()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modern floating bottom navigation bar
  Widget _buildFloatingNavBar(
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final currentIndex = settings.selectedIndexBottomNavBar;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: LucideIcons.settings,
            label: 'settings'.tr(),
            isSelected: currentIndex == 0,
            onTap: () {
              settings.setSelectedIndex(0);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
            settings: settings,
            fontFamily: fontFamily,
          ),
          _buildNavItem(
            icon: LucideIcons.barChart,
            label: 'stats'.tr(),
            isSelected: currentIndex == 1,
            onTap: () {
              settings.setSelectedIndex(1);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatsPage()),
              );
            },
            settings: settings,
            fontFamily: fontFamily,
          ),
          _buildNavItem(
            icon: LucideIcons.home,
            label: 'home'.tr(),
            isSelected: currentIndex == 2,
            onTap: () {
              settings.setSelectedIndex(2);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            settings: settings,
            fontFamily: fontFamily,
          ),
          _buildNavItem(
            icon: LucideIcons.accessibility,
            label: 'access'.tr(),
            isSelected: currentIndex == 3,
            onTap: () {
              settings.setSelectedIndex(3);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccessibilityPage()),
              );
            },
            settings: settings,
            fontFamily: fontFamily,
          ),
          _buildNavItem(
            icon: LucideIcons.menu,
            label: 'menu'.tr(),
            isSelected: currentIndex == 4,
            onTap: () {
              settings.setSelectedIndex(4);
              _scaffoldKey.currentState?.openEndDrawer();
            },
            settings: settings,
            fontFamily: fontFamily,
          ),
        ],
      ),
    );
  }

  // Individual navigation item with indicator for selected state
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required AccessibilitySettings settings,
    required String fontFamily,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with indicator dot for selected state
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Color(0XFF6366F1) : Colors.grey.shade400,
                  size: 22,
                ),
                if (isSelected)
                  Positioned(
                    bottom: -4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(0XFF6366F1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0XFF6366F1) : Colors.grey.shade500,
                fontSize: 11 * settings.fontSize,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New modern menu section builder
  Widget _buildMenuSection(
    String title,
    List<_MenuItem> items,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14 * settings.fontSize,
              fontWeight: FontWeight.w500,
              fontFamily: fontFamily,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Menu items with modern styling
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children:
                items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = selectedIndex == item.index;

                  return Column(
                    children: [
                      // Menu item
                      InkWell(
                        onTap: item.onTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              SizedBox(width: 12),
                              // Title
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15 * settings.fontSize,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                              ),
                              // Indicator for selected item
                              if (isSelected)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Divider between items (except for the last one)
                      if (index < items.length - 1)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.white.withOpacity(0.05),
                          indent: 16,
                          endIndent: 16,
                        ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  void _navigateTo(Widget page, int index) {
    setState(() {
      selectedIndex = index;
    });
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

// Helper class for menu items
class _MenuItem {
  final IconData icon;
  final String title;
  final int index;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.onTap,
  });
}
