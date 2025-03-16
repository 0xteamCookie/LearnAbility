import 'dart:ffi';

import 'package:flutter/material.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text("LearnAbility",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ), 

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Photosynthesis",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
            ),
            Text('Science - Chapter 4'),
            Text('What is Photosynthesis?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            ),
            Text('Photosynthesis is the process throught with vla bla asdf sfjnsdf snfjsdn sfjnsf m sdjfnksdf kfsdfjnks sfdnkdnks sdhf sdfnks sjfnkd their own food!'),
            Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Photosynthesis_en.svg/1200px-Photosynthesis_en.svg.png')
          ],
        )
        ,
    );
  }
}