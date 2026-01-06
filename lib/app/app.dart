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
      routerConfig: createRouter(
        authProvider,
      ), //to update route when notifilistners call(login status changed)

      title: 'GovGuide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,

            primary: Color(0xFF145AFA),
            onPrimary: Colors.white,

            secondary: Color(0xFF145AFA),
            onSecondary: Colors.white,

            surface: Colors.white,
            onSurface: Colors.black,

            surfaceContainerHighest : Color(0xFFEAF0FF), // removes purple tint
            onSurfaceVariant: Colors.black,

            outline: Color(0xFF145AFA),

            error: Colors.red,
            onError: Colors.white,
          ),

        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: const Color.fromARGB(255, 20, 90, 250),
        //   primary: const Color.fromARGB(255, 20, 90, 250),
        // ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFC),
          cardTheme: CardThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.transparent, // VERY IMPORTANT
            elevation: 0,
          ),

          chipTheme: ChipThemeData(
            backgroundColor: Color(0xFFEAF0FF),
            selectedColor: Color(0xFF145AFA),
            labelStyle: TextStyle(color: Colors.black),
            secondaryLabelStyle: TextStyle(color: Colors.white),
            side: BorderSide.none,
          ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        // Fixes the purple "ink" splash on clicks
        splashColor: const Color.fromARGB(
          255,
          20,
          90,
          250,
        ).withValues(alpha: 0.1),
        highlightColor: const Color.fromARGB(
          255,
          20,
          90,
          250,
        ).withValues(alpha: 0.05),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color.fromARGB(255, 20, 90, 250),
          unselectedItemColor: Color.fromARGB(255, 100, 110, 120),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      // home: authProvider.isLoggedIn? const MainScreen() : const LoginScreen(), //here we the home route choosed
    );
  }
}
