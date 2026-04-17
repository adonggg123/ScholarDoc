import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import 'dashboard/home_screen.dart';
import 'submissions/status_tracking_screen.dart';
import 'submissions/upload_workflow_screen.dart';
import 'notifications/notification_screen.dart';
import 'profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimController;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatusTrackingScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  static const List<_NavItem> _items = [
    _NavItem(icon: LucideIcons.home, label: 'Home'),
    _NavItem(icon: LucideIcons.clipboardList, label: 'Status'),
    _NavItem(icon: LucideIcons.bell, label: 'Alerts'),
    _NavItem(icon: LucideIcons.user, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgC,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? ScaleTransition(
              scale: CurvedAnimation(
                parent: _fabAnimController,
                curve: Curves.easeOutBack,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBC02D), Color(0xFFF9A825)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UploadWorkflowScreen()),
                    );
                  },
                  backgroundColor: Colors.transparent,
                  foregroundColor: const Color(0xFF0F3260),
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  splashColor: Colors.white.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  icon: const Icon(LucideIcons.uploadCloud, size: 20),
                  label: const Text(
                    'Submit Docs',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: List.generate(_items.length + 1, (i) {
              // Centre slot for FAB notch
              if (i == 2) {
                return const Expanded(child: SizedBox(height: 56));
              }
              final idx = i > 2 ? i - 1 : i;
              final selected = _currentIndex == idx;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() => _currentIndex = idx);
                    _fabAnimController.forward(from: 0);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryColor.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: selected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _items[idx].icon,
                            color: selected ? AppTheme.primaryColor : context.textSec,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _items[idx].label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                            color: selected ? AppTheme.primaryColor : context.textSec,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          width: selected ? 20 : 0,
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
