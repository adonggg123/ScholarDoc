import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import 'dashboard/home_screen.dart';
import 'submissions/status_tracking_screen.dart';
import 'notifications/notification_screen.dart';
import 'profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatusTrackingScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              activeIcon: Icon(LucideIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.fileText),
              activeIcon: Icon(LucideIcons.fileText),
              label: 'Submissions',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.bell),
              activeIcon: Icon(LucideIcons.bell),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              activeIcon: Icon(LucideIcons.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
      // Floating Action Button for quick upload access
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navigate to workflow screen (Implemented later)
              },
              backgroundColor: AppTheme.primaryColor,
              icon: Icon(LucideIcons.uploadCloud, color: Colors.white),
              label: Text(
                'Submit Docs',
                style: TextStyle(color: context.surfaceC, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
