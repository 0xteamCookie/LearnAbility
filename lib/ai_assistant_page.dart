import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'utils/constants.dart';
import 'domain/constants/appcolors.dart';
import 'accessibility_model.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _response = '';
  bool _isLoading = false;
  final List<Map<String, dynamic>> _chatHistory = [];

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendQuery() async {
    if (_queryController.text.trim().isEmpty) return;

    final userQuery = _queryController.text;
    _queryController.clear();

    setState(() {
      _isLoading = true;
      // Add user message to chat history
      _chatHistory.add({
        'role': 'user',
        'message': userQuery,
        'timestamp': DateTime.now(),
      });
    });

    _scrollToBottom();

    try {
      // Get API host from constants and JWT token from SharedPreferences
      final apiHost = Constants.uri;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        setState(() {
          _chatHistory.add({
            'role': 'assistant',
            'message': 'Error: You are not logged in. Please log in first.',
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
        });
        _scrollToBottom();
        return;
      }

      final response = await http.post(
        Uri.parse('$apiHost/api/v1/user-query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'query': userQuery}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _response = data['answer'] ?? 'No response from assistant';
          // Add AI response to chat history
          _chatHistory.add({
            'role': 'assistant',
            'message': _response,
            'timestamp': DateTime.now(),
          });
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode}';
          // Add error message to chat history
          _chatHistory.add({
            'role': 'assistant',
            'message': 'Error: Could not get a response. Please try again.',
            'timestamp': DateTime.now(),
          });
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        // Add error message to chat history
        _chatHistory.add({
          'role': 'assistant',
          'message': 'Error: Could not connect to the assistant.',
          'timestamp': DateTime.now(),
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Icon(
                Icons.assistant,
                color: AppColors.primaryBackground,
                size: 20 * settings.fontSize,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AI Learning Assistant',
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                color: Colors.white,
                fontFamily: fontFamily(),
              ),
            ),
          ],
        ),
        elevation: 2,
        backgroundColor: AppColors.primaryBackground,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.grey[100]!],
          ),
        ),
        child: Column(
          children: [
            // Chat history display
            Expanded(
              child: _chatHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80 * settings.fontSize,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Your AI Learning Assistant',
                            style: TextStyle(
                              fontSize: 20 * settings.fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              fontFamily: fontFamily(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Ask me anything about your courses, assignments, or learning materials!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16 * settings.fontSize,
                                color: Colors.grey[600],
                                fontFamily: fontFamily(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.lightbulb_outline),
                            label: Text(
                              'Try an example question',
                              style: TextStyle(fontFamily: fontFamily()
                              , fontSize: 18 * settings.fontSize),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBackground,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              _queryController.text =
                                  "Explain the concept of object-oriented programming";
                              _sendQuery();
                            },
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator as the last item when loading
                        if (_isLoading && index == _chatHistory.length) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(
                                top: 12,
                                bottom: 12,
                                right: 80,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryBackground,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Thinking...',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 14 * settings.fontSize,
                                      fontFamily: fontFamily(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final chat = _chatHistory[index];
                        final bool isUser = chat['role'] == 'user';
                        final timestamp = chat['timestamp'] as DateTime;

                        return Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isUser)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      bottom: 4,
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: AppColors
                                          .primaryBackground
                                          .withOpacity(0.8),
                                      radius: 12,
                                      child: const Icon(
                                        Icons.assistant,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: isUser ? 0 : 4,
                                    right: isUser ? 12 : 0,
                                    bottom: 4,
                                  ),
                                  child: Text(
                                    isUser ? 'You' : 'Assistant',
                                    style: TextStyle(
                                      fontSize: 12 * settings.fontSize,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                      fontFamily: fontFamily(),
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatTimestamp(timestamp),
                                  style: TextStyle(
                                    fontSize: 10 * settings.fontSize,
                                    color: Colors.grey[500],
                                    fontFamily: fontFamily(),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.only(
                                  bottom: 16,
                                  left: isUser ? 80 : 0,
                                  right: isUser ? 0 : 80,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? AppColors.primaryBackground
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  chat['message'] ?? '',
                                  style: TextStyle(
                                    color: isUser
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 15 * settings.fontSize,
                                    height: 1.4,
                                    fontFamily: fontFamily(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            // Input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -1),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14 * settings.fontSize,
                          fontFamily: fontFamily(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBackground.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _sendQuery,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22 * settings.fontSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
