import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'accessibility_model.dart';

class Subject {
  final String id;
  final String name;
  final String color;
  String? syllabusFileName;

  Subject({
    required this.id,
    required this.name,
    required this.color,
    this.syllabusFileName,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? 'blue',
    );
  }
}

class GenerateContentPage extends StatefulWidget {
  const GenerateContentPage({super.key});

  @override
  State<GenerateContentPage> createState() => _GenerateContentPageState();
}

class _GenerateContentPageState extends State<GenerateContentPage> {
  List<Subject> subjects = [];
  bool isLoading = true;
  TextEditingController subjectNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> uploadSyllabus(String subjectId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) return;

      print("SYLLABUS STARTING UPLOADDD");
      PlatformFile file = result.files.first;
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects/syllabus'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['subjectId'] = subjectId;
      request.files.add(
        await http.MultipartFile.fromPath('document', file.path!),
      );

      final response = await request.send();
      print("SYLLABUS UPLOADDEDDD");
      print(response.stream);

      if (response.statusCode == 200) {
        print("Syllabus uploaded successfully");
      } else {
        print("Failed to upload syllabus: ${response.reasonPhrase}");
      }
    }
  }

  // Upload Material Function
  Future<void> uploadMaterial(String subjectId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) return;

      PlatformFile file = result.files.first;
      print("MATERIAL STARTING UPLOADDD");
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.uri}/api/v1/pyos/materials'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['subjectId'] = subjectId;
      request.files.add(
        await http.MultipartFile.fromPath('documents', file.path!),
      );

      final response = await request.send();

      print("MATERIAL UPLOADDD");
      if (response.statusCode == 200) {
        print("Material uploaded successfully");
      } else {
        print("Failed to upload material: ${response.reasonPhrase}");
      }
    }
  }

  Future<void> fetchSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      print("JWT token not found");
      setState(() => isLoading = false);
      return;
    }
    print("SEARCHING SUBJECTS");

    final response = await http.get(
      Uri.parse('${Constants.uri}/api/v1/pyos/subjects'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("DONE SUBJECTS");
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        subjects =
            (data['subjects'] as List)
                .map((json) => Subject.fromJson(json))
                .toList();
        isLoading = false;
      });
    } else {
      print("Failed to fetch subjects: ${response.body}");
      setState(() => isLoading = false);
    }
  }

  Future<void> createSubject() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      print("JWT token not found");
      return;
    }

    if (subjectNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter a subject name")));
      return;
    }

    print("POSTING SUBJECTS");
    final response = await http.post(
      Uri.parse('${Constants.uri}/api/v1/pyos/subjects'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': subjectNameController.text,
        'color': 'blue',
      }), // Default color
    );

    print("POSTED SUBJECTS");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("POSTED SUBJECTS1");
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final Subject newSubject = Subject.fromJson(responseData['subject']);
      setState(() {
        subjects.add(newSubject);
      });
      Navigator.pop(context); // Close dialog
    } else {
      print("Failed to create subject: ${response.body}");
    }
  }

  Future<void> _showCreateSubjectDialog() async {
    subjectNameController.clear();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final settings = Provider.of<AccessibilitySettings>(context);
        final bool isDyslexic = settings.openDyslexic;
        String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

        return AlertDialog(
          title: Text(
            "Create Subject",
            style: TextStyle(
              fontSize: 20 * settings.fontSize,
              fontFamily: fontFamily(),
            ),
          ),
          content: TextField(
            controller: subjectNameController,
            decoration: InputDecoration(hintText: "Enter subject name"),
            style: TextStyle(
              fontSize: 14 * settings.fontSize,
              fontFamily: fontFamily(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(onPressed: createSubject, child: Text("Create")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "LearnAbility",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24 * settings.fontSize,
            fontFamily: fontFamily(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Subjects",
              style: TextStyle(
                fontSize: 20 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showCreateSubjectDialog,
              child: Text("Create New Subject"),
            ),
            const SizedBox(height: 16),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : subjects.isEmpty
                ? Center(
                  child: Text(
                    "No subjects found.",
                    style: TextStyle(
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                  ),
                )
                : Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: subjects.length,
                    itemBuilder: (context, subjectIndex) {
                      Subject subject = subjects[subjectIndex];
                      return ExpansionTile(
                        title: Text(
                          subject.name,
                          style: TextStyle(
                            fontSize: 18 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily(),
                          ),
                        ),
                        leading: Icon(Icons.subject, color: Colors.blue),
                        children: [
                          ListTile(
                            leading: Icon(Icons.book, color: Colors.green),
                            title: Text(
                              subject.syllabusFileName ?? "Upload syllabus",
                              style: TextStyle(
                                fontSize: 16 * settings.fontSize,
                              ),
                            ),
                            onTap: () => uploadSyllabus(subject.id),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.upload_file,
                              color: Colors.blue,
                            ),
                            title: Text(
                              "Upload resource",
                              style: TextStyle(
                                fontSize: 16 * settings.fontSize,
                              ),
                            ),
                            onTap: () => uploadMaterial(subject.id),
                          ),
                        ],
                        // children: [
                        //   ListTile(
                        //     leading: Icon(Icons.book, color: Colors.green),
                        //     title: Text(
                        //       subject.syllabusFileName ?? "Upload syllabus",
                        //       style: TextStyle(
                        //         fontSize: 16 * settings.fontSize,
                        //         fontFamily: fontFamily(),
                        //       ),
                        //     ),
                        //   ),
                        // ],
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
