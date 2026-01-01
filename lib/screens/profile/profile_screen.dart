import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:govguide/auth/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Helper function to get real document counts from Firestore
  Future<int> _getCollectionCount(String collection, String? uid) async {
    if (uid == null) return 0;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('userId', isEqualTo: uid)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint("Error fetching $collection count: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    String memberSince = "2024";
    if (user?.metadata.creationTime != null) {
      memberSince = DateFormat('MMM yyyy').format(user!.metadata.creationTime!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFE3F2FD),
                    backgroundImage: user?.photoURL != null 
                        ? NetworkImage(user!.photoURL!) 
                        : null,
                    child: user?.photoURL == null 
                        ? const Icon(Icons.person, size: 55, color: Color(0xFF1A73E8)) 
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? "Guest User",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Member since $memberSince",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 25),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: _cardDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCountItem(context, 'processes', Icons.description_outlined, "Processes", Colors.blue, user?.uid),
                          _buildCountItem(context, 'tickets', Icons.chat_bubble_outline, "Tickets", Colors.indigo, user?.uid),
                          _buildCountItem(context, 'reviews', Icons.star_outline, "Reviews", Colors.amber, user?.uid),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- PERSONAL INFORMATION ---
            _buildSectionTitle("Personal Information"),
            _buildCardWrapper([
              _buildInfoTile(Icons.person_outline, "Full Name", user?.displayName ?? "N/A"),
              _buildInfoTile(Icons.email_outlined, "Email", user?.email ?? "N/A"),
              _buildInfoTile(Icons.phone_android_outlined, "Phone", user?.phoneNumber ?? "Not Linked"),
              _buildInfoTile(Icons.location_on_outlined, "Location", "Addis Ababa, Ethiopia", isLast: true),
            ]),

            const SizedBox(height: 24),

            // --- NAVIGATION MENU ---
            _buildCardWrapper([
              _buildMenuTile(Icons.chat_outlined, "My Tickets", () => context.push('/tickets')),
              _buildMenuTile(Icons.assignment_outlined, "My Processes", () => context.push('/processes')),
              _buildMenuTile(Icons.help_outline, "Help Center", () => context.push('/help-center')),
              _buildMenuTile(Icons.settings_outlined, "Settings", () => context.push('/settings'), isLast: true),
            ]),
            
            // --- LOGOUT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: OutlinedButton(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: Color(0xFFFFCDD2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Text("GovGuide v1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCountItem(BuildContext context, String collection, IconData icon, String label, Color color, String? uid) {
    return FutureBuilder<int>(
      future: _getCollectionCount(collection, uid),
      builder: (context, snapshot) {
        String count = snapshot.hasData ? snapshot.data.toString() : "0";
        return Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        );
      },
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEEEEE)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  Widget _buildCardWrapper(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF1F3F4),
            child: Icon(icon, size: 18, color: const Color(0xFF1A73E8)),
          ),
          const SizedBox(width: 16),
          // FIXED OVERFLOW: Using Expanded to handle long text like emails
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  value, 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.black87),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
    );
  }
}