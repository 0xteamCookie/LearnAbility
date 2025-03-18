import "package:flutter/material.dart";

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<ArticlesPage> {
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

      body: Text("This is Articles page"),
    );
  }
}