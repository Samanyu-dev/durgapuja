import 'package:go_router/go_router.dart';
import 'widgets/app_scaffold.dart';
import 'screens/home/home_dashboard_screen.dart';
import 'screens/design/design_welcome_screen.dart';
import 'screens/orders/clients_screen.dart';
import 'screens/finance/finance_home_screen.dart';
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

final GoRouter router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffold(
          body: child,
          currentIndex: _getCurrentIndex(state.uri.toString()),
          onNavTap: (index) {
            final routes = ['/', '/design', '/orders', '/finance', '/reports'];
            if (index >= 0 && index < routes.length) {
              context.go(routes[index]);
            }
          },
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeDashboardScreen(),
        ),
        GoRoute(
          path: '/design',
          builder: (context, state) => const DesignWelcomeScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const ClientsScreen(),
        ),
        GoRoute(
          path: '/finance',
          builder: (context, state) => const FinanceHomeScreen(),
        ),
        GoRoute(
          path: '/reports',
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
        // Orders routes
        GoRoute(
          path: '/orders/client/:id',
          builder: (context, state) => ClientChatScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/orders/client/:id/details',
          builder: (context, state) => ClientDetailsScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/orders/add-client',
          builder: (context, state) => const AddClientScreen(),
        ),
        GoRoute(
          path: '/orders/client/:id/delivery-dates',
          builder: (context, state) => DeliveryDatesScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/orders/client/:id/send-update',
          builder: (context, state) => SendUpdateScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/orders/client/:id/record-payment',
          builder: (context, state) => RecordPaymentScreen(
            clientId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ],
);

int _getCurrentIndex(String path) {
  if (path == '/' || path.startsWith('/home')) return 0;
  if (path.startsWith('/design')) return 1;
  if (path.startsWith('/orders')) return 2;
  if (path.startsWith('/finance')) return 3;
  if (path.startsWith('/reports')) return 4;
  return 0; // default to home
}
