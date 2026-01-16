import 'dart:io';
import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // For Cloudinary API
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostProcessScreen extends StatefulWidget {
  const PostProcessScreen({super.key});

  @override
  State<PostProcessScreen> createState() => _PostProcessScreenState();
}

class _PostProcessScreenState extends State<PostProcessScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  bool _isUploading = false;

  // ---------------------------------------------------------
  // CLOUDINARY CONFIGURATION (Already Filled)
  // ---------------------------------------------------------
  final String cloudName = "dwox9olhr"; 
  final String uploadPreset = "govguide"; 
  // ---------------------------------------------------------

  // Controllers
  final _titleController = TextEditingController();
  final _agencyController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  String? _selectedCategory;
  final List<TextEditingController> _stepControllers = [TextEditingController()];
  final List<String> _categories = ["Legal", "Education", "Health", "Business", "Transport"];

  @override
  void dispose() {
    _titleController.dispose();
    _agencyController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> _generateKeywords(String title, String description) {
    String combined = "${title.toLowerCase()} ${description.toLowerCase()}";
    return combined
        .split(RegExp(r'[\s\-_,.]+'))
        .where((word) => word.length > 1)
        .toSet()
        .toList();
  }

  void _addStep() {
    setState(() => _stepControllers.add(TextEditingController()));
  }

  void _removeStep(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  /// ---------------------------------------------------------
  /// Uploads image to Cloudinary and returns the URL
  /// ---------------------------------------------------------
  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    final jsonMap = jsonDecode(responseString);

    if (response.statusCode == 200) {
      return jsonMap['secure_url']; // Success: Return the link
    } else {
      // Failure: Throw detailed error
      String errorMsg = jsonMap['error']?['message'] ?? "Unknown Error";
      throw Exception("Cloudinary Upload Failed ($errorMsg). Code: ${response.statusCode}");
    }
  }

  Future<void> _publishProcess() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: You must be logged in to post"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String imageUrl = "";
      
      // 1. Upload Image to Cloudinary (if selected)
      if (_selectedImage != null) {
        final String? uploadedLink = await _uploadImageToCloudinary(_selectedImage!);
        if (uploadedLink != null) {
          imageUrl = uploadedLink;
        }
      }

      List<String> steps = _stepControllers
          .map((c) => c.text.trim())
          .toList();

      List<String> keywords = _generateKeywords(
        _titleController.text.trim(),
        _descController.text.trim(),
      );

      // 2. Save Data to Firestore
      await FirebaseFirestore.instance.collection('processes').add({
        'userId': user.uid, 
        'title': _titleController.text.trim(),
        'tag': _selectedCategory,
        'agency': _agencyController.text.trim(),
        'description': _descController.text.trim(),
        'searchKeywords': keywords,
        'steps': steps,
        'location': _locationController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'imageUrl': imageUrl, // Stores the Cloudinary URL
        'rating': 0.0,
        'reviews': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Process Published Successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Post New Process",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Share your knowledge! Help others by posting government processes you've completed.",
                        style: TextStyle(color: Color(0xFF1967D2), fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Image Picker Section
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_selectedImage!, height: 180, width: double.infinity, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 16,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                  onPressed: () => setState(() => _selectedImage = null),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                    _buildLabel("Process Title *"),
                    _buildTextField(_titleController, "e.g., Passport Application"),

                    _buildLabel("Category *"),
                    _buildDropdown(),

                    _buildLabel("Responsible Agency *"),
                    _buildTextField(_agencyController, "e.g., Immigration Bureau"),

                    _buildLabel("Process Description *"),
                    _buildTextField(_descController, "Brief overview of what this process is about...", maxLines: 3),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel("Step-by-Step Instructions *"),
                        TextButton.icon(
                          onPressed: _addStep,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Add Step"),
                        ),
                      ],
                    ),
                    ..._stepControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blueAccent,
                                child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(entry.value, "Step ${index + 1} description...")),
                            if (_stepControllers.length > 1)
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                                onPressed: () => _removeStep(index),
                              ),
                          ],
                        ),
                      );
                    }),

                    const Divider(height: 40),
                    const Text("Contact Information (Optional)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    _buildLabel("Office Location"),
                    _buildTextField(_locationController, "e.g., Addis Ababa, Bole", isOptional: true),

                    _buildLabel("Phone Number"),
                    _buildTextField(_phoneController, "+251-XX-XXX-XXXX", isOptional: true),

                    _buildLabel("Email Address"),
                    _buildTextField(_emailController, "contact@agency.gov.et", isOptional: true, isEmail: true),

                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _publishProcess,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text("Publish Process", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text("By posting, you confirm this information is accurate", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: Colors.white,
        mini: true,
        child: const Icon(Icons.add_a_photo, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, bool isOptional = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) {
        if (isOptional && (value == null || value.isEmpty)) return null;
        if (value == null || value.trim().isEmpty) return "This field is required";
        if (isEmail && !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
          return "Please enter a valid email";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF1F3F4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildDropdown() {
    return FormField<String>(
      validator: (value) => _selectedCategory == null ? "Please select a category" : null,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(8),
                border: state.hasError ? Border.all(color: Colors.redAccent, width: 1) : null,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Text("Select a category", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  isExpanded: true,
                  items: _categories.map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => _selectedCategory = newValue);
                    state.didChange(newValue);
                  },
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(state.errorText!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }
}