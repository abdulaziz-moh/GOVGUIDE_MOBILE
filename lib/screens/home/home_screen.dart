import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:govguide/models/process_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  final List<DocumentSnapshot> _products = [];

  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 10;

  String _searchQuery = "";
  String _selectedCategory = "All";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchProcesses();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        if (!_isLoading && _hasMore) {
          _fetchProcesses();
        }
      }
    });
  }

  Future<void> _fetchProcesses() async {
    if (_isLoading || !_hasMore) return;
    
    // Safety Check: check mounted before setState
    if (!mounted) return; 
    setState(() => _isLoading = true);

    Query query = _firestore.collection('processes').orderBy('title');

    if (_selectedCategory != "All") {
      query = query.where('tag', isEqualTo: _selectedCategory);
    }

    if (_searchQuery.isNotEmpty) {
      query = query
          .where('title', isGreaterThanOrEqualTo: _searchQuery)
          .where('title', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
    }

    if (_products.isNotEmpty) {
      query = query.startAfterDocument(_products.last);
    }

    query = query.limit(_limit);

    try {
      final snapshot = await query.get();
      
      // Safety Check: check mounted after async operation
      if (!mounted) return; 

      if (snapshot.docs.length < _limit) _hasMore = false;

      setState(() {
        _products.addAll(snapshot.docs);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Firebase Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Check mounted inside the timer callback
      if (!mounted) return;

      setState(() {
        _searchQuery = value;
        _products.clear();
        _hasMore = true;
      });
      _fetchProcesses();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel(); // Cancel timer to prevent it firing after dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(context),
          _buildSearchBar(),
          _buildCategories(),
          _buildProcessList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/post'),
        backgroundColor: Colors.blueAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        onTap: (index) {
          if (index == 1) context.push('/tickets');
          if (index == 2) context.push('/profile');
        },
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house, size: 20),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.message, size: 20),
            label: "Tickets",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user, size: 20),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // ---------------- SLIVERS ----------------

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Image.asset(
            'assets/images/splash.png',
            height: 50, // Standard AppBar height scale
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          const Text(
            "GovGuide",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.bell, size: 20),
          onPressed: () {},
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.bars, size: 20),
          onPressed: () => context.push('/profile'),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: "Search processes...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFFF1F3F4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategories() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            "All",
            "Education",
            "Health",
            "Business",
            "Legal",
          ].map((label) => _buildChip(label)).toList(),
        ),
      ),
    );
  }

  SliverPadding _buildProcessList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildChip(String label) {
    return _CategoryChip(
      label: label,
      isSelected: _selectedCategory == label,
      onSelected: (selectedLabel) {
        if (!mounted) return;
        setState(() {
          _selectedCategory = selectedLabel;
          _products.clear();
          _hasMore = true;
        });
        _fetchProcesses();
      },
    );
  }
}

// ================= CATEGORY CHIP =================

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(String) onSelected;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.blueAccent,
        backgroundColor: const Color(0xFFEAF0FF),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        side: BorderSide.none,
        surfaceTintColor: Colors.transparent, // IMPORTANT

        onSelected: (bool selected) {
          if (selected) onSelected(label);
        },
      ),
    );
  }
}

// ================= SERVICE CARD =================

class ServiceCard extends StatefulWidget {
  final ProcessModel process;
  const ServiceCard({super.key, required this.process});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      surfaceTintColor: Colors.transparent,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/details/${widget.process.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.process.imageUrl.isNotEmpty)
                Container(
                  height: 160,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(widget.process.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.process.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      if (mounted) {
                        setState(() => isLiked = !isLiked);
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.orange),
                  Text(" ${widget.process.rating} (${widget.process.reviews})"),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.process.tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.process.description,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.buildingColumns,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.process.agency,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}