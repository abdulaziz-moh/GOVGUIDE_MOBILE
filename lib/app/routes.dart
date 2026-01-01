import 'package:go_router/go_router.dart';
import 'package:govguide/auth/auth_provider.dart';
import 'package:govguide/auth/login_screen.dart';
import 'package:govguide/screens/home/home_screen.dart';
import 'package:govguide/screens/processes/process_detail_screen.dart';
import 'package:govguide/screens/processes/process_post.dart';
import 'package:govguide/screens/profile/profile_screen.dart';
import 'package:govguide/screens/support/my_tickets_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,

    redirect: (context, state) {
      final bool isLoggedIn = authProvider.isLoggedIn;
      final bool isLoggingIn = state.matchedLocation == '/login';

      // CHECK IF PATH IS PUBLIC
      // This allows anyone to view the home page or a specific process detail
      final bool isPublicPage =
          state.matchedLocation == '/' ||
          state.matchedLocation.startsWith('/details');

      if (!isLoggedIn) {
        // If not logged in, allow access to public pages or the login screen
        if (isPublicPage || isLoggingIn) return null;

        // Otherwise, force login
        return '/login';
      }

      if (isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // ADD THE DETAILS ROUTE HERE
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
    ],
  );
}
