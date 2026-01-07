import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // This import will now work

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "Open", "In Progress", "Resolved"];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
          "My Tickets",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) {
                  bool isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() => _selectedFilter = filter);
                      },
                      selectedColor: const Color(0xFF1A73E8),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      backgroundColor: const Color(0xFFF1F3F4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Tickets List using StreamBuilder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(user?.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading tickets"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No tickets found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length + 1,
                  itemBuilder: (context, index) {
                    if (index < docs.length) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return _TicketCard(
                        id: docs[index].id,
                        title: data['title'] ?? 'Untitled Ticket',
                        category: data['category'] ?? 'General',
                        status: data['status'] ?? 'Open',
                        priority: data['priority'] ?? 'Medium',
                        timestamp: data['createdAt'] as Timestamp?,
                      );
                    } else {
                      return SizedBox(height: 100);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      // FAB to navigate to Create Ticket
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-ticket'),
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF1A73E8),
        child: const FaIcon(
          FontAwesomeIcons.plus,
          size: 20,
          color: Colors.white,
        ),
        // Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredStream(String? uid) {
    Query query = FirebaseFirestore.instance
        .collection('tickets')
        .where('userId', isEqualTo: uid ?? 'anonymous')
        .orderBy('createdAt', descending: true);

    if (_selectedFilter != "All") {
      query = query.where('status', isEqualTo: _selectedFilter);
    }
    return query.snapshots();
  }
}

class _TicketCard extends StatelessWidget {
  final String id, title, category, status, priority;
  final Timestamp? timestamp;

  const _TicketCard({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.priority,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic styling based on status
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (status) {
      case "Resolved":
        statusColor = const Color(0xFF2E7D32);
        statusBg = const Color(0xFFE8F5E9);
        statusIcon = Icons.check_circle_outline;
        break;
      case "In Progress":
        statusColor = const Color(0xFFEF6C00);
        statusBg = const Color(0xFFFFF3E0);
        statusIcon = Icons.history_rounded;
        break;
      default: // Open
        statusColor = const Color(0xFF1565C0);
        statusBg = const Color(0xFFE3F2FD);
        statusIcon = Icons.info_outline_rounded;
    }

    // Small Priority Dot logic
    Color priorityColor = priority == "High"
        ? Colors.red
        : (priority == "Medium" ? Colors.amber : Colors.green);

    // Using DateFormat from the intl package
    String formattedDate = timestamp != null
        ? DateFormat('MMM d, h:mm a').format(timestamp!.toDate())
        : "Pending...";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "TKT-${id.substring(0, 4).toUpperCase()}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Updated $formattedDate",
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
