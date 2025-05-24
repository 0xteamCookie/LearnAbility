import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'accessibility_model.dart';
import 'repository/widgets/global_navbar.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _articles = [];
  List<String> _categories = [];
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _fetchArticles();
    _fetchCategories();
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call with delay
    await Future.delayed(Duration(milliseconds: 800));

    // Demo data - this would be replaced with actual API call
    final Map<String, dynamic> response = {
      "success": true,
      "articles": [
        {
          "id": "a1",
          "title": "Getting Started with Dart",
          "description":
              "A comprehensive guide to Dart programming language basics for beginners.",
          "thumbnailUrl": "https://via.placeholder.com/400x225",
          "articleUrl": "https://example.com/articles/dart-basics",
          "readTime": "5 min read",
          "author": "John Doe",
          "authorAvatar": "https://via.placeholder.com/50",
          "category": "Programming",
          "views": 3200,
          "likes": 450,
          "publishedAt": "2023-05-10T08:30:00Z",
          "isFeatured": true,
          "tags": ["dart", "programming", "beginners"],
        },
        {
          "id": "a2",
          "title": "Flutter Animations Guide",
          "description":
              "Learn how to create smooth and engaging animations in your Flutter applications.",
          "thumbnailUrl": "https://via.placeholder.com/400x225",
          "articleUrl": "https://example.com/articles/flutter-animations",
          "readTime": "8 min read",
          "author": "Jane Smith",
          "authorAvatar": "https://via.placeholder.com/50",
          "category": "Programming",
          "views": 2800,
          "likes": 380,
          "publishedAt": "2023-06-15T11:45:00Z",
          "isFeatured": true,
          "tags": ["flutter", "animations", "ui"],
        },
        {
          "id": "a3",
          "title": "Effective Testing in Flutter",
          "description":
              "Best practices for testing Flutter applications to ensure reliability and performance.",
          "thumbnailUrl": "https://via.placeholder.com/400x225",
          "articleUrl": "https://example.com/articles/flutter-testing",
          "readTime": "7 min read",
          "author": "Alice Johnson",
          "authorAvatar": "https://via.placeholder.com/50",
          "category": "Programming",
          "views": 1950,
          "likes": 270,
          "publishedAt": "2023-07-20T14:20:00Z",
          "isFeatured": false,
          "tags": ["flutter", "testing", "quality"],
        },
        {
          "id": "a4",
          "title": "Understanding Quantum Physics",
          "description":
              "An introduction to the fundamental principles of quantum physics and its applications.",
          "thumbnailUrl": "https://via.placeholder.com/400x225",
          "articleUrl": "https://example.com/articles/quantum-physics",
          "readTime": "10 min read",
          "author": "Dr. Richard Feynman",
          "authorAvatar": "https://via.placeholder.com/50",
          "category": "Science",
          "views": 4500,
          "likes": 620,
          "publishedAt": "2023-04-05T09:15:00Z",
          "isFeatured": true,
          "tags": ["physics", "quantum", "science"],
        },
        {
          "id": "a5",
          "title": "The Rise and Fall of Ancient Rome",
          "description":
              "Explore the history of the Roman Empire from its founding to its eventual collapse.",
          "thumbnailUrl": "https://via.placeholder.com/400x225",
          "articleUrl": "https://example.com/articles/ancient-rome",
          "readTime": "12 min read",
          "author": "Prof. Marcus Aurelius",
          "authorAvatar": "https://via.placeholder.com/50",
          "category": "History",
          "views": 3800,
          "likes": 540,
          "publishedAt": "2023-03-18T16:30:00Z",
          "isFeatured": false,
          "tags": ["history", "rome", "ancient"],
        },
      ],
    };

    setState(() {
      _articles = List<Map<String, dynamic>>.from(response['articles']);
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

  List<Map<String, dynamic>> get _filteredArticles {
    if (_selectedCategory == "All") {
      return _articles;
    }
    return _articles
        .where((article) => article['category'] == _selectedCategory)
        .toList();
  }

  List<Map<String, dynamic>> get _featuredArticles {
    return _articles.where((article) => article['isFeatured'] == true).toList();
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
                          "Educational Articles",
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
                      "Expand your knowledge through reading",
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
                            await _fetchArticles();
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

                                // Featured Articles Section
                                if (_featuredArticles.isNotEmpty) ...[
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
                                        "Featured Articles",
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

                                  // Featured Articles List
                                  for (var article in _featuredArticles)
                                    _buildArticleCard(
                                      article: article,
                                      settings: settings,
                                      fontFamily: fontFamily(),
                                    ),

                                  SizedBox(height: 24),
                                ],

                                // All Articles Section
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE0E7FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        LucideIcons.fileText,
                                        size: 18,
                                        color: Color(0XFF6366F1),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _selectedCategory == "All"
                                          ? "All Articles"
                                          : "$_selectedCategory Articles",
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

                                // Filtered Articles List
                                if (_filteredArticles.isEmpty)
                                  _buildEmptyState(settings, fontFamily())
                                else
                                  for (var article in _filteredArticles)
                                    _buildArticleCard(
                                      article: article,
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

  Widget _buildArticleCard({
    required Map<String, dynamic> article,
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
          // Thumbnail with featured badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  article['thumbnailUrl'],
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey.shade200,
                      child: Icon(
                        LucideIcons.fileText,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
              if (article['isFeatured'])
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

          // Article details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  article['title'],
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

                // Author info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(article['authorAvatar']),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    SizedBox(width: 8),
                    Text(
                      article['author'],
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
                        article['category'],
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
                  article['description'],
                  style: TextStyle(
                    fontSize: 14 * settings.fontSize,
                    fontFamily: fontFamily,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),

                // Tags
                if (article['tags'] != null && article['tags'].isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        (article['tags'] as List).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "#$tag",
                              style: TextStyle(
                                fontSize: 12 * settings.fontSize,
                                fontFamily: fontFamily,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                SizedBox(height: 16),

                // Stats and read button
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      article['readTime'],
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      LucideIcons.eye,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "${article['views']}",
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to article reader
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
                        "Read Article",
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
          Icon(LucideIcons.fileText, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "No articles found",
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
