
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    double tenPercentHeight = MediaQuery.sizeOf(context).height * 0.10;

    return Scaffold(
      appBar: AppBar(
        title: const Text("GovGuide", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                IconButton(
                  onPressed: () {},
                  icon: const FaIcon(FontAwesomeIcons.bell, color: Color(0xFF646E78), size: 20.0),
                ),
                IconButton(
                  onPressed: () { context.push('/profile'); },
                  icon: const FaIcon(FontAwesomeIcons.bars, color: Color(0xFF646E78), size: 20.0),
                ),
              ],)
          
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(tenPercentHeight),
          child: _buildHeaderContent(), // Search bar and Chips logic here
        ),
      ),
      // body: const HomeListView(), // The list of passport/business cards
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Always 0 because we are on Home
        onTap: (index) {
          if (index == 1) context.push('/tickets');
          if (index == 2) context.push('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house, size: 20.0), label: 'Home'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.message, size: 20.0), label: 'Tickets'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.user, size: 20.0), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        shape: CircleBorder(),
        tooltip: 'Post a process', // Accessiblity hint on long presss
        backgroundColor: Theme.of(context).primaryColor,
        // foregroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.white),
        ),
    );
  }
  
  Widget _buildHeaderContent() {
    return Column(
      children: [
        // ... Your Search TextField and Chips from previous step
      ],
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