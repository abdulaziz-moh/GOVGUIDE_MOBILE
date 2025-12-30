import 'package:flutter/material.dart';
import 'package:govguide/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:govguide/app/routes.dart';

class GovGuideApp extends StatelessWidget {
  const GovGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return MaterialApp.router(
      routerConfig: createRouter(authProvider), //to update route when notifilistners call(login status changed)

      title: 'GovGuide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color.fromARGB(255, 20, 90, 250), // Darker specific blue
        scaffoldBackgroundColor: Color(0xFFF9FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          // centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color.fromARGB(255, 20, 90, 250),
          unselectedItemColor: Color.fromARGB(255, 100, 110, 120),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        useMaterial3: true,
      ),
      // home: authProvider.isLoggedIn? const MainScreen() : const LoginScreen(), //here we the home route choosed 
    );
  }
}
