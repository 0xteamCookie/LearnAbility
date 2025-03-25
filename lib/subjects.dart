import 'package:flutter/material.dart';

class Subjects extends StatefulWidget {
  const Subjects({super.key});

  @override
  State<Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
  final List<SubjectCard> subjects = [
    SubjectCard(
      title: 'Mathematics',
      description: 'Learn algebra, geometry, calculus and more',
      totalLessons: 2,
      startedLessons: 1,
    ),
    SubjectCard(
      title: 'Science',
      description: 'Discover physics, chemistry, biology and more',
      totalLessons: 1,
      startedLessons: 1,
    ),
    SubjectCard(
      title: 'English',
      description: 'Master grammar, literature, writing and more',
      totalLessons: 0,
      startedLessons: 0,
    ),
    SubjectCard(
      title: 'History',
      description: 'Explore world history, civilizations, and historical events',
      totalLessons: 0,
      startedLessons: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Explore Subjects",
                    style: TextStyle(
                      fontSize: 24 ,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    return _buildSubjectCard(subjects[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(SubjectCard subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subject.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${subject.totalLessons} lessons',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle explore action
                  },
                  child: const Text('Explore'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectCard {
  final String title;
  final String description;
  final int totalLessons;
  final int startedLessons;

  SubjectCard({
    required this.title,
    required this.description,
    required this.totalLessons,
    required this.startedLessons,
  });
}