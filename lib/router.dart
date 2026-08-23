import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/auth/phone_auth_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/module_selection_screen.dart';
import 'screens/home/home_dashboard_screen.dart';
import 'screens/design/design_welcome_screen.dart';
import 'screens/design/create_design_screen.dart';
import 'screens/design/element_edit_screen.dart';
import 'screens/design/tap_to_edit_screen.dart';
import 'screens/design/image_to_image_screen.dart';
import 'screens/design/my_concepts_screen.dart';
import 'screens/finance/finance_home_screen.dart';
import 'screens/finance/enhanced_material_tracker_screen.dart';
import 'screens/finance/samiti_funds_screen.dart';
import 'screens/finance/worker_funds_screen.dart';
import 'screens/orders/add_client_screen.dart';
import 'screens/orders/client_details_screen.dart';
import 'screens/orders/clients_screen.dart';
import 'screens/orders/client_chat_screen.dart';
import 'screens/orders/delivery_dates_screen.dart';
import 'screens/orders/record_payment_screen.dart';
import 'screens/orders/send_update_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/analytics_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'providers/auth_provider.dart';
import 'services/onboarding_service.dart';
import 'models/generated_image.dart';
import 'widgets/app_scaffold.dart';

final GoRouter router = GoRouter(
  initialLocation: '/onboarding',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentPath = state.uri.toString();

    // Don't redirect while auth is loading to avoid race conditions
    if (authProvider.isLoading) {
      return null;
    }

    // DEMO MODE: Set to false to enable real authentication
    const bool demoMode = false;

    if (demoMode) {
      // In demo mode, skip auth screens and go directly to main app
      if (currentPath == '/onboarding' ||
          currentPath.startsWith('/auth') ||
          currentPath.startsWith('/sign-in') ||
          currentPath.startsWith('/otp-verification')) {
        return '/main';
      }
      return null;
    }

    // PRODUCTION MODE: Enforce authentication
    final isPublicRoute = currentPath == '/onboarding' ||
        currentPath.startsWith('/auth') ||
        currentPath.startsWith('/sign-in') ||
        currentPath.startsWith('/otp-verification');

    // Onboarding only needs to be shown once — skip straight to sign-in after that
    if (currentPath == '/onboarding' &&
        OnboardingService.hasSeenOnboarding &&
        !authProvider.isAuthenticated) {
      return '/auth';
    }

    // Redirect unauthenticated users to onboarding (or straight to sign-in
    // if they've already been through onboarding on a previous launch)
    if (!authProvider.isAuthenticated && !isPublicRoute) {
      return OnboardingService.hasSeenOnboarding ? '/auth' : '/onboarding';
    }

    // Redirect authenticated users away from auth screens
    if (authProvider.isAuthenticated && isPublicRoute) {
      return '/main';
    }

    // Handle finance module routes - ensure we don't get stuck in redirect loops
    if (currentPath.startsWith('/finance/')) {
      // If we're already in the finance module, don't redirect
      return null;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const ModuleSelectionScreen(),
    ),
    GoRoute(
      path: '/',
      redirect: (context, state) => '/main',
    ),
    // Finance Module Routes
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffold(
          body: child,
          currentIndex: _getFinanceIndex(state.uri.toString()),
          onNavTap: (index) {
            // Must match the 3-item nav AppScaffold actually renders for the
            // finance module (showHomeIcon + !isDesignModule): Dashboard,
            // Orders, Reports. Materials/Samiti/Worker are reached from the
            // dashboard's grid, not this bottom nav.
            final routes = [
              '/finance/dashboard',
              '/finance/orders',
              '/finance/reports',
            ];
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
          builder: (context, state) => const FinanceHomeScreen(),
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
        // Finance-specific routes
        GoRoute(
          path: '/finance/materials',
          builder: (context, state) => const EnhancedMaterialTrackerScreen(),
        ),
        GoRoute(
          path: '/finance/materials/enhanced',
          builder: (context, state) => const EnhancedMaterialTrackerScreen(),
        ),
        GoRoute(
          path: '/finance/samiti-funds',
          builder: (context, state) => const SamitiFundsScreen(),
        ),
        GoRoute(
          path: '/finance/worker-funds',
          builder: (context, state) => const WorkerFundsScreen(),
        ),
        // Orders routes for Finance module
        GoRoute(
          path: '/finance/orders/client/:id',
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
        GoRoute(
          path: '/finance/orders/client/:id/chat',
          builder: (context, state) => ClientChatScreen(
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
        // New simplified design routes
        GoRoute(
          path: '/design/create',
          builder: (context, state) => const CreateDesignScreen(),
        ),
        GoRoute(
          path: '/design/edit',
          builder: (context, state) => const MyConceptsScreen(),
        ),
        GoRoute(
          path: '/design/edit/image/:id',
          builder: (context, state) => ElementEditScreen(
            originalImage: state.extra as GeneratedImage,
          ),
        ),
        GoRoute(
          path: '/design/tap-to-edit',
          builder: (context, state) => const TapToEditScreen(),
        ),
        GoRoute(
          path: '/design/image-to-image',
          builder: (context, state) => const ImageToImageScreen(),
        ),
        GoRoute(
          path: '/design/tap-to-edit/image/:id',
          builder: (context, state) => TapToEditScreen(
            image: state.extra as GeneratedImage,
          ),
        ),
        // Orders routes for Design module (minimal)
        GoRoute(
          path: '/design/orders/client/:id',
          builder: (context, state) => ClientDetailsScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/design/orders/add-client',
          builder: (context, state) => const AddClientScreen(),
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
  // Must match the 3-item nav AppScaffold renders for the finance module:
  // Dashboard, Orders, Reports.
  if (path == '/finance/dashboard') return 0;
  if (path.startsWith('/finance/orders')) return 1;
  if (path.startsWith('/finance/reports')) return 2;
  // Sub-pages reached from the dashboard's grid (materials, samiti-funds,
  // worker-funds, worker-details, ...) don't correspond to any of the 3
  // tabs, so leave none of them highlighted rather than falsely showing
  // "Dashboard" as active.
  return -1;
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
