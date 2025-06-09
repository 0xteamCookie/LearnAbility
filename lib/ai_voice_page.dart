import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_first_app/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:vapinew/vapinew.dart';
import 'accessibility_model.dart';
import 'domain/constants/appcolors.dart';

// ignore: constant_identifier_names
const VAPI_PUBLIC_KEY = '012585dc-1191-46c5-abe6-8daf08aa841d';

void main() {
  runApp(const VoiceAiChat());
}

class VoiceAiChat extends StatefulWidget {
  const VoiceAiChat({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VoiceAiChatState createState() => _VoiceAiChatState();
}

class _VoiceAiChatState extends State<VoiceAiChat> {
  String buttonText = 'Start Talking';
  bool isLoading = false;
  bool isCallStarted = false;
  final Vapi vapi = Vapi(VAPI_PUBLIC_KEY);
  final List<Map<String, dynamic>> _chatHistory = [];

  final Map<String, Widget Function(BuildContext)> routeMap = {
    "/settings": (context) => SettingsPage(),
  };

  _VoiceAiChatState() {
    vapi.onEvent.listen((event) {
      try {
        final Map<String, dynamic> messageData = jsonDecode(event.value);

        print(messageData);

        if (messageData["type"] == "transcript" &&
            messageData["transcriptType"] == "final") {
          setState(() {
            _chatHistory.add({
              'role': messageData["role"],
              'message': messageData["transcript"],
            });
          });
        }

        if (messageData['type'] == 'tool-calls') {
          final dynamic toolCalls = messageData['toolCalls'];
          if (toolCalls is List && toolCalls.isNotEmpty) {
            final dynamic firstToolCall = toolCalls[0];
            if (firstToolCall is Map &&
                firstToolCall['type'] == 'function') {
              final dynamic functionCallDetails = firstToolCall['function'];
              if (functionCallDetails is Map &&
                  functionCallDetails['name'] == 'navigate') {
                final dynamic arguments = functionCallDetails['arguments'];
                if (arguments is Map && arguments['path'] is String) {
                  final String path = arguments['path'] as String;
                  print('Navigating via tool-call to path: $path');
                  _navigateToPage(path);
                }
              }
            }
          }
        }
      } catch (e) {
        print("Error decoding event data: $e");
      }
    });
  }

  Future<void> _handleMicPress() async {
    setState(() {
      isLoading = true;
      buttonText = isCallStarted ? 'Ending Call...' : 'Starting Call...';
    });

    if (!isCallStarted) {
      final assistantConfig = {
        "name": "miss-williams",
        "model": {
          "provider": "openai",
          "model": "gpt-3.5-turbo",
          "temperature": 0.7,
          "systemPrompt":
              "You are Miss Williams, a knowledgeable and friendly teacher...",
          "functions": [
            {
              "name": "navigate",
              "async": true,
              "description": "Navigate to a specific route on the app",
              "parameters": {
                "type": "object",
                "properties": {
                  "path": {
                    "type": "string",
                    "description":
                        "The route path to navigate to, e.g., '/dashboard', '/settings', /pyos, '/calendar, /assistant, /voice-assistant",
                  },
                },
                "required": ["path"],
              },
            },
          ],
          "tools":[
            {
              "type": "endCall"
            }
          ]
        },
        "voice": {"provider": "11labs", "voiceId": "paula"},
        "firstMessage":
            "Hello! I'm Miss Williams. Ask me anything—I'm here to help!",
        "serverUrl": "https://08ae-202-43-120-244.ngrok-free.app/api/webhook",
      };

      await vapi.start(assistant: assistantConfig);
    } else {
      print("Ending AI Voice Assistant...");
      await vapi.stop();
    }
  }

  void _navigateToPage(String path) {
    final navigateTo = routeMap[path];

    if (navigateTo != null) {
      Navigator.push(context, MaterialPageRoute(builder: navigateTo));
    } else {
      print("Unknown route: $path");
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Icon(
                  Icons.mic,
                  color: AppColors.primaryBackground,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Voice AI Chat',
                style: TextStyle(
                  fontSize: 18 * settings.fontSize,
                  color: Colors.white,
                  fontFamily: fontFamily(),
                ),
              ),
            ],
          ),
          elevation: 2,
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
              Expanded(
                child:
                    _chatHistory.isEmpty
                        ? _buildEmptyState(settings, fontFamily)
                        : _buildChatHistory(settings, fontFamily),
              ),
              _buildMicButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    AccessibilitySettings settings,
    String Function() fontFamily,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mic_none,
            size: 80 * settings.fontSize,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Talk to Your AI Assistant',
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
              'Tap the mic button below and ask anything!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                color: Colors.grey[600],
                fontFamily: fontFamily(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistory(
    AccessibilitySettings settings,
    String Function() fontFamily,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: _chatHistory.length,
      itemBuilder: (context, index) {
        final chat = _chatHistory[index];
        final bool isUser = chat['role'] == 'user';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: isUser ? 40 : 0,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primaryBackground : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                fontSize: 15 * settings.fontSize,
                color: isUser ? Colors.white : Colors.black87,
                fontFamily: fontFamily(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMicButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FloatingActionButton(
        onPressed: isLoading ? null : _handleMicPress,
        backgroundColor: AppColors.primaryBackground,
        child: Icon(
          isCallStarted ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }
}
