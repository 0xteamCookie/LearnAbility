import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'accessibility_model.dart';
import 'repository/widgets/global_navbar.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _videos = [];
  List<String> _categories = [];
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _fetchVideos();
    _fetchCategories();
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call with delay
    await Future.delayed(Duration(milliseconds: 800));

    // Demo data - this would be replaced with actual API call
    final Map<String, dynamic> response = {
      "success": true,
      "videos": [
        {
          "id": "v1",
          "title": "Introduction to Flutter",
          "description":
              "Learn the basics of Flutter framework and how to get started with your first app.",
          "thumbnailUrl": "https://via.placeholder.com/400x225",
          "videoUrl": "https://example.com/videos/intro-to-flutter",
          "duration": "10:25",
          "creator": "John Doe",
          "creatorAvatar": "https://via.placeholder.com/50",
          "category": "Programming",
          "views": 1250,
          "likes": 230,
          "createdAt": "2023-05-15T10:30:00Z",
          "isFeatured": true,
        },
        {
          "id": "v2",
          "title": "Advanced State Management",
          "description":
              "Deep dive into state management techniques in Flutter applications.",
          "thumbnailUrl": "https://via.placeholder.com/400x225",
          "videoUrl": "https://example.com/videos/state-management",
          "duration": "15:40",
          "creator": "Jane Smith",
          "creatorAvatar": "https://via.placeholder.com/50",
          "category": "Programming",
          "views": 980,
          "likes": 185,
          "createdAt": "2023-06-20T14:15:00Z",
          "isFeatured": true,
        },
        {
          "id": "v3",
          "title": "Building Responsive UIs",
          "description":
              "Learn how to create responsive user interfaces that work on all screen sizes.",
          "thumbnailUrl": "https://via.placeholder.com/400x225",
          "videoUrl": "https://example.com/videos/responsive-ui",
          "duration": "12:30",
          "creator": "Alice Johnson",
          "creatorAvatar": "https://via.placeholder.com/50",
          "category": "Design",
          "views": 750,
          "likes": 120,
          "createdAt": "2023-07-05T09:45:00Z",
          "isFeatured": false,
        },
        {
          "id": "v4",
          "title": "Mathematics: Calculus Fundamentals",
          "description":
              "Introduction to basic calculus concepts and problem-solving techniques.",
          "thumbnailUrl": "https://via.placeholder.com/400x225",
          "videoUrl": "https://example.com/videos/calculus-basics",
          "duration": "18:15",
          "creator": "Prof. Robert Chen",
          "creatorAvatar": "https://via.placeholder.com/50",
          "category": "Mathematics",
          "views": 2100,
          "likes": 340,
          "createdAt": "2023-04-10T11:20:00Z",
          "isFeatured": true,
        },
        {
          "id": "v5",
          "title": "History of Ancient Civilizations",
          "description":
              "Explore the rise and fall of major ancient civilizations and their contributions.",
          "thumbnailUrl": "https://via.placeholder.com/400x225",
          "videoUrl": "https://example.com/videos/ancient-civilizations",
          "duration": "22:50",
          "creator": "Dr. Emily Williams",
          "creatorAvatar": "https://via.placeholder.com/50",
          "category": "History",
          "views": 1850,
          "likes": 290,
          "createdAt": "2023-03-25T16:40:00Z",
          "isFeatured": false,
        },
      ],
    };

    setState(() {
      _videos = List<Map<String, dynamic>>.from(response['videos']);
      _isLoading = false;
    });
  }

  Future<void> _fetchCategories() async {
    // Simulate API call with delay
    await Future.delayed(Duration(milliseconds: 500));

    // Demo data - this would be replaced with actual API call
    final Map<String, dynamic> response = {
      "success": true,
      "categories": [
        "All",
        "Programming",
        "Mathematics",
        "Science",
        "History",
        "Design",
        "Technology",
      ],
    };

    setState(() {
      _categories = List<String>.from(response['categories']);
    });
  }

  List<Map<String, dynamic>> get _filteredVideos {
    if (_selectedCategory == "All") {
      return _videos;
    }
    return _videos
        .where((video) => video['category'] == _selectedCategory)
        .toList();
  }

  List<Map<String, dynamic>> get _featuredVideos {
    return _videos.where((video) => video['isFeatured'] == true).toList();
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
                        Text(
                          "Educational Videos",
                          style: TextStyle(
                            fontSize: 24 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily(),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Learn through visual content",
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
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: Color(0XFF6366F1),
                          ),
                        )
                        : RefreshIndicator(
                          onRefresh: () async {
                            await _fetchVideos();
                            await _fetchCategories();
                          },
                          color: Color(0XFF6366F1),
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Chips
                                SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _categories.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: _buildCategoryChip(
                                          _categories[index],
                                          settings,
                                          fontFamily(),
                                          isSelected:
                                              _selectedCategory ==
                                              _categories[index],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 24),

                                // Featured Videos Section
                                if (_featuredVideos.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE0E7FF),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          LucideIcons.star,
                                          size: 18,
                                          color: Color(0XFF6366F1),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Featured Videos",
                                        style: TextStyle(
                                          fontSize: 20 * settings.fontSize,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: fontFamily(),
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),

                                  // Featured Videos List
                                  for (var video in _featuredVideos)
                                    _buildVideoCard(
                                      video: video,
                                      settings: settings,
                                      fontFamily: fontFamily(),
                                    ),

                                  SizedBox(height: 24),
                                ],

                                // All Videos Section
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE0E7FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        LucideIcons.video,
                                        size: 18,
                                        color: Color(0XFF6366F1),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _selectedCategory == "All"
                                          ? "All Videos"
                                          : "$_selectedCategory Videos",
                                      style: TextStyle(
                                        fontSize: 20 * settings.fontSize,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily(),
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),

                                // Filtered Videos List
                                if (_filteredVideos.isEmpty)
                                  _buildEmptyState(settings, fontFamily())
                                else
                                  for (var video in _filteredVideos)
                                    _buildVideoCard(
                                      video: video,
                                      settings: settings,
                                      fontFamily: fontFamily(),
                                    ),

                                // Add extra padding at the bottom for the floating navbar
                                SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    AccessibilitySettings settings,
    String fontFamily, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0XFF6366F1) : Color(0xFFE0E7FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0XFF6366F1) : Color(0xFFE0E7FF),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: fontFamily,
            color: isSelected ? Colors.white : Color(0XFF6366F1),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard({
    required Map<String, dynamic> video,
    required AccessibilitySettings settings,
    required String fontFamily,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
          // Thumbnail with duration
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  video['thumbnailUrl'],
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey.shade200,
                      child: Icon(
                        LucideIcons.video,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    video['duration'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12 * settings.fontSize,
                      fontWeight: FontWeight.w500,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.play,
                      color: Color(0XFF6366F1),
                      size: 30,
                    ),
                  ),
                ),
              ),
              if (video['isFeatured'])
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0XFF6366F1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.star, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          "Featured",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12 * settings.fontSize,
                            fontWeight: FontWeight.w500,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Video details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  video['title'],
                  style: TextStyle(
                    fontSize: 18 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),

                // Creator info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(video['creatorAvatar']),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    SizedBox(width: 8),
                    Text(
                      video['creator'],
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video['category'],
                        style: TextStyle(
                          fontSize: 12 * settings.fontSize,
                          fontFamily: fontFamily,
                          color: Color(0XFF6366F1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Description
                Text(
                  video['description'],
                  style: TextStyle(
                    fontSize: 14 * settings.fontSize,
                    fontFamily: fontFamily,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),

                // Stats and watch button
                Row(
                  children: [
                    Icon(
                      LucideIcons.eye,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "${video['views']} views",
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      LucideIcons.heart,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "${video['likes']}",
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to video player
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0XFF6366F1),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Watch Now",
                        style: TextStyle(
                          fontSize: 14 * settings.fontSize,
                          fontWeight: FontWeight.w500,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AccessibilitySettings settings, String fontFamily) {
    return Container(
      padding: EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.videoOff, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "No videos found",
            style: TextStyle(
              fontSize: 18 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Try selecting a different category or check back later for new content",
            style: TextStyle(
              fontSize: 14 * settings.fontSize,
              fontFamily: fontFamily,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
