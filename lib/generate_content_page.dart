import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'accessibility_model.dart';

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
  List<UploadedFile> uploadedFiles = [];

  // Controllers for input fields
  TextEditingController subjectController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController tagsController = TextEditingController();

  // Function to handle file upload by Pranjal
  Future<void> _uploadFile() async {
    subjectController.clear();
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
          title: Text(
            "Upload Files",
            style: TextStyle(
              fontSize: 20 * settings.fontSize,
              fontFamily: fontFamily(), // Added font family
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
                      fontFamily: fontFamily(), // Added font family
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Subject (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(), // Added font family
                    ),
                  ),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      hintText: "Enter subject",
                      hintStyle: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily(), // Added font family
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      fontFamily: fontFamily(), // Added font family
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Topic (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(), // Added font family
                    ),
                  ),
                  TextField(
                    controller: topicController,
                    decoration: InputDecoration(
                      hintText: "Enter topic",
                      hintStyle: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily(), // Added font family
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      fontFamily: fontFamily(), // Added font family
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Description (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(), // Added font family
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: "Enter a description for these files",
                      hintStyle: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily(), // Added font family
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      fontFamily: fontFamily(), // Added font family
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Tags (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(), // Added font family
                    ),
                  ),
                  TextField(
                    controller: tagsController,
                    decoration: InputDecoration(
                      hintText: "Add tags",
                      hintStyle: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily(), // Added font family
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      fontFamily: fontFamily(), // Added font family
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 16 * settings.fontSize,
                  fontFamily: fontFamily(), // Added font family
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
                  setState(() {
                    uploadedFiles.add(
                      UploadedFile(
                        name: file.name,
                        subject: subjectController.text,
                        topic: topicController.text,
                      ),
                    );
                  });
                  Navigator.of(context).pop(); // Close dialog
                } else {
                  Navigator.of(context).pop(); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "No file selected",
                        style: TextStyle(
                          fontSize: 14 * settings.fontSize,
                          fontFamily: fontFamily(), // Added font family
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
                  fontFamily: fontFamily(), // Added font family
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Confirmation before deleting
  void _confirmDelete(int index) {
    final settings = Provider.of<AccessibilitySettings>(context, listen: false);
    final bool isDyslexic = settings.openDyslexic;

    // Function to determine font family
    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Delete',
          style: TextStyle(
            fontSize: 20 * settings.fontSize,
            fontFamily: fontFamily(), // Added font family
          ),
        ),
        content: Text(
          'Are you sure you want to delete this file?',
          style: TextStyle(
            fontSize: 16 * settings.fontSize,
            fontFamily: fontFamily(), // Added font family
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily(), // Added font family
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                uploadedFiles.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily(), // Added font family
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
        backgroundColor: Colors.blue,
        title: Text(
          "LearnAbility",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24 * settings.fontSize,
            fontFamily: fontFamily(), // Added font family
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Materials",
              style: TextStyle(
                fontSize: 27 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily(), // Added font family
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Upload your learning resources to generate personalized content",
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                color: Colors.grey,
                fontFamily: fontFamily(), // Added font family
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.upload_file, color: Colors.blue),
                title: Text(
                  "Upload file",
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(), // Added font family
                  ),
                ),
                onTap: _uploadFile,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Uploaded Files",
              style: TextStyle(
                fontSize: 20 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily(), // Added font family
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: uploadedFiles.isEmpty
                  ? Center(
                      child: Text(
                        "No files uploaded yet.",
                        style: TextStyle(
                          fontSize: 16 * settings.fontSize,
                          fontFamily: fontFamily(), // Added font family
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: uploadedFiles.length,
                      itemBuilder: (context, index) {
                        UploadedFile fileData = uploadedFiles[index];
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
                          default:
                            fileIcon = Icons.insert_drive_file;
                            iconColor = Colors.grey;
                        }

                        return Card(
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(fileIcon, color: iconColor),
                            title: Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 16 * settings.fontSize,
                                fontFamily: fontFamily(), // Added font family
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (fileData.subject.isNotEmpty)
                                  Text(
                                    "Subject: ${fileData.subject}",
                                    style: TextStyle(
                                      fontSize: 14 * settings.fontSize,
                                      fontFamily: fontFamily(), // Added font family
                                    ),
                                  ),
                                if (fileData.topic.isNotEmpty)
                                  Text(
                                    "Topic: ${fileData.topic}",
                                    style: TextStyle(
                                      fontSize: 14 * settings.fontSize,
                                      fontFamily: fontFamily(), // Added font family
                                    ),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 24 * settings.fontSize,
                              ),
                              onPressed: () => _confirmDelete(index),
                            ),
                          ),
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