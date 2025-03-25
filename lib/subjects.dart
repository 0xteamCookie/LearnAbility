import 'package:flutter/material.dart';

class Subjects extends StatefulWidget {
  const Subjects({super.key});

  @override
  State<Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    // Simulate API call - replace with your actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    // This would be your actual API response
    final Map<String, dynamic> response = {
      "success": true,
      "subjects": [
        {
          "id": "4ecf9a04-3f33-4515-a74e-357dcaa328e7",
          "name": "Mathematics",
          "color": "blue",
          "status": "PROCESSING",
          "createdAt": "2025-03-25T12:45:34.376Z",
          "updatedAt": "2025-03-25T13:17:57.947Z",
          "materialCount": 1
        },
        {
          "id": "e17090bf-ca88-418d-ba6d-7ede17183f1a",
          "name": "Science",
          "color": "bg-blue-500",
          "status": "COMPLETED",
          "createdAt": "2025-03-25T12:18:48.922Z",
          "updatedAt": "2025-03-25T12:39:50.537Z",
          "materialCount": 2
        },
        
      ]
    };

    if (mounted) {
      setState(() {
        subjects = List<Map<String, dynamic>>.from(response['subjects'] as List);
        isLoading = false;
      });
    }
  }

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
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Explore Subjects",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return _buildSubjectCard(subject['name'] as String);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(String subjectName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              subjectName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onStartLearning(subjectName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Start Learning'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStartLearning(String subjectName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting $subjectName')),
    );
  }
}