
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
  
//   @override
//   Widget build(BuildContext context) {
//     double tenPercentHeight = MediaQuery.sizeOf(context).height * 0.10;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("GovGuide", style: TextStyle(fontWeight: FontWeight.bold)),
//         actions: [
//           Padding(
//               padding: const EdgeInsets.all(8),
//               child: Row(children: [
//                 IconButton(
//                   onPressed: () {},
//                   icon: const FaIcon(FontAwesomeIcons.bell, color: Color(0xFF646E78), size: 20.0),
//                 ),
//                 IconButton(
//                   onPressed: () { context.push('/profile'); },
//                   icon: const FaIcon(FontAwesomeIcons.bars, color: Color(0xFF646E78), size: 20.0),
//                 ),
//               ],)
          
//           )
//         ],
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(tenPercentHeight),
//           child: _buildHeaderContent(), // Search bar and Chips logic here
//         ),
//       ),
//       // body: const HomeListView(), // The list of passport/business cards
      
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 0, // Always 0 because we are on Home
//         onTap: (index) {
//           if (index == 1) context.push('/tickets');
//           if (index == 2) context.push('/profile');
//         },
//         items: const [
//           BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house, size: 20.0), label: 'Home'),
//           BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.message, size: 20.0), label: 'Tickets'),
//           BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.user, size: 20.0), label: 'Profile'),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: (){},
//         shape: CircleBorder(),
//         tooltip: 'Post a process', // Accessiblity hint on long presss
//         backgroundColor: Theme.of(context).primaryColor,
//         // foregroundColor: Colors.white,
//         child: const Icon(Icons.add, color: Colors.white),
//         ),
//     );
//   }
  
//   Widget _buildHeaderContent() {
//     return Column(
//       children: [
//         // ... Your Search TextField and Chips from previous step
//       ],
//     );
//   }
// }







class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  // Firebase & Pagination
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final List<DocumentSnapshot> _products = [];
  
  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 10;
  
  // Search & Filter state
  String _searchQuery = "";
  String _selectedCategory = "All";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchProcesses();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
        if (!_isLoading && _hasMore) _fetchProcesses();
      }
    });
  }

  // Fetch logic with Category and Search filtering
  Future<void> _fetchProcesses() async {
    if (_isLoading || !_hasMore) return;
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
      if (snapshot.docs.length < _limit) _hasMore = false;
      
      setState(() {
        _products.addAll(snapshot.docs);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Firebase Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _products.clear();
        _hasMore = true;
      });
      _fetchProcesses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(8)),
              child: const Text("GG", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            const Text("GovGuide", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.bell, size: 20)),
          IconButton(onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.bars, size: 20)),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search processes...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF1F3F4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          // Category Chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ["All", "Education", "Health", "Business", "Legal"].map((cat) => _buildChip(cat)).toList(),
            ),
          ),
          // Infinite Scroll List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _products.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _products.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final data = _products[index].data() as Map<String, dynamic>;
                return ServiceCard(
                  id: _products[index].id,
                  title: data['title'] ?? '',
                  rating: data['rating']?.toString() ?? '0.0',
                  reviews: data['reviews']?.toString() ?? '0',
                  description: data['description'] ?? '',
                  agency: data['agency'] ?? '',
                  tag: data['tag'] ?? '',
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        onTap: (index) {
          if (index == 1) context.push('/tickets');
          if (index == 2) context.push('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house, size: 20), label: "Home"),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.message, size: 20), label: "Tickets"),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.user, size: 20), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    bool isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _selectedCategory = label;
            _products.clear();
            _hasMore = true;
          });
          _fetchProcesses();
        },
        selectedColor: Colors.blueAccent,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }
}

// Stateful Service Card for Likes and Navigation
class ServiceCard extends StatefulWidget {
  final String id, title, rating, reviews, description, agency, tag;
  const ServiceCard({super.key, required this.id, required this.title, required this.rating, required this.reviews, required this.description, required this.agency, required this.tag});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/details/${widget.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  IconButton(
                    onPressed: () => setState(() => isLiked = !isLiked),
                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey),
                  )
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                  Text(" ${widget.rating} (${widget.reviews})"),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(widget.tag, style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(widget.description, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.account_balance, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(widget.agency, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}














































// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Welcome back, Citizen.",
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 20),
          
//           // Example "Pending Action" Card
//           Card(
//             elevation: 2,
//             color: Colors.orange[50],
//             child: const ListTile(
//               leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
//               title: Text("Action Required"),
//               subtitle: Text("Vehicle registration renewal due soon."),
//               trailing: Icon(Icons.arrow_forward_ios, size: 16),
//             ),
//           ),
//           const SizedBox(height: 20),

//           Text("Quick Services", style: Theme.of(context).textTheme.titleMedium),
//           const SizedBox(height: 10),
          
//           // Example Grid for quick links
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 3,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//             children: [
//               _buildQuickLinkIcon(Icons.file_copy, "Documents"),
//               _buildQuickLinkIcon(Icons.payment, "Taxes"),
//               _buildQuickLinkIcon(Icons.directions_car, "Vehicles"),
//               _buildQuickLinkIcon(Icons.business, "Permits"),
//               _buildQuickLinkIcon(Icons.health_and_safety, "Health"),
//               _buildQuickLinkIcon(Icons.more_horiz, "More"),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickLinkIcon(IconData icon, String label) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200)
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 30, color: const Color(0xFF005696)),
//           const SizedBox(height: 8),
//           Text(label, style: const TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }
// }