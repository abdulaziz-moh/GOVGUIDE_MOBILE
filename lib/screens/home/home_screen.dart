import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back, Citizen.",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          
          // Example "Pending Action" Card
          Card(
            elevation: 2,
            color: Colors.orange[50],
            child: const ListTile(
              leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
              title: Text("Action Required"),
              subtitle: Text("Vehicle registration renewal due soon."),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          const SizedBox(height: 20),

          Text("Quick Services", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          
          // Example Grid for quick links
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildQuickLinkIcon(Icons.file_copy, "Documents"),
              _buildQuickLinkIcon(Icons.payment, "Taxes"),
              _buildQuickLinkIcon(Icons.directions_car, "Vehicles"),
              _buildQuickLinkIcon(Icons.business, "Permits"),
              _buildQuickLinkIcon(Icons.health_and_safety, "Health"),
              _buildQuickLinkIcon(Icons.more_horiz, "More"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkIcon(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: const Color(0xFF005696)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}