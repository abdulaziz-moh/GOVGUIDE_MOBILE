import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:govguide/models/process_model.dart';
import 'package:govguide/screens/home/home_screen.dart';

class MyProcessesScreen extends StatefulWidget {
  const MyProcessesScreen({super.key});

  @override
  State<MyProcessesScreen> createState() => _MyProcessesScreenState();
}

class _MyProcessesScreenState extends State<MyProcessesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final List<DocumentSnapshot> _products = [];

  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchMyProcesses();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        if (!_isLoading && _hasMore) {
          _fetchMyProcesses();
        }
      }
    });
  }

  Future<void> _fetchMyProcesses() async {
    if (_isLoading || !_hasMore) return;
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    // FILTER BY USER ID HERE
    Query query = _firestore
        .collection('processes')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true);

    if (_products.isNotEmpty) {
      query = query.startAfterDocument(_products.last);
    }

    query = query.limit(_limit);

    try {
      final snapshot = await query.get();
      if (!mounted) return;

      if (snapshot.docs.length < _limit) {
        _hasMore = false;
      }

      setState(() {
        _products.addAll(snapshot.docs);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Firebase Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Published Processes",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _products.isEmpty && !_isLoading
          ? _buildEmptyState()
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == _products.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final process = ProcessModel.fromFirestore(_products[index]);
                        return ServiceCard(process: process);
                      },
                      childCount: _products.length + (_hasMore ? 1 : 0),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.folderOpen, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("You haven't posted any processes yet.",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}