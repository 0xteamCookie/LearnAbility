import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_first_app/domain/constants/appcolors.dart';
import 'accessibility_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'utils/constants.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? standard;
  final List<String> selectedNeeds;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.standard,
    required this.selectedNeeds,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      standard: json['standard'] as String?,
      selectedNeeds: List<String>.from(json['selectedNeeds'] ?? []),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) {
        setState(() {
          _errorMessage =
              'Authentication token not found. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true && responseBody['user'] != null) {
          setState(() {
            _userProfile = UserProfile.fromJson(responseBody['user']);
            _isLoading = false;
          });
        } else {
          throw Exception(
            'Failed to parse profile data: ${responseBody['message']}',
          );
        }
      } else {
        logger.e(
          'Failed to load profile: ${response.statusCode} ${response.body}',
        );
        throw Exception(
          'Failed to load profile. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      logger.e('Error fetching profile data: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return '';
    return fullName.split(' ').first;
  }

  String _getLastName(String fullName) {
    if (fullName.isEmpty) return '';
    List<String> parts = fullName.split(' ');
    if (parts.length > 1) {
      return parts.sublist(1).join(' ');
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Account Information',
          style: TextStyle(
            fontSize: 18 * settings.fontSize,
            color: Colors.white,
            fontFamily: fontFamily(),
          ),
        ),
        elevation: 2,
      ),
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : _errorMessage != null
                ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                : _userProfile == null
                ? Text(
                  'No profile data available.',
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                )
                : SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 28),
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _userProfile!.name,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 24 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily(),
                          ),
                        ),
                        const SizedBox(height: 28),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "First Name",
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getFirstName(_userProfile!.name),
                            style: TextStyle(
                              fontSize: 18 * settings.fontSize,
                              fontWeight: FontWeight.w600,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Last Name",
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getLastName(_userProfile!.name),
                            style: TextStyle(
                              fontSize: 18 * settings.fontSize,
                              fontWeight: FontWeight.w600,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _userProfile!.email,
                            style: TextStyle(
                              fontSize: 18 * settings.fontSize,
                              fontWeight: FontWeight.w600,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Class",
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _userProfile!.standard ?? 'Not specified',
                            style: TextStyle(
                              fontSize: 18 * settings.fontSize,
                              fontWeight: FontWeight.w600,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Primary Learning Accommodation",
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _userProfile!.selectedNeeds.isNotEmpty
                                ? _userProfile!.selectedNeeds.join(', ')
                                : 'Not specified',
                            style: TextStyle(
                              fontSize: 18 * settings.fontSize,
                              fontWeight: FontWeight.w600,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
