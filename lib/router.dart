import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/dynamic_island_nav.dart';
import 'screens/home/home_dashboard_screen.dart';
import 'screens/home/module_selection_screen.dart';
import 'screens/design/design_welcome_screen.dart';
import 'screens/design/create_design_screen.dart';
import 'screens/design/element_edit_screen.dart';
import 'screens/orders/clients_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/design/ai_design_assistant_screen.dart';
import 'screens/design/sculpting_assistant_screen.dart';
import 'screens/design/fine_detailing_screen.dart';
import 'screens/design/create_preview_screen.dart';
import 'screens/design/create_backdrop_screen.dart';
import 'screens/design/suggest_lighting_screen.dart';
import 'screens/design/tap_to_edit_screen.dart';
import 'screens/orders/client_chat_screen.dart';
import 'screens/orders/client_details_screen.dart';
import 'screens/orders/add_client_screen.dart';
import 'screens/orders/delivery_dates_screen.dart';
import 'screens/orders/send_update_screen.dart';
import 'screens/orders/record_payment_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/analytics_dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/finance/finance_home_screen.dart';
import 'screens/finance/samiti_funds_screen.dart';
import 'screens/finance/worker_funds_screen.dart';
import 'screens/finance/worker_details_screen.dart';
import 'screens/finance/material_screen.dart';
import 'screens/finance/material_tracker_screen.dart';

import 'screens/auth/phone_auth_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'providers/auth_provider.dart';
import 'models/generated_image.dart';

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
        final financeNavItems = [
          const NavItem(icon: Icons.home_outlined, label: 'Dashboard'),
          const NavItem(icon: Icons.category_outlined, label: 'Materials'),
          const NavItem(icon: Icons.account_balance_wallet_outlined, label: 'Samiti Funds'),
          const NavItem(icon: Icons.people_outlined, label: 'Worker Funds'),
          const NavItem(icon: Icons.shopping_bag_outlined, label: 'Orders'),
          const NavItem(icon: Icons.bar_chart_outlined, label: 'Reports'),
        ];

        return AppScaffold(
          body: child,
          currentIndex: _getFinanceIndex(state.uri.toString()),
          onNavTap: (index) {
            final routes = [
              '/finance/dashboard', 
              '/finance/materials', 
              '/finance/samiti-funds', 
              '/finance/worker-funds',
              '/finance/orders', 
              '/finance/reports'
            ];
            if (index >= 0 && index < routes.length) {
              context.go(routes[index]);
            }
          },
          showHomeIcon: true,
          customNavItems: financeNavItems,
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
          builder: (context, state) => const MaterialsScreen(),
        ),
        GoRoute(
          path: '/finance/materials/tracker',
          builder: (context, state) => const MaterialTrackerScreen(),
        ),
        GoRoute(
          path: '/finance/samiti-funds',
          builder: (context, state) => const SamitiFundsScreen(),
        ),
        GoRoute(
          path: '/finance/worker-funds',
          builder: (context, state) => const WorkerFundsScreen(),
        ),
        GoRoute(
          path: '/finance/worker-details',
          builder: (context, state) {
            final args = {
              'name': state.uri.queryParameters['name'] ?? 'Unknown',
              'category': state.uri.queryParameters['category'] ?? 'Unknown',
              'budget': state.uri.queryParameters['budget'] ?? '0',
              'paid': state.uri.queryParameters['paid'] ?? '0',
            };
            return WorkerDetailsScreen.fromArgs(args);
          },
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
        // New simplified design routes
        GoRoute(
          path: '/design/create',
          builder: (context, state) => const CreateDesignScreen(),
        ),
        GoRoute(
          path: '/design/edit',
          builder: (context, state) => const Text('Edit Existing Designs'),
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
          path: '/design/tap-to-edit/image/:id',
          builder: (context, state) => TapToEditScreen(
            image: state.extra as GeneratedImage,
          ),
        ),
        // Orders routes for Design module (minimal)
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
  if (path.startsWith('/finance/materials')) return 1;
  if (path.startsWith('/finance/samiti-funds')) return 2;
  if (path.startsWith('/finance/worker-funds')) return 3;
  if (path.startsWith('/finance/orders')) return 4;
  if (path.startsWith('/finance/reports')) return 5;
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
