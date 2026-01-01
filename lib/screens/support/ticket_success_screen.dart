import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TicketSuccessScreen extends StatelessWidget {
  const TicketSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Icon with Green Circle Background
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Light green background
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF4CAF50), // Success green
                size: 60,
              ),
            ),
            const SizedBox(height: 32),

            // Title
            const Text(
              "Ticket Submitted!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Description Message
            const Text(
              "Your support ticket has been created successfully. Our team will review it shortly.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the tickets list page using GoRouter
                  context.pushReplacement('/tickets');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D0D1B), // Dark navy/black
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "View My Tickets",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}