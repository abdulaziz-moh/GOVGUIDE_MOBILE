
import 'package:flutter/material.dart';
import 'package:govguide/auth/auth_provider.dart';
import 'package:govguide/auth/login_screen.dart';
import 'package:provider/provider.dart';

class GovGuideApp extends StatelessWidget {
  const GovGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return MaterialApp(
      title: 'GovGuide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // A professional color palette suitable for government apps
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF005696), // Darker specific blue
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF005696),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF005696),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        useMaterial3: true,
      ),
      home: authProvider.isLoggedIn? const MainScreen() : const LoginScreen(), //here we the home route choosed 
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // The list of pages corresponding to the tabs
  final List<Widget> _pages = [
    // const HomeTab(),
    // const SearchTab(),
    // const CreateTab(),
    // const ProfileTab(),
  ];

  // Titles for the App Bar based on current index
  final List<String> _titles = [
    'GovGuide Home',
    'Search Processes',
    'Start New Process',
    'My Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use a common AppBar that changes title based on selection
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          // Example action button (e.g., notifications) common to all pages
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      // The body keeps the state of the tabs alive so scrolling positions are saved
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Type fixed is important when you have 4+ items to prevent shifting
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search_sharp),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            // Using add_circle for "Create Process"
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
