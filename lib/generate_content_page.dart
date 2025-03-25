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
  TextEditingController subjectController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController tagsController = TextEditingController();

  // Function to show create subject dialog
  // Replace your existing _createSubject function with this new version
Future<void> _createSubject() async {
  subjectNameController.clear();
  
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      final settings = Provider.of<AccessibilitySettings>(context);
      final bool isDyslexic = settings.openDyslexic;

      String fontFamily() {
        return isDyslexic ? "OpenDyslexic" : "Roboto";
      }

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add New Subject",
                  style: TextStyle(
                    fontSize: 20 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: subjectNameController,
              decoration: InputDecoration(
                labelText: "Subject Name",
                border: OutlineInputBorder(),
                hintText: "e.g. Mathematics, Biology",
              ),
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily(),
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Add Materials",
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily(),
              ),
            ),
            SizedBox(height: 8),
            // Dropdown menu similar to screenshot
            Card(
              elevation: 2,
              child: ExpansionTile(
                title: Text(
                  "Upload Options",
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                ),
                leading: Icon(Icons.add),
                children: [
                  ListTile(
                    leading: Icon(Icons.book, color: Colors.green),
                    title: Text(
                      "Upload Syllabus",
                      style: TextStyle(
                        fontSize: 16 * settings.fontSize,
                        fontFamily: fontFamily(),
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context); // Close the bottom sheet
                      if (subjectNameController.text.isNotEmpty) {
                        // Create the subject first
                        final newSubject = Subject(
                          name: subjectNameController.text,
                          files: [],
                        );
                        setState(() {
                          subjects.add(newSubject);
                        });
                        // Then upload syllabus for it
                        await _uploadSyllabus(subjects.length - 1);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Please enter a subject name first",
                              style: TextStyle(
                                fontSize: 14 * settings.fontSize,
                                fontFamily: fontFamily(),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.upload_file, color: Colors.blue),
                    title: Text(
                      "Upload Resource",
                      style: TextStyle(
                        fontSize: 16 * settings.fontSize,
                        fontFamily: fontFamily(),
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context); // Close the bottom sheet
                      if (subjectNameController.text.isNotEmpty) {
                        // Create the subject first
                        final newSubject = Subject(
                          name: subjectNameController.text,
                          files: [],
                        );
                        setState(() {
                          subjects.add(newSubject);
                        });
                        // Then upload resources for it
                        await _uploadFile(subjects.length - 1);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Please enter a subject name first",
                              style: TextStyle(
                                fontSize: 14 * settings.fontSize,
                                fontFamily: fontFamily(),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF6366F1),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (subjectNameController.text.isNotEmpty) {
                    setState(() {
                      subjects.add(
                        Subject(name: subjectNameController.text, files: []),
                      );
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Subject created successfully",
                          style: TextStyle(
                            fontSize: 14 * settings.fontSize,
                            fontFamily: fontFamily(),
                          ),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Please enter a subject name",
                          style: TextStyle(
                            fontSize: 14 * settings.fontSize,
                            fontFamily: fontFamily(),
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  "Create Subject",
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    color: Colors.white,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}


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
          backgroundColor: Colors.white,
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
  // Confirmation before deleting
  void _confirmDelete(int subjectIndex, int fileIndex) {
    final settings = Provider.of<AccessibilitySettings>(context, listen: false);
    final bool isDyslexic = settings.openDyslexic;

    // Function to determine font family
    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Confirm Delete',
              style: TextStyle(
                fontSize: 20 * settings.fontSize,
                fontFamily: fontFamily(),
              ),
            ),
            content: Text(
              'Are you sure you want to delete this file?',
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    final fileToRemove =
                        subjects[subjectIndex].files[fileIndex];
                    subjects[subjectIndex].files.removeAt(fileIndex);
                    uploadedFiles.remove(fileToRemove);
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Confirmation before deleting subject
  void _confirmDeleteSubject(int subjectIndex) {
    final settings = Provider.of<AccessibilitySettings>(context, listen: false);
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Confirm Delete Subject',
              style: TextStyle(
                fontSize: 20 * settings.fontSize,
                fontFamily: fontFamily(),
              ),
            ),
            content: Text(
              'Are you sure you want to delete this subject and all its files?',
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    // Remove all files of this subject from the global list
                    uploadedFiles.removeWhere(
                      (file) => file.subject == subjects[subjectIndex].name,
                    );
                    subjects.removeAt(subjectIndex);
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";
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
                    icon: Icon(Icons.arrow_back, size: 28, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back
                    },
                  ),
                  Text(
                    "My Materials",
                    style: TextStyle(
                      fontSize: 27 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                "Organize your learning resources by subject",
                style: TextStyle(
                  fontSize: 16 * settings.fontSize,
                  color: Colors.grey,
                  fontFamily: fontFamily(),
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Colors.white,
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.create_new_folder, color: Colors.deepPurple),
                  title: Text(
                    "Create new subject",
                    style: TextStyle(
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                  ),
                  onTap: _createSubject,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "My Subjects",
                style: TextStyle(
                  fontSize: 20 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(),
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child:
                    subjects.isEmpty
                        ? Center(
                          child: Text(
                            "No subjects created yet.",
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        )
                        : ListView.builder(
                          physics: BouncingScrollPhysics(),
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
                              leading: Icon(Icons.subject, color: Colors.deepPurple),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 24 * settings.fontSize,
                                    ),
                                    onPressed:
                                        () => _confirmDeleteSubject(subjectIndex),
                                  ),
                                ],
                              ),
                              children: [
                                // Syllabus section
                                ListTile(
                                  leading: Icon(Icons.book, color: Colors.green),
                                  title: Text(
                                    subject.syllabusFileName ?? "Upload syllabus",
                                    style: TextStyle(
                                      fontSize: 16 * settings.fontSize,
                                      fontFamily: fontFamily(),
                                      fontStyle:
                                          subject.syllabusFileName == null
                                              ? FontStyle.italic
                                              : FontStyle.normal,
                                    ),
                                  ),
                                  onTap: () => _uploadSyllabus(subjectIndex),
                                ),
                                // Upload files option
                                ListTile(
                                  leading: Icon(
                                    Icons.upload_file,
                                    color: Color(0XFF06B6D4),
                                  ),
                                  title: Text(
                                    "Upload resource",
                                    style: TextStyle(
                                      fontSize: 16 * settings.fontSize,
                                      fontFamily: fontFamily(),
                                    ),
                                  ),
                                  onTap: () => _uploadFile(subjectIndex),
                                ),
                                // Files list
                                if (subject.files.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "No files uploaded for this subject.",
                                      style: TextStyle(
                                        fontSize: 14 * settings.fontSize,
                                        fontFamily: fontFamily(),
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                else
                                  ...List.generate(subject.files.length, (
                                    fileIndex,
                                  ) {
                                    UploadedFile fileData =
                                        subject.files[fileIndex];
                                    String fileName = fileData.name;
                                    String fileExtension =
                                        fileName.split('.').last.toLowerCase();
      
                                    IconData fileIcon = Icons.insert_drive_file;
                                    Color iconColor = Colors.blue;
      
                                    switch (fileExtension) {
                                      case 'pdf':
                                        fileIcon = Icons.picture_as_pdf;
                                        iconColor = Colors.red;
                                        break;
                                      case 'jpeg':
                                      case 'jpg':
                                      case 'png':
                                        fileIcon = Icons.image;
                                        iconColor = Colors.teal;
                                        break;
                                      default:
                                        fileIcon = Icons.insert_drive_file;
                                        iconColor = Colors.grey;
                                    }
      
                                    // Truncate filename if too long
                                    String displayName = fileName;
                                    if (fileName.length > 28) {
                                      final nameParts = fileName.split('.');
                                      final extension = nameParts.last;
                                      final baseName = fileName.substring(
                                        0,
                                        fileName.length - extension.length - 1,
                                      );
      
                                      // Show first 15 chars + ... + last 10 chars
                                      if (baseName.length > 25) {
                                        displayName =
                                            '${baseName.substring(0, 15)}...${baseName.substring(baseName.length - 10)}.$extension';
                                      }
                                    }
      
                                    return Card(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      elevation: 1,
                                      child: InkWell(
                                        onLongPress: () {
                                          // Show tooltip with full filename on long press
                                          final scaffold = ScaffoldMessenger.of(
                                            context,
                                          );
                                          scaffold.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                fileName,
                                                style: TextStyle(
                                                  fontFamily: fontFamily(),
                                                  fontSize:
                                                      14 * settings.fontSize,
                                                ),
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: ListTile(
                                            leading: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: iconColor.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                fileIcon,
                                                color: iconColor,
                                              ),
                                            ),
                                            title: Text(
                                              displayName,
                                              style: TextStyle(
                                                fontSize: 14 * settings.fontSize,
                                                fontFamily: fontFamily(),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (fileData.topic.isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 4.0,
                                                        ),
                                                    child: Text(
                                                      "Topic: ${fileData.topic}",
                                                      style: TextStyle(
                                                        fontSize:
                                                            12 *
                                                            settings.fontSize,
                                                        fontFamily: fontFamily(),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                    top: 2.0,
                                                  ),
                                                  child: Text(
                                                    fileExtension.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize:
                                                          10 * settings.fontSize,
                                                      fontFamily: fontFamily(),
                                                      color: iconColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 20 * settings.fontSize,
                                              ),
                                              onPressed:
                                                  () => _confirmDelete(
                                                    subjectIndex,
                                                    fileIndex,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                              ],
                            );
                          },
                        ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}
