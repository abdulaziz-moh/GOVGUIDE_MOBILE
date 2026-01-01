import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEARCH BAR ---
            TextField(
              decoration: InputDecoration(
                hintText: "Search FAQs...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
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

            // --- NEED MORE HELP BOX ---
            Container(
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
                      Text(
                        "Need More Help?",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
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
                    child: const Text(
                      "Create Support Ticket →",
                      style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- FAQ SECTIONS ---
            _buildSectionTitle("Getting Started"),
            _buildFAQTile(
              "How do I create an account?",
              "Click on the 'Sign Up' button on the login page, fill in your details including name, email, and password, then verify your email address to activate your account.",
            ),
            _buildFAQTile(
              "What is GovGuide?",
              "GovGuide is a platform that helps citizens navigate government processes more easily. You can find step-by-step guides for various government services, get help through support tickets, and share your own experiences.",
            ),

            _buildSectionTitle("Posting Processes"),
            _buildFAQTile(
              "How do I post a new process?",
              "Click the '+' button on the home screen, fill in the process details including title, description, steps, and the responsible agency. Your post will be reviewed and published for other users to see.",
            ),
            _buildFAQTile(
              "Can I edit my posted process?",
              "Yes, you can edit your posted processes from your profile page. Navigate to 'My Processes' and select the process you want to update.",
            ),
            _buildFAQTile(
              "Who can post processes?",
              "All registered users can post processes. However, we encourage you to only post accurate information based on your actual experience with government services.",
            ),

            _buildSectionTitle("Support Tickets"),
            _buildFAQTile(
              "When should I create a support ticket?",
              "Create a support ticket when you need help understanding a government process, have questions about documentation, or encounter issues that aren't covered in existing guides.",
            ),
            _buildFAQTile(
              "How long does it take to get a response?",
              "Most tickets are responded to within 24-48 hours. High priority tickets are typically addressed sooner. You can track your ticket status in the 'My Tickets' section.",
            ),
            _buildFAQTile(
              "Can I update my ticket after submission?",
              "Yes, you can add comments and additional information to your ticket through the ticket details page. This helps our support team better understand your issue.",
            ),

            _buildSectionTitle("Rating & Reviews"),
            _buildFAQTile(
              "How do I rate a process?",
              "Open any process details page and scroll to the 'Add Your Review' section. Select a star rating and write your feedback about your experience with that process.",
            ),
            _buildFAQTile(
              "Can I change my rating?",
              "Yes, you can edit or update your rating and review at any time from the process details page.",
            ),

            const SizedBox(height: 30),

            // --- FOOTER CONTACT SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Still have questions?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Our support team is here to help you",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/create-ticket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      "Contact Support",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper widget for Section Headers
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper widget for FAQ Expandable tiles
  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E6EB)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        iconColor: Colors.grey,
        collapsedIconColor: Colors.grey,
        shape: const Border(), // Removes the default border line when expanded
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}