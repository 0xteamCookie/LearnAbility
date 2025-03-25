import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';
import 'accessibility_model.dart';

class Subject {
  final String name;
  String? syllabusFileName;
  List<UploadedFile> files;

  Subject({required this.name, this.syllabusFileName, this.files = const []});
}

class UploadedFile {
  final String name;
  final String subject;
  final String topic;

  UploadedFile({
    required this.name,
    required this.subject,
    required this.topic,
  });
}

class GenerateContentPage extends StatefulWidget {
  const GenerateContentPage({super.key});

  @override
  State<GenerateContentPage> createState() => _GenerateContentPageState();
}

class _GenerateContentPageState extends State<GenerateContentPage> {
  List<Subject> subjects = [];
  List<UploadedFile> uploadedFiles = [];
  int? selectedSubjectIndex;

  // Controllers for input fields
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

  // Function to upload syllabus for a subject
  Future<void> _uploadSyllabus(int subjectIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    final settings = Provider.of<AccessibilitySettings>(context, listen: false);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        subjects[subjectIndex].syllabusFileName = file.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Syllabus uploaded successfully",
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
            "No file selected",
            style: TextStyle(
              fontSize: 14 * settings.fontSize,
              fontFamily: fontFamily(),
            ),
          ),
        ),
      );
    }
  }

  // Function to handle file upload by Pranjal
  Future<void> _uploadFile(int subjectIndex) async {
    selectedSubjectIndex = subjectIndex;
    topicController.clear();
    descriptionController.clear();
    tagsController.clear();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final settings = Provider.of<AccessibilitySettings>(context);
        final bool isDyslexic = settings.openDyslexic;

        // Function to determine font family
        String fontFamily() {
          return isDyslexic ? "OpenDyslexic" : "Roboto";
        }

        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Upload Files to ${subjects[subjectIndex].name}",
            style: TextStyle(
              fontSize: 20 * settings.fontSize,
              fontFamily: fontFamily(),
            ),
          ),
          content: SizedBox(
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Upload files to your learning materials library.",
                    style: TextStyle(
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Topic (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                  ),
                  TextField(
                    controller: topicController,
                    decoration: InputDecoration(
                      hintText: "Enter topic",
                      hintStyle: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily(),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Description (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: "Enter a description for these files",
                      hintStyle: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily(),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Tags (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                  ),
                  TextField(
                    controller: tagsController,
                    decoration: InputDecoration(
                      hintText: "Add tags",
                      hintStyle: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily(),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      fontFamily: fontFamily(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 16 * settings.fontSize,
                  fontFamily: fontFamily(),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Handle file upload
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpeg', 'jpg', 'png'],
                );

                if (result != null) {
                  PlatformFile file = result.files.first;
                  final newFile = UploadedFile(
                    name: file.name,
                    subject: subjects[subjectIndex].name,
                    topic: topicController.text,
                  );

                  setState(() {
                    // Add to both global list and subject-specific list
                    uploadedFiles.add(newFile);
                    subjects[subjectIndex].files.add(newFile);
                  });
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "No file selected",
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
                "Upload",
                style: TextStyle(
                  fontSize: 16 * settings.fontSize,
                  fontFamily: fontFamily(),
                ),
              ),
            ),
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

    // Function to determine font family
    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

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
