import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class ProcessDetailScreen extends StatefulWidget {
  final String processId;

  const ProcessDetailScreen({super.key, required this.processId});

  @override
  State<ProcessDetailScreen> createState() => _ProcessDetailScreenState();
}

class _ProcessDetailScreenState extends State<ProcessDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _processData;

  @override
  void initState() {
    super.initState();
    _loadProcessDetails();
  }

  Future<void> _loadProcessDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('processes')
          .doc(widget.processId)
          .get();

      if (doc.exists) {
        setState(() {
          _processData = doc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching details: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_processData == null) {
      return const Scaffold(body: Center(child: Text("Process not found")));
    }

    final data = _processData!;
    // Extract steps as a List, defaulting to empty if missing
    final List<dynamic> steps = data['steps'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Process Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tag & Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                data['tag'] ?? "General",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data['title'] ?? "",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  "${data['rating'] ?? 0.0}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  " (${data['reviews'] ?? 0} reviews)",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              data['description'] ?? "",
              style: const TextStyle(color: Colors.black87, height: 1.5),
            ),

            const SizedBox(height: 24),

            // 2. Agency Contact Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          data['agency']?[0] ?? "G",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['agency'] ?? "Government Agency",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            "Responsible Agency",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildContactRow(
                    Icons.phone_outlined,
                    data['phone'] ?? "No phone provided",
                  ),
                  _buildContactRow(
                    Icons.email_outlined,
                    data['email'] ?? "No email provided",
                  ),
                  _buildContactRow(
                    Icons.location_on_outlined,
                    data['location'] ?? "No location provided",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. Step-by-Step Section
            const Row(
              children: [
                Icon(Icons.access_time, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  "Step-by-Step Process",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          steps[index],
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(height: 40),

            // 4. Need Help Section
            const Text(
              "Need Help?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Having trouble understanding this process? Create a support ticket and get help from our team.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/create-ticket');
                },
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  "Create Support Ticket",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 5. Review Section
            const Text(
              "Add Your Review",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Text("Your Rating: "),
                Icon(Icons.star_border, color: Colors.grey),
                Icon(Icons.star_border, color: Colors.grey),
                Icon(Icons.star_border, color: Colors.grey),
                Icon(Icons.star_border, color: Colors.grey),
                Icon(Icons.star_border, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: "Share your experience with this process...",
                filled: true,
                fillColor: const Color(0xFFF1F3F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Submit Review",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
