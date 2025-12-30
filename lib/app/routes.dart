import 'package:go_router/go_router.dart';
import 'package:govguide/auth/auth_provider.dart';
import 'package:govguide/auth/login_screen.dart';
import 'package:govguide/screens/home/home_screen.dart';
import 'package:govguide/screens/profile/profile_screen.dart';
import 'package:govguide/screens/support/my_tickets_screen.dart';


GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    // 1. Re-route automatically when authProvider calls notifyListeners()
    refreshListenable: authProvider, 
    
    // 2. Navigation logic formerly in your MaterialApp
    redirect: (context, state) {
      final bool isLoggedIn = authProvider.isLoggedIn;
      final bool isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        // If not logged in and not on login page, go to login
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        // If logged in but trying to access login page, go home
        return '/';
      }

      return null; // No redirection needed
    },
    routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/tickets',
      builder: (context, state) => const TicketsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
  );
}