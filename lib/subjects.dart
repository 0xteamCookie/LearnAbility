import 'package:flutter/material.dart';
import 'dart:async';
import 'Lesson/lessons_page.dart';

class Subjects extends StatefulWidget {
  const Subjects({super.key});

  @override
  State<Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;
  Timer? _pollingTimer;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
    _startConditionalPolling();
  }

  void _startConditionalPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isLoading && _hasProcessingSubjects()) {
        _fetchSubjects();
      } else if (!_hasProcessingSubjects()) {
        timer.cancel();
      }
    });
  }

  bool _hasProcessingSubjects() {
    return subjects.any((subject) => subject['status'] == 'PROCESSING');
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSubjects() async {
    try {
      setState(() => isLoading = true);
      await Future.delayed(const Duration(milliseconds: 500));
      
      final Map<String, dynamic> response = {
        "success": true,
        "subjects": [
          {
            "id": "4ecf9a04-3f33-4515-a74e-357dcaa328e7",
            "name": "Mathematics",
            "color": "blue",
            "status": "COMPLETED",
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
          {
            "id": "0e8985f8-05bd-4197-ae63-b7d36300d5d4",
            "name": "English",
            "color": "bg-blue-500",
            "status": "PROCESSING",
            "createdAt": "2025-03-25T12:18:57.097Z",
            "updatedAt": "2025-03-25T12:18:57.097Z",
            "materialCount": 0
          },
        ]
      };

      if (mounted) {
        setState(() {
          subjects = List<Map<String, dynamic>>.from(response['subjects'] as List);
          isLoading = false;
          _hasError = false;
          
          if (_hasProcessingSubjects() && (_pollingTimer == null || !_pollingTimer!.isActive)) {
            _startConditionalPolling();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load subjects: $e')),
        );
        
        if (_hasProcessingSubjects() && (_pollingTimer == null || !_pollingTimer!.isActive)) {
          _startConditionalPolling();
        }
      }
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
              if (_hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Failed to load subjects. Pull to refresh.',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              Expanded(
                child: isLoading && subjects.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _fetchSubjects,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: subjects.length,
                          itemBuilder: (context, index) {
                            final subject = subjects[index];
                            return _buildSubjectCard(
                              subject['name'] as String,
                              subject['status'] as String,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(String subjectName, String status) {
    final isProcessing = status == 'PROCESSING';
    
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _getSubjectIcon(subjectName),
                  size: 60,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: isProcessing
                  ? _buildProcessingButton()
                  : ElevatedButton(
                      onPressed: () => _navigateToLessons(subjectName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
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

  Widget _buildProcessingButton() {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Generating...'),
          SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLessons(String subjectName) {
    _onStartLearning(subjectName);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LessonsPage()),
    );
  }

  void _onStartLearning(String subjectName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting $subjectName')),
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'biology': return Icons.eco;
      case 'mathematics': return Icons.calculate;
      case 'chemistry': return Icons.science;
      case 'computer': return Icons.computer;
      case 'english': return Icons.menu_book;
      case 'physics': return Icons.bolt;
      case 'science': return Icons.science;
      default: return Icons.book;
    }
  }
}