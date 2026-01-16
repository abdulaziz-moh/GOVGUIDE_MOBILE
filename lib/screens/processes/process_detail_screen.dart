import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProcessDetailScreen extends StatefulWidget {
  final String processId;

  const ProcessDetailScreen({super.key, required this.processId});

  @override
  State<ProcessDetailScreen> createState() => _ProcessDetailScreenState();
}

class _ProcessDetailScreenState extends State<ProcessDetailScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  Map<String, dynamic>? _processData;

  // Inputs
  int _userRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  // User State
  User? _currentUser;
  bool _hasReviewed = false;

  // Theme Colors (Google Blue)
  final Color _googleBlue = const Color(0xFF1A73E8);
  final Color _starColor = const Color(0xFFE8EAED); // Inactive star color
  final Color _activeStarColor = const Color(0xFFFBC02D); // Gold

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadProcessDetails();
    _checkExistingReview();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadProcessDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('processes')
          .doc(widget.processId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _processData = doc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkExistingReview() async {
    if (_currentUser == null) return;
    try {
      DocumentSnapshot reviewDoc = await FirebaseFirestore.instance
          .collection('processes')
          .doc(widget.processId)
          .collection('reviews')
          .doc(_currentUser!.uid)
          .get();

      if (reviewDoc.exists && mounted) {
        final data = reviewDoc.data() as Map<String, dynamic>;
        setState(() {
          _hasReviewed = true;
          _userRating = (data['rating'] as num).toInt();
          _reviewController.text = data['reviewText'] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Error checking review: $e");
    }
  }

  Future<void> _submitReview() async {
    if (_currentUser == null) return;
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a star rating.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final processRef = FirebaseFirestore.instance.collection('processes').doc(widget.processId);
    final reviewRef = processRef.collection('reviews').doc(_currentUser!.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot processSnapshot = await transaction.get(processRef);
        DocumentSnapshot reviewSnapshot = await transaction.get(reviewRef);

        if (!processSnapshot.exists) throw Exception("Process not found");

        final pData = processSnapshot.data() as Map<String, dynamic>;
        
        // 1. Get Current Stats
        double currentAvg = (pData['rating'] as num? ?? 0).toDouble();
        int totalReviews = (pData['reviews'] as num? ?? 0).toInt();
        Map<String, dynamic> ratingDist = Map<String, dynamic>.from(pData['ratingDist'] ?? {});

        double newAvg;
        int newTotalReviews;

        if (reviewSnapshot.exists) {
          // --- UPDATE EXISTING REVIEW ---
          final rData = reviewSnapshot.data() as Map<String, dynamic>;
          int oldRating = (rData['rating'] as num).toInt();

          int div = totalReviews > 0 ? totalReviews : 1;
          // Calculate raw average
          double rawNewAvg = ((currentAvg * totalReviews) - oldRating + _userRating) / div;
          newAvg = rawNewAvg;
          newTotalReviews = totalReviews;

          // Update Distribution Bars
          int oldDistCount = (ratingDist[oldRating.toString()] as num? ?? 0).toInt();
          int newDistCount = (ratingDist[_userRating.toString()] as num? ?? 0).toInt();
          
          if(oldDistCount > 0) ratingDist[oldRating.toString()] = oldDistCount - 1;
          ratingDist[_userRating.toString()] = newDistCount + 1;

        } else {
          // --- CREATE NEW REVIEW ---
          double rawNewAvg = ((currentAvg * totalReviews) + _userRating) / (totalReviews + 1);
          newAvg = rawNewAvg;
          newTotalReviews = totalReviews + 1;

          // Update Distribution Bars
          int currentDistCount = (ratingDist[_userRating.toString()] as num? ?? 0).toInt();
          ratingDist[_userRating.toString()] = currentDistCount + 1;
        }

        // --- FIX: ROUNDING LOGIC ---
        // Convert to fixed string "X.Y" then back to double to ensure DB stores 4.5 instead of 4.5333333
        newAvg = double.parse(newAvg.toStringAsFixed(1));

        // 2. Write to Firestore
        transaction.update(processRef, {
          'rating': newAvg,
          'reviews': newTotalReviews,
          'ratingDist': ratingDist,
        });

        transaction.set(reviewRef, {
          'rating': _userRating,
          'reviewText': _reviewController.text.trim(),
          'userName': _currentUser!.displayName ?? "User",
          'timestamp': FieldValue.serverTimestamp(),
          'userId': _currentUser!.uid,
        }, SetOptions(merge: true));
      });

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _hasReviewed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Review submitted"), backgroundColor: _googleBlue)
        );
        _loadProcessDetails();
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_processData == null) return const Scaffold(body: Center(child: Text("Process not found")));

    final data = _processData!;
    final List<dynamic> steps = data['steps'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          data['title'] ?? "Details",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Process Info Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                        child: Text(data['tag'] ?? "General", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ),
                      const SizedBox(width: 10),
                      Text(data['agency'] ?? "Agency", style: TextStyle(color: _googleBlue, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['description'] ?? "",
                    style: TextStyle(color: Colors.grey[800], height: 1.5, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text("Procedure", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: steps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text("${index + 1}.", style: TextStyle(fontWeight: FontWeight.bold, color: _googleBlue)),
                             const SizedBox(width: 12),
                             Expanded(child: Text(steps[index], style: const TextStyle(height: 1.4))),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1, color: Colors.grey[200]),

            // ============================================
            // GOOGLE PLAY STYLE RATING & REVIEW SECTION
            // ============================================
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ratings and reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  _buildRatingSummary(data),
                  
                  const SizedBox(height: 30),

                  const Text("Rate this process", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text("Tell others what you think", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 16),
                  
                  // Interactive Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => _userRating = index + 1),
                        child: FaIcon(
                          index < _userRating ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                          color: index < _userRating ? _activeStarColor : _starColor,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      hintText: "Describe your experience (optional)",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _googleBlue, width: 2)),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isSubmitting ? null : _submitReview,
                      style: TextButton.styleFrom(
                        foregroundColor: _googleBlue,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: _isSubmitting 
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _googleBlue))
                        : Text(_hasReviewed ? "Edit" : "Post"),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildReviewsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary(Map<String, dynamic> data) {
    double rating = (data['rating'] as num? ?? 0.0).toDouble();
    int totalReviews = (data['reviews'] as num? ?? 0).toInt();
    Map<String, dynamic> dist = data['ratingDist'] ?? {};

    return Row(
      children: [
        // Big Score
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // ENSURE DISPLAY IS FORMATTED
              rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, height: 1, letterSpacing: -1),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (i) => Icon(
                Icons.star, 
                size: 14, 
                color: i < rating.round() ? _activeStarColor : _starColor
              )),
            ),
            const SizedBox(height: 4),
            Text(
              "$totalReviews reviews",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(width: 20),
        
        // Distribution Bars
        Expanded(
          child: Column(
            children: [5, 4, 3, 2, 1].map((star) {
              int count = (dist[star.toString()] as num? ?? 0).toInt();
              double percent = totalReviews == 0 ? 0 : count / totalReviews;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text("$star", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: const Color(0xFFE8EAED), 
                          color: _googleBlue, 
                          minHeight: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('processes')
          .doc(widget.processId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final rData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final ts = rData['timestamp'] as Timestamp?;
            final date = ts != null 
                ? "${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}" 
                : "Recently";

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.primaries[index % Colors.primaries.length].shade100,
                  foregroundColor: Colors.primaries[index % Colors.primaries.length].shade800,
                  child: Text((rData['userName'] ?? "U")[0].toUpperCase(), style: const TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rData['userName'] ?? "User", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (i) => Icon(
                              Icons.star, 
                              size: 12, 
                              color: i < (rData['rating'] ?? 0) ? _activeStarColor : _starColor
                            )),
                          ),
                          const SizedBox(width: 8),
                          Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if ((rData['reviewText'] ?? "").isNotEmpty)
                        Text(rData['reviewText'], style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, size: 16, color: Colors.grey),
              ],
            );
          },
        );
      },
    );
  }
}