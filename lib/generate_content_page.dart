import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'accessibility_model.dart';
import 'domain/constants/appcolors.dart';

class Subject {
  final String id;
  final String name;
  final String color;
  String? syllabusFileName;
  List<UploadedFile> files;

  Subject({
    required this.id,
    required this.name,
    required this.color,
    this.syllabusFileName,
    required this.files,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? 'blue',
      files: [],
    );
  }
}

class Material {
  final String id;
  final String name;
  final String type;
  final String fileType;
  final int size;
  final String uploadDate;
  final String subjectId;
  final String subjectName;
  final String? thumbnail;
  final String status;

  Material({
    required this.id,
    required this.name,
    required this.type,
    required this.fileType,
    required this.size,
    required this.uploadDate,
    required this.subjectId,
    required this.subjectName,
    this.thumbnail,
    required this.status,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Material',
      type: json['type'] ?? 'unknown',
      fileType: json['fileType'] ?? 'unknown',
      size: json['size'] ?? 0,
      uploadDate: json['uploadDate'] ?? DateTime.now().toIso8601String(),
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? 'Unknown Subject',
      thumbnail: json['thumbnail'],
      status: json['status'] ?? 'unknown',
    );
  }
}

class UploadedFile {
  final String name;
  final String path;
  final String subject;
  final String topic;
  final String description;
  final String tags;

  UploadedFile({
    required this.name,
    required this.path,
    required this.subject,
    this.topic = '',
    this.description = '',
    this.tags = '',
  });
}

class GenerateContentPage extends StatefulWidget {
  const GenerateContentPage({super.key});

  @override
  State<GenerateContentPage> createState() => _GenerateContentPageState();
}

class _GenerateContentPageState extends State<GenerateContentPage> {
  List<Subject> subjects = [];
  Map<String, List<Material>> subjectMaterials = {};
  bool isLoading = true;
  bool isCreatingSubject = false;
  TextEditingController subjectNameController = TextEditingController();
  String? selectedSubjectId;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  // Add a new function to fetch subject details after the fetchMaterials function
  Future<void> fetchSubjectDetails(String subjectId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects/$subjectId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final subject = Subject.fromJson(data['subject']);
        print(subject);

        // Update the subject in the list
        int index = subjects.indexWhere((s) => s.id == subjectId);
        if (index != -1) {
          setState(() {
            // Check if syllabus exists (syllabusPath would be non-null)
            if (data['subject']['syllabusPath'] != null) {
              // Extract filename from path
              String path = data['subject']['syllabusPath'];
              String fileName = path.split('/').last;
              subjects[index].syllabusFileName = fileName;
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching subject details: $e");
    }
  }

  // Add a function to delete a subject
  Future<void> deleteSubject(String subjectId) async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects/$subjectId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Subject deleted successfully")));

        // Remove the subject from the list
        setState(() {
          subjects.removeWhere((subject) => subject.id == subjectId);
          subjectMaterials.remove(subjectId);
          if (selectedSubjectId == subjectId) {
            selectedSubjectId = null;
          }
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete subject")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting subject: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Update the fetchSubjects function to also fetch subject details
  Future<void> fetchSubjects() async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      print("JWT token not found");
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          subjects =
              (data['subjects'] as List)
                  .map((json) => Subject.fromJson(json))
                  .toList();
        });

        // Fetch materials and details for each subject
        for (var subject in subjects) {
          await fetchMaterials(subject.id);
          await fetchSubjectDetails(subject.id);
        }
      } else {
        print("Failed to fetch subjects: ${response.body}");
      }
    } catch (e) {
      print("Error fetching subjects: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMaterials(String subjectId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/pyos/materials'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<Material> allMaterials =
            (data['materials'] as List)
                .map((json) => Material.fromJson(json))
                .toList();

        // Filter materials by subject ID
        final subjectMaterialsList =
            allMaterials
                .where((material) => material.subjectId == subjectId)
                .toList();

        setState(() {
          subjectMaterials[subjectId] = subjectMaterialsList;
        });
      }
    } catch (e) {
      print("Error fetching materials: $e");
    }
  }

  Future<void> createSubject() async {
    if (subjectNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter a subject name")));
      return;
    }

    setState(() => isCreatingSubject = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      setState(() => isCreatingSubject = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': subjectNameController.text, 'color': 'blue'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final Subject newSubject = Subject.fromJson(responseData['subject']);

        setState(() {
          subjects.add(newSubject);
          subjectMaterials[newSubject.id] = [];
          selectedSubjectId = newSubject.id;
        });

        subjectNameController.clear();
        Navigator.pop(context);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Subject created successfully")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to create subject")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error creating subject: $e")));
    } finally {
      setState(() => isCreatingSubject = false);
    }
  }

  Future<void> uploadSyllabus(String subjectId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() => isLoading = true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        setState(() => isLoading = false);
        return;
      }

      try {
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

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Syllabus uploaded successfully")),
          );

          // Update the subject in the UI
          int index = subjects.indexWhere((subject) => subject.id == subjectId);
          if (index != -1) {
            setState(() {
              subjects[index].syllabusFileName = file.name;
            });
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Failed to upload syllabus")));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error uploading syllabus: $e")));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> uploadMaterial(String subjectId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() => isLoading = true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        setState(() => isLoading = false);
        return;
      }

      try {
        PlatformFile file = result.files.first;
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

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Material uploaded successfully")),
          );

          // Refresh materials for this subject
          await fetchMaterials(subjectId);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Failed to upload material")));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error uploading material: $e")));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('${Constants.uri}/api/v1/data-sources/$materialId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Material deleted successfully")),
        );

        // Update UI by refreshing all materials
        for (var subject in subjects) {
          await fetchMaterials(subject.id);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete material")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting material: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showCreateSubjectDialog() {
    subjectNameController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final settings = Provider.of<AccessibilitySettings>(context);
        final bool isDyslexic = settings.openDyslexic;
        String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Create New Subject",
                    style: TextStyle(
                      fontSize: 22 * settings.fontSize,
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
              SizedBox(height: 24),
              TextField(
                controller: subjectNameController,
                decoration: InputDecoration(
                  labelText: "Subject Name",
                  hintText: "e.g. Mathematics, Biology",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0XFF6366F1), width: 2),
                  ),
                  prefixIcon: Icon(Icons.subject),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                style: TextStyle(
                  fontSize: 16 * settings.fontSize,
                  fontFamily: fontFamily(),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isCreatingSubject ? null : createSubject,
                  child:
                      isCreatingSubject
                          ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            "Create Subject",
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontWeight: FontWeight.bold,
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

  // Update the _confirmDeleteSubject function to use the API
  void _confirmDeleteSubject(String subjectId) {
    final settings = Provider.of<AccessibilitySettings>(context, listen: false);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete Subject',
              style: TextStyle(
                fontSize: 20 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily(),
              ),
            ),
            content: Text(
              'Are you sure you want to delete this subject and all its materials? This action cannot be undone.',
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
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  deleteSubject(subjectId);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteMaterial(Material material) {
    final settings = Provider.of<AccessibilitySettings>(context, listen: false);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete Material',
              style: TextStyle(
                fontSize: 20 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily(),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete:',
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  material.name,
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  deleteMaterial(material.id);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildEmptyState() {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "No subjects created yet",
            style: TextStyle(
              fontSize: 18 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily(),
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Create a subject to start organizing your materials",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16 * settings.fontSize,
              fontFamily: fontFamily(),
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0XFF6366F1),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _showCreateSubjectDialog,
            icon: Icon(Icons.add),
            label: Text(
              "Create Subject",
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Update the _buildSubjectCard function to include a delete button
  Widget _buildSubjectCard(Subject subject) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    final materials = subjectMaterials[subject.id] ?? [];
    final isSelected = selectedSubjectId == subject.id;

    Color getSubjectColor() {
      switch (subject.color.toLowerCase()) {
        case 'blue':
          return Color(0xFF3B82F6);
        case 'red':
          return Color(0xFFEF4444);
        case 'green':
          return Color(0xFF10B981);
        case 'purple':
          return Color(0xFF8B5CF6);
        case 'yellow':
          return Color(0xFFF59E0B);
        case 'pink':
          return Color(0xFFEC4899);
        default:
          return Color(0xFF3B82F6);
      }
    }

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isSelected
                ? BorderSide(color: getSubjectColor(), width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedSubjectId = isSelected ? null : subject.id;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: getSubjectColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.subject,
                      color: getSubjectColor(),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: TextStyle(
                            fontSize: 18 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily(),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${materials.length} materials",
                          style: TextStyle(
                            fontSize: 14 * settings.fontSize,
                            color: Colors.grey.shade600,
                            fontFamily: fontFamily(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                    ),
                    onPressed: () => _confirmDeleteSubject(subject.id),
                  ),
                  IconButton(
                    icon: Icon(
                      isSelected
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade700,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedSubjectId = isSelected ? null : subject.id;
                      });
                    },
                  ),
                ],
              ),
              if (isSelected) ...[
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade800,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => uploadSyllabus(subject.id),
                        icon: Icon(Icons.book, size: 18),
                        label: Text(
                          subject.syllabusFileName != null
                              ? "Update Syllabus"
                              : "Add Syllabus",
                          style: TextStyle(
                            fontSize: 14 * settings.fontSize,
                            fontFamily: fontFamily(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF06B6D4).withOpacity(0.2),
                          foregroundColor: Color(0xFF06B6D4),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => uploadMaterial(subject.id),
                        icon: Icon(Icons.upload_file, size: 18),
                        label: Text(
                          "Add Material",
                          style: TextStyle(
                            fontSize: 14 * settings.fontSize,
                            fontFamily: fontFamily(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (subject.syllabusFileName != null) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.book,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Syllabus",
                                style: TextStyle(
                                  fontSize: 14 * settings.fontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily(),
                                  color: Colors.green.shade800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                subject.syllabusFileName!,
                                style: TextStyle(
                                  fontSize: 12 * settings.fontSize,
                                  fontFamily: fontFamily(),
                                  color: Colors.green.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 16),
                Text(
                  "Materials",
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily(),
                  ),
                ),
                SizedBox(height: 8),
                if (materials.isEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "No materials added yet",
                        style: TextStyle(
                          fontSize: 14 * settings.fontSize,
                          fontFamily: fontFamily(),
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      final material = materials[index];
                      return _buildMaterialItem(material);
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialItem(Material material) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    IconData getFileIcon() {
      switch (material.fileType.toLowerCase()) {
        case 'pdf':
          return Icons.picture_as_pdf;
        case 'jpg':
        case 'jpeg':
        case 'png':
          return Icons.image;
        case 'doc':
        case 'docx':
          return Icons.description;
        case 'xls':
        case 'xlsx':
          return Icons.table_chart;
        case 'ppt':
        case 'pptx':
          return Icons.slideshow;
        case 'txt':
        case 'json':
          return Icons.text_snippet;
        default:
          return Icons.insert_drive_file;
      }
    }

    Color getFileColor() {
      switch (material.fileType.toLowerCase()) {
        case 'pdf':
          return Colors.red.shade700;
        case 'jpg':
        case 'jpeg':
        case 'png':
          return Colors.teal.shade700;
        case 'doc':
        case 'docx':
          return Colors.blue.shade700;
        case 'xls':
        case 'xlsx':
          return Colors.green.shade700;
        case 'ppt':
        case 'pptx':
          return Colors.orange.shade700;
        case 'txt':
        case 'json':
          return Colors.purple.shade700;
        default:
          return Colors.grey.shade700;
      }
    }

    String formatFileSize(int bytes) {
      if (bytes < 1024) return "$bytes B";
      if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
      return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: getFileColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(getFileIcon(), color: getFileColor(), size: 24),
        ),
        title: Text(
          material.name,
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily(),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              material.fileType.toUpperCase(),
              style: TextStyle(
                fontSize: 12 * settings.fontSize,
                fontFamily: fontFamily(),
                color: getFileColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Text(
              "• ${formatFileSize(material.size)}",
              style: TextStyle(
                fontSize: 12 * settings.fontSize,
                fontFamily: fontFamily(),
                color: Colors.grey.shade600,
              ),
            ),
            // SizedBox(width: 8),
            // Text(
            //   "• ${formatDate(material.uploadDate)}",
            //   style: TextStyle(
            //     fontSize: 12 * settings.fontSize,
            //     fontFamily: fontFamily(),
            //     color: Colors.grey.shade600,
            //   ),
            // ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Colors.red.shade400,
            size: 20,
          ),
          onPressed: () => _confirmDeleteMaterial(material),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Learning Materials",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchSubjects,
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: fetchSubjects,
                child: CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Organize your learning resources",
                              style: TextStyle(
                                fontSize: 16 * settings.fontSize,
                                color: Colors.grey.shade700,
                                fontFamily: fontFamily(),
                              ),
                            ),
                            SizedBox(height: 16),
                            Card(
                              elevation: 0,
                              color: Color(0XFF6366F1).withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Color(0XFF6366F1).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: _showCreateSubjectDialog,
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0XFF6366F1,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Color(0XFF6366F1),
                                          size: 28,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Create New Subject",
                                              style: TextStyle(
                                                fontSize:
                                                    18 * settings.fontSize,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: fontFamily(),
                                                color: Color(0XFF6366F1),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "Add a new subject to organize your materials",
                                              style: TextStyle(
                                                fontSize:
                                                    14 * settings.fontSize,
                                                color: Colors.grey.shade700,
                                                fontFamily: fontFamily(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              "My Subjects",
                              style: TextStyle(
                                fontSize: 20 * settings.fontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily(),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${subjects.length}",
                                style: TextStyle(
                                  fontSize: 14 * settings.fontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily(),
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(16),
                      sliver:
                          subjects.isEmpty
                              ? SliverToBoxAdapter(child: _buildEmptyState())
                              : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                      _buildSubjectCard(subjects[index]),
                                  childCount: subjects.length,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
