import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'widgets/app_scaffold.dart';
import 'screens/home/home_dashboard_screen.dart';
import 'screens/home/module_selection_screen.dart';
import 'screens/design/design_welcome_screen.dart';
import 'screens/orders/clients_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/design/ai_design_assistant_screen.dart';
import 'screens/design/sculpting_assistant_screen.dart';
import 'screens/design/fine_detailing_screen.dart';
import 'screens/design/create_preview_screen.dart';
import 'screens/design/create_backdrop_screen.dart';
import 'screens/design/suggest_lighting_screen.dart';
import 'screens/orders/client_chat_screen.dart';
import 'screens/orders/client_details_screen.dart';
import 'screens/orders/add_client_screen.dart';
import 'screens/orders/delivery_dates_screen.dart';
import 'screens/orders/send_update_screen.dart';
import 'screens/orders/record_payment_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/analytics_dashboard_screen.dart';
import 'screens/inventory_screen.dart';

import 'screens/auth/phone_auth_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'providers/auth_provider.dart';

final GoRouter router = GoRouter(
  initialLocation: '/onboarding',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentPath = state.uri.toString();

    print('Router redirect: path=$currentPath, isAuthenticated=${authProvider.isAuthenticated}, isLoading=${authProvider.isLoading}'); // Debug log

    // Don't redirect while auth is loading to avoid race conditions
    if (authProvider.isLoading) {
      print('Router: Auth is loading, not redirecting'); // Debug log
      return null;
    }

    // If user is not authenticated and trying to access protected routes
    if (!authProvider.isAuthenticated &&
        !currentPath.startsWith('/onboarding') &&
        !currentPath.startsWith('/auth') &&
        !currentPath.startsWith('/sign-in') &&
        !currentPath.startsWith('/otp-verification')) {
      print('Router: Redirecting to /auth (not authenticated)'); // Debug log
      return '/auth';
    }

    // If user is authenticated and on auth/onboarding screens, redirect to main app
    if (authProvider.isAuthenticated &&
        (currentPath == '/onboarding' ||
         currentPath.startsWith('/auth') ||
         currentPath.startsWith('/sign-in') ||
         currentPath.startsWith('/otp-verification'))) {
      print('Router: Redirecting to / (authenticated, on auth screen)'); // Debug log
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const ModuleSelectionScreen(),
    ),
    // Finance Module Routes
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffold(
          body: child,
          currentIndex: _getFinanceIndex(state.uri.toString()),
          onNavTap: (index) {
            final routes = ['/finance/dashboard', '/finance/orders', '/finance/reports'];
            if (index >= 0 && index < routes.length) {
              context.go(routes[index]);
            }
          },
          showHomeIcon: true,
        );
      },
      routes: [
        GoRoute(
          path: '/finance/dashboard',
          builder: (context, state) => const HomeDashboardScreen(),
        ),
        GoRoute(
          path: '/finance',
          redirect: (context, state) => '/finance/dashboard',
        ),
        GoRoute(
          path: '/finance/orders',
          builder: (context, state) => const ClientsScreen(),
        ),
        GoRoute(
          path: '/finance/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        // Orders routes for Finance module
        GoRoute(
          path: '/finance/orders/client/:id',
          builder: (context, state) => ClientChatScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/finance/orders/client/:id/details',
          builder: (context, state) => ClientDetailsScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/finance/orders/add-client',
          builder: (context, state) => const AddClientScreen(),
        ),
        GoRoute(
          path: '/finance/orders/client/:id/delivery-dates',
          builder: (context, state) => DeliveryDatesScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/finance/orders/client/:id/send-update',
          builder: (context, state) => SendUpdateScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/finance/orders/client/:id/record-payment',
          builder: (context, state) => RecordPaymentScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
    // Design Module Routes
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffold(
          body: child,
          currentIndex: _getDesignIndex(state.uri.toString()),
          onNavTap: (index) {
            final routes = ['/design/dashboard', '/design/welcome'];
            if (index >= 0 && index < routes.length) {
              context.go(routes[index]);
            }
          },
          showHomeIcon: true,
          isDesignModule: true,
        );
      },
      routes: [
        GoRoute(
          path: '/design/dashboard',
          builder: (context, state) => const HomeDashboardScreen(),
        ),
        GoRoute(
          path: '/design',
          redirect: (context, state) => '/design/welcome',
        ),
        GoRoute(
          path: '/design/welcome',
          builder: (context, state) => const DesignWelcomeScreen(),
        ),
        GoRoute(
          path: '/design/orders',
          builder: (context, state) => const ClientsScreen(),
        ),
        GoRoute(
          path: '/design/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        // Design routes
        GoRoute(
          path: '/design/idea-generation',
          builder: (context, state) => const AIDesignAssistantScreen(),
        ),
        GoRoute(
          path: '/design/sculpting',
          builder: (context, state) => const SculptingAssistantScreen(),
        ),
        GoRoute(
          path: '/design/detailing',
          builder: (context, state) => const FineDetailingScreen(),
        ),
        GoRoute(
          path: '/design/preview',
          builder: (context, state) => const CreatePreviewScreen(),
        ),
        GoRoute(
          path: '/design/backdrop',
          builder: (context, state) => const CreateBackdropScreen(),
        ),
        GoRoute(
          path: '/design/lighting',
          builder: (context, state) => const SuggestLightingScreen(),
        ),
        // Orders routes for Design module
        GoRoute(
          path: '/design/orders/client/:id',
          builder: (context, state) => ClientChatScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/design/orders/client/:id/details',
          builder: (context, state) => ClientDetailsScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/design/orders/add-client',
          builder: (context, state) => const AddClientScreen(),
        ),
        GoRoute(
          path: '/design/orders/client/:id/delivery-dates',
          builder: (context, state) => DeliveryDatesScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/design/orders/client/:id/send-update',
          builder: (context, state) => SendUpdateScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/design/orders/client/:id/record-payment',
          builder: (context, state) => RecordPaymentScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
    // Analytics Dashboard Route
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsDashboardScreen(),
    ),
    // Inventory Management Route
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryScreen(),
    ),
    // Auth Routes
    GoRoute(
      path: '/auth',
      builder: (context, state) => const PhoneAuthScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/otp-verification',
      builder: (context, state) => const OtpVerificationScreen(),
    ),
    // Admin Routes
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);

int _getFinanceIndex(String path) {
  if (path == '/finance/dashboard') return 0;
  if (path.startsWith('/finance/orders')) return 1;
  if (path.startsWith('/finance/reports')) return 2;
  return 0; // default to dashboard
}

int _getDesignIndex(String path) {
  if (path == '/design/dashboard') {
    return 0;
  }
  if (path.startsWith('/design/welcome') || path.startsWith('/design/idea-generation') ||
      path.startsWith('/design/sculpting') || path.startsWith('/design/detailing') ||
      path.startsWith('/design/preview') || path.startsWith('/design/backdrop') ||
      path.startsWith('/design/lighting') || path.startsWith('/design/orders') ||
      path.startsWith('/design/reports')) {
    return 1;
  }
  return 0; // default to dashboard
}
