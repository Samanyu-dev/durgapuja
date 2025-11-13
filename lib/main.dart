import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'screens/home/home_screen.dart';
import 'screens/design/my_concepts_screen.dart';
import 'screens/orders/clients_screen.dart';
import 'screens/finance/finance_home_screen.dart';
import 'widgets/dynamic_island_nav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Durga Idol Maker',
      theme: ThemeData(
        primaryColor: AppColors.primaryBrown,
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
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

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyConceptsScreen(),
    const ClientsScreen(),
    const FinanceHomeScreen(),
    const Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: Stack(
        children: [
          _screens[_currentIndex],
          DynamicIslandNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
