import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  // GlobalKey used to validate the form
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  String _priority = "Medium"; 
  bool _isSubmitting = false;

  final List<String> _categories = [
    "Education", 
    "Health", 
    "Business", 
    "Legal", 
    "General"
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    // Check if all required fields are filled
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      await FirebaseFirestore.instance.collection('tickets').add({
        'userId': user?.uid ?? 'anonymous',
        'userEmail': user?.email ?? 'anonymous',
        'category': _selectedCategory,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'priority': _priority,
        'status': 'Open',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
        context.pushReplacement('/ticket-success');
      // Navigate back using GoRouter
      // context.pop(); 
      
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Ticket submitted successfully!"),
      //     backgroundColor: Colors.green,
      //   ),
      // );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
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
          "Create Support Ticket",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructional Info Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Need help understanding a government process? Our support team is here to assist you!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1A73E8), 
                    fontWeight: FontWeight.normal,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category Field
              _buildLabel("Process Category"),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: _inputDecoration("Select a category"),
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat, 
                  child: Text(cat),
                )).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (value) => value == null ? "Please select a category" : null,
              ),

              const SizedBox(height: 20),

              // Title Field
              _buildLabel("Issue Title"),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration("Brief summary of your issue"),
                validator: (value) => (value == null || value.isEmpty) ? "Title is required" : null,
              ),

              const SizedBox(height: 20),

              // Description Field
              _buildLabel("Description"),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration("Please describe your issue in detail..."),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Description is required";
                  if (value.length < 10) return "Please provide more detail";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Priority Selector
              _buildLabel("Priority Level"),
              _buildPriorityTile("Low", Colors.green),
              _buildPriorityTile("Medium", Colors.orange),
              _buildPriorityTile("High", Colors.red),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Submit Ticket",
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 16, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF1F3F4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  Widget _buildPriorityTile(String value, Color color) {
    bool isSelected = _priority == value;
    return InkWell(
      onTap: () => setState(() => _priority = value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1A73E8) : Colors.grey.shade400, 
                  width: 2,
                ),
              ),
              child: isSelected 
                ? Center(
                    child: Container(
                      width: 10, 
                      height: 10, 
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1A73E8)),
                    ),
                  )
                : null,
            ),
            const SizedBox(width: 12),
            CircleAvatar(radius: 6, backgroundColor: color),
            const SizedBox(width: 10),
            Text(
              value, 
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}