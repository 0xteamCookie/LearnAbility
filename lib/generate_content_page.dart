import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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

  UploadedFile({
    required this.name,
    required this.subject,
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

  // Function to show create subject dialog
  Future<void> _createSubject() async {
    subjectNameController.clear();

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
          title: Text(
            "Create Subject",
            style: TextStyle(
              fontSize: 20 * settings.fontSize,
              fontFamily: fontFamily(),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Subject Name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * settings.fontSize,
                  fontFamily: fontFamily(),
                ),
              ),
              TextField(
                controller: subjectNameController,
                decoration: InputDecoration(
                  hintText: "Enter subject name",
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
              onPressed: () {
                if (subjectNameController.text.isNotEmpty) {
                  setState(() {
                    subjects.add(
                      Subject(name: subjectNameController.text, files: []),
                    );
                  });
                  Navigator.of(context).pop();
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
                "Create",
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

    final settings = Provider.of<AccessibilitySettings>(context, listen: false);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    // Directly open file picker without showing dialog first
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpeg', 'jpg', 'png', 'doc', 'docx', 'ppt', 'pptx'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      final newFile = UploadedFile(
        name: file.name,
        subject: subjects[subjectIndex].name,
      );

      setState(() {
        // Add to both global list and subject-specific list
        uploadedFiles.add(newFile);
        subjects[subjectIndex].files.add(newFile);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[700],
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "File uploaded successfully",
                  style: TextStyle(
                    fontSize: 14 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "No file selected",
                  style: TextStyle(
                    fontSize: 14 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
    }
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        title: Text(
          "LearnAbility",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily(),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Materials",
                style: TextStyle(
                  fontSize: 27 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(),
                  color: Colors.blue.shade800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Organize your learning resources by subject",
                style: TextStyle(
                  fontSize: 16 * settings.fontSize,
                  color: Colors.grey.shade700,
                  fontFamily: fontFamily(),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.blue.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.create_new_folder, color: Colors.white),
                    ),
                    title: Text(
                      "Create new subject",
                      style: TextStyle(
                        fontSize: 16 * settings.fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily(),
                      ),
                    ),
                    onTap: _createSubject,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.folder_special, color: Colors.blue.shade700),
                  SizedBox(width: 8),
                  Text(
                    "My Subjects",
                    style: TextStyle(
                      fontSize: 20 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily(),
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: subjects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No subjects created yet.",
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontFamily: fontFamily(),
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Create a subject to get started!",
                            style: TextStyle(
                              fontSize: 14 * settings.fontSize,
                              fontFamily: fontFamily(),
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: subjects.length,
                      itemBuilder: (context, subjectIndex) {
                        Subject subject = subjects[subjectIndex];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ExpansionTile(
                            childrenPadding: EdgeInsets.only(bottom: 12),
                            tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              subject.name,
                              style: TextStyle(
                                fontSize: 18 * settings.fontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily(),
                                color: Colors.blue.shade800,
                              ),
                            ),
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.subject, color: Colors.blue.shade700),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${subject.files.length} files",
                                  style: TextStyle(
                                    fontSize: 14 * settings.fontSize,
                                    color: Colors.grey,
                                    fontFamily: fontFamily(),
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red.shade300,
                                    size: 24 * settings.fontSize,
                                  ),
                                  onPressed: () => _confirmDeleteSubject(subjectIndex),
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
                                    fontStyle: subject.syllabusFileName == null
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                                onTap: () => _uploadSyllabus(subjectIndex),
                              ),
                              
                              // Upload files option
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: Icon(Icons.upload_file),
                                  label: Text(
                                    "Upload resource",
                                    style: TextStyle(
                                      fontSize: 16 * settings.fontSize,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: fontFamily(),
                                    ),
                                  ),
                                  onPressed: () => _uploadFile(subjectIndex),
                                ),
                              ),
                              
                              // Files list
                              if (subject.files.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.grey),
                                        SizedBox(width: 8),
                                        Text(
                                          "No files uploaded for this subject.",
                                          style: TextStyle(
                                            fontSize: 14 * settings.fontSize,
                                            fontFamily: fontFamily(),
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          "Uploaded Files",
                                          style: TextStyle(
                                            fontSize: 16 * settings.fontSize,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: fontFamily(),
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ),
                                      ...List.generate(subject.files.length, (fileIndex) {
                                        UploadedFile fileData = subject.files[fileIndex];
                                        String fileName = fileData.name;
                                        String fileExtension = fileName.split('.').last.toLowerCase();

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
                                          case 'doc':
                                          case 'docx':
                                            fileIcon = Icons.description;
                                            iconColor = Colors.blue;
                                            break;
                                          case 'ppt':
                                          case 'pptx':
                                            fileIcon = Icons.slideshow;
                                            iconColor = Colors.orange;
                                            break;
                                          default:
                                            fileIcon = Icons.insert_drive_file;
                                            iconColor = Colors.grey;
                                        }

                                        return Card(
                                          margin: EdgeInsets.symmetric(vertical: 4),
                                          elevation: 0,
                                          color: Colors.grey.shade50,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(color: Colors.grey.shade200),
                                          ),
                                          child: ListTile(
                                            leading: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: iconColor.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(fileIcon, color: iconColor),
                                            ),
                                            title: Text(
                                              fileName,
                                              style: TextStyle(
                                                fontSize: 14 * settings.fontSize,
                                                fontFamily: fontFamily(),
                                              ),
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red.shade300,
                                                size: 20 * settings.fontSize,
                                              ),
                                              onPressed: () => _confirmDelete(subjectIndex, fileIndex),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                            ],
                          ),
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
