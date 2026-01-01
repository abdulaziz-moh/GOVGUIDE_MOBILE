import 'package:go_router/go_router.dart';
import 'package:govguide/auth/auth_provider.dart';
import 'package:govguide/auth/login_screen.dart';
import 'package:govguide/auth/signup_screen.dart'; // Ensure this import is correct
import 'package:govguide/screens/help/help_screen.dart';
import 'package:govguide/screens/home/home_screen.dart';
import 'package:govguide/screens/processes/process_detail_screen.dart';
import 'package:govguide/screens/processes/process_post.dart';
import 'package:govguide/screens/profile/profile_screen.dart';
import 'package:govguide/screens/support/create_ticket_screen.dart';
import 'package:govguide/screens/support/my_tickets_screen.dart';
import 'package:govguide/screens/support/ticket_success_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,

    redirect: (context, state) {
      final bool isLoggedIn = authProvider.isLoggedIn;
      final bool isLoggingIn = state.matchedLocation == '/login';
      final bool isSigningUp = state.matchedLocation == '/signup'; // Added this check

      // UPDATED: Include /signup as a public page
      final bool isPublicPage =
          state.matchedLocation == '/' ||
          state.matchedLocation == '/signup' || // Allow signup
          state.matchedLocation.startsWith('/details');

      if (!isLoggedIn) {
        // If not logged in, allow access to public pages, login, or signup
        if (isPublicPage || isLoggingIn) return null;

        // Otherwise, force login
        return '/login';
      }

      // If already logged in, don't let them see login or signup pages
      if (isLoggingIn || isSigningUp) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      
      // ADDED THE SIGNUP ROUTE HERE
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),

      GoRoute(
        path: '/details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProcessDetailScreen(processId: id);
        },
      ),
      GoRoute(
        path: '/tickets',
        builder: (context, state) => const TicketsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/post',
        builder: (context, state) => const PostProcessScreen(),
      ),
      GoRoute(
        path: '/create-ticket',
        builder: (context, state) => const CreateTicketScreen(),
      ),
      GoRoute(
        path: '/ticket-success',
        builder: (context, state) => const TicketSuccessScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpCenterScreen(),
      ),
    ],
  );
}