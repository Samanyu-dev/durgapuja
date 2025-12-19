import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/colors.dart';
import 'router.dart';
import 'widgets/app_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Durga Idol Maker',
      theme: ThemeData(
        primaryColor: AppColors.primaryBrown,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundCream,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<String> _routes = ['/', '/design', '/orders', '/finance', '/reports'];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Router.withConfig(
        config: router,
      ),
      currentIndex: _currentIndex,
      onNavTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        context.go(_routes[index]);
      },
    );
  }
}
