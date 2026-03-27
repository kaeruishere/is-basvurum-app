import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'companies_screen.dart';
import 'templates_screen.dart';
import 'applications_screen.dart';
import 'apply_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CompaniesScreen(),
    const TemplatesScreen(),
    const ApplicationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFE8FF47),
        unselectedItemColor: Colors.white.withOpacity(0.3),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'Firmalar'),
          BottomNavigationBarItem(icon: Icon(Icons.description_rounded), label: 'Şablonlar'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Başvurular'),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplyScreen()));
        },
        backgroundColor: const Color(0xFFE8FF47),
        child: const Icon(Icons.send_rounded, color: Colors.black),
      ) : null,
    );
  }
}