import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                const Text("John Doe Citizen", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Text("citizen.id@gov.email", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // Settings Options
          ListTile(
            leading: const Icon(Icons.folder_shared),
            title: const Text("My Documents"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Account Settings"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
           const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Help & Support"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
             onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}