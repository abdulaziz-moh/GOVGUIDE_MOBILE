import 'package:flutter/material.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar Field
          TextField(
            decoration: InputDecoration(
              hintText: 'Search services, forms, departments...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 20),

          // Placeholder for recent searches or popular topics
          Expanded(
            child: ListView(
               children: const [
                 ListTile(
                   leading: Icon(Icons.history),
                   title: Text("Passport Application"),
                 ),
                 ListTile(
                   leading: Icon(Icons.trending_up),
                   title: Text("Popular: Business License"),
                 ),
                ListTile(
                  leading: Icon(Icons.trending_up),
                  title: Text("Popular: Address Change"),
                ),
               ],
            ),
          )
        ],
      ),
    );
  }
}