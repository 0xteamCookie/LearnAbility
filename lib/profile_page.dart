import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Account Information"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Update your personal information",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // Profile Photo
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Change Photo"),
                ),
                const SizedBox(height: 24),

                // First Name
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("First Name"),
                ),
                const SizedBox(height: 4),
                TextField(
                  decoration: _inputDecoration("Sam"),
                ),
                const SizedBox(height: 16),

                // Last Name
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Last Name"),
                ),
                const SizedBox(height: 4),
                TextField(
                  decoration: _inputDecoration("Johnson"),
                ),
                const SizedBox(height: 16),

                // Email
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email"),
                ),
                const SizedBox(height: 4),
                TextField(
                  decoration: _inputDecoration("student@example.com"),
                ),
                const SizedBox(height: 16),

                // Change Password
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Change Password"),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Change Password"),
                ),
                const SizedBox(height: 16),

                // Primary Learning Accommodation
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Primary Learning Accommodation"),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: "Dyslexia",
                  decoration: _inputDecoration(""),
                  items: const [
                    DropdownMenuItem(
                      value: "Dyslexia",
                      child: Text("Dyslexia"),
                    ),
                    DropdownMenuItem(
                      value: "ADHD",
                      child: Text("ADHD"),
                    ),
                    DropdownMenuItem(
                      value: "Visual Impairment",
                      child: Text("Visual Impairment"),
                    ),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),

                // About Me
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("About Me (Optional)"),
                ),
                const SizedBox(height: 4),
                TextField(
                  maxLines: 4,
                  decoration: _inputDecoration("Tell us a bit about yourself..."),
                ),
                const SizedBox(height: 16),

                // Phone
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Phone (Optional)"),
                ),
                const SizedBox(height: 4),
                TextField(
                  decoration: _inputDecoration("(123) 456-7890"),
                ),
                const SizedBox(height: 24),

                // Save Changes
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}
