import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Data structure for the FAQs
  final List<Map<String, dynamic>> _faqData = [
    {
      "category": "Getting Started",
      "items": [
        {
          "q": "How do I create an account?",
          "a": "Click on the 'Sign Up' button on the login page, fill in your details including name, email, and password, then verify your email address to activate your account."
        },
        {
          "q": "What is GovGuide?",
          "a": "GovGuide is a platform that helps citizens navigate government processes more easily. You can find step-by-step guides for various government services, get help through support tickets, and share your own experiences."
        },
      ]
    },
    {
      "category": "Posting Processes",
      "items": [
        {
          "q": "How do I post a new process?",
          "a": "Click the '+' button on the home screen, fill in the process details including title, description, steps, and the responsible agency. Your post will be reviewed and published for other users to see."
        },
        {
          "q": "Can I edit my posted process?",
          "a": "Yes, you can edit your posted processes from your profile page. Navigate to 'My Processes' and select the process you want to update."
        },
        {
          "q": "Who can post processes?",
          "a": "All registered users can post processes. However, we encourage you to only post accurate information based on your actual experience with government services."
        },
      ]
    },
    {
      "category": "Support Tickets",
      "items": [
        {
          "q": "When should I create a support ticket?",
          "a": "Create a support ticket when you need help understanding a government process, have questions about documentation, or encounter issues that aren't covered in existing guides."
        },
        {
          "q": "How long does it take to get a response?",
          "a": "Most tickets are responded to within 24-48 hours. High priority tickets are typically addressed sooner. You can track your ticket status in the 'My Tickets' section."
        },
        {
          "q": "Can I update my ticket after submission?",
          "a": "Yes, you can add comments and additional information to your ticket through the ticket details page. This helps our support team better understand your issue."
        },
      ]
    },
    {
      "category": "Rating & Reviews",
      "items": [
        {
          "q": "How do I rate a process?",
          "a": "Open any process details page and scroll to the 'Add Your Review' section. Select a star rating and write your feedback about your experience with that process."
        },
        {
          "q": "Can I change my rating?",
          "a": "Yes, you can edit or update your rating and review at any time from the process details page."
        },
      ]
    }
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Help Center",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: [
          // --- SEARCH BAR ---
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
            },
            decoration: InputDecoration(
              hintText: "Search FAQs...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear), 
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    }
                  ) 
                : null,
              filled: true,
              fillColor: const Color(0xFFF5F6F7),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Only show the header box if search is empty
          if (_searchQuery.isEmpty) _buildHeaderBox(context),

          // --- DYNAMIC FAQ LIST ---
          ..._faqData.map((section) {
            // Filter items within each section
            final filteredItems = section['items'].where((item) {
              final q = item['q'].toString().toLowerCase();
              final a = item['a'].toString().toLowerCase();
              return q.contains(_searchQuery) || a.contains(_searchQuery);
            }).toList();

            // Only show the section if it has matching items
            if (filteredItems.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(section['category']),
                ...filteredItems.map((item) => _buildFAQTile(item['q'], item['a'])),
              ],
            );
          }),

          const SizedBox(height: 30),
          _buildFooter(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildHeaderBox(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1877F2).withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline, color: Color(0xFF1877F2), size: 20),
              SizedBox(width: 8),
              Text("Need More Help?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Can't find what you're looking for? Create a support ticket and our team will assist you.",
            style: TextStyle(color: Colors.black87, fontSize: 13),
          ),
          TextButton(
            onPressed: () => context.push('/create-ticket'),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text("Create Support Ticket →", style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E6EB)),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(color: Colors.black54, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Text("Still have questions?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          const Text("Our support team is here to help you", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/create-ticket'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1877F2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Contact Support", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}