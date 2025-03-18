import "package:flutter/material.dart";

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<VideosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,

          //APP NAME
          title: Text(
            "LearnAbility",
              style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
          ),
        ),

      body: Text("This is Videos page"),
    );
  }
}