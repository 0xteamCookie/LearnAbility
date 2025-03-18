import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
        return AlertDialog(
          title: Text("Upload Files"),
          content: SizedBox(
            height: 400, 
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Upload files to your learning materials library."),
                  SizedBox(height: 16),
                  Text("Subject (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(hintText: "Enter subject"),
                  ),
                  SizedBox(height: 16),
                  Text("Topic (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: topicController,
                    decoration: InputDecoration(hintText: "Enter topic"),
                  ),
                  SizedBox(height: 16),
                  Text("Description (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: "Enter a description for these files",
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("Tags (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: tagsController,
                    decoration: InputDecoration(hintText: "Add tags"),
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
              child: Text("Cancel"),
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
                    SnackBar(content: Text("No file selected")),
                  );
                }
              },
              child: Text("Upload"),
            ),
          ],
        );
      },
    );
  }

  // Confirmation before deleting
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                uploadedFiles.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "LearnAbility",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Materials",
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Upload your learning resources to generate personalized content",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.upload_file, color: Colors.blue),
                title: Text("Upload file"),
                onTap: _uploadFile,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Uploaded Files",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: uploadedFiles.isEmpty
                  ? Center(child: Text("No files uploaded yet."))
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
                            title: Text(fileName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (fileData.subject.isNotEmpty)
                                  Text("Subject: ${fileData.subject}"),
                                if (fileData.topic.isNotEmpty)
                                  Text("Topic: ${fileData.topic}"),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
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
