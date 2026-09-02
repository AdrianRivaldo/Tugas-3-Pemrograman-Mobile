import 'package:flutter/material.dart';

import 'services/ticket_provider.dart';
import 'screens/home_screen.dart';
import 'screens/my_tickets_screen.dart';
import 'screens/profile_screen.dart';

// ✅ PASTIKAN FUNGSI INI ADA DI PALING ATAS (DI LUAR CLASS APAPUN)
void main() {
  runApp(const TiketinAjaApp());
}

class TiketinAjaApp extends StatelessWidget {
  const TiketinAjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiketin Aja',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1a3a6b),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final TicketProvider _provider = TicketProvider();

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;

    switch (_currentIndex) {
      case 0:
        currentScreen = HomeScreen(provider: _provider);
        break;
      case 1:
        currentScreen = MyTicketsScreen(provider: _provider);
        break;
      case 2:
        // Perhatikan: TIDAK ADA 'const' di sini karena ProfileScreen butuh parameter
        currentScreen = ProfileScreen(provider: _provider);
        break;
      default:
        currentScreen = HomeScreen(provider: _provider);
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1a3a6b),
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'Tiket Saya',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
