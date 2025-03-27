import 'package:flutter/material.dart';
import 'package:vapinew/Vapinew.dart';

const VAPI_PUBLIC_KEY = '012585dc-1191-46c5-abe6-8daf08aa841d';
const VAPI_ASSISTANT_ID = 'VAPI_ASSISTANT_ID';

void main() {
  runApp(VoiceAiChat());
}

class VoiceAiChat extends StatefulWidget {
  @override
  _VoiceAiChatState createState() => _VoiceAiChatState();
}

class _VoiceAiChatState extends State<VoiceAiChat> {
  String buttonText = 'Start Call';
  bool isLoading = false;
  bool isCallStarted = false;
  Vapi vapi = Vapi(VAPI_PUBLIC_KEY);

  _VoiceAiChatState() {
    vapi.onEvent.listen((event) {
      if (event.label == "call-start") {
        setState(() {
          buttonText = 'End Call';
          isLoading = false;
          isCallStarted = true;
        });
        print('call started');
      }
      if (event.label == "call-end") {
        setState(() {
          buttonText = 'Start Call';
          isLoading = false;
          isCallStarted = false;
        });
        print('call ended');
      }
      if (event.label == "message") {
        print(event.value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Voice AI Chat')),
        body: Center(
          child: ElevatedButton(
            onPressed:
                isLoading
                    ? null
                    : () async {
                      setState(() {
                        buttonText = 'Loading...';
                        isLoading = true;
                      });

                      if (!isCallStarted) {
                        print("STARTING CALL");
                        await vapi.start(
                          assistant: {
                            "firstMessage": "Hello, I am an assistant.",
                            "model": {
                              "provider": "openai",
                              "model": "gpt-3.5-turbo",
                              "messages": [
                                {
                                  "role": "system",
                                  "content": "You are an assistant.",
                                },
                              ],
                            },
                            "voice": "jennifer-playht",
                          },
                        );
                      } else {
                        await vapi.stop();
                      }
                    },
            child: Text(buttonText),
          ),
        ),
      ),
    );
  }
}
