import 'package:flutter/material.dart';

class CreateTab extends StatelessWidget {
  const CreateTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Text("What would you like to start today?"),
        ),
        // Example list of processes to start
        _buildProcessTile(context, "New Passport Application", Icons.book),
        _buildProcessTile(context, "Register a Business", Icons.store),
        _buildProcessTile(context, "File a Complaint", Icons.report_problem),
        _buildProcessTile(context, "Request Public Records", Icons.folder_open),
      ],
    );
  }

  Widget _buildProcessTile(BuildContext context, String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Estimated time: 15 mins"),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // Navigate to the actual form screen
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Starting: $title"))
          );
        },
      ),
    );
  }
}