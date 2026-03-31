import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import 'dashboard_overview.dart';
import 'student_records_screen.dart';
import 'sa_verification_screen.dart';
import 'audit_log_screen.dart';
import 'reports_screen.dart';
import 'admin_settings_screen.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const DashboardOverview(),
    const StudentRecordsScreen(),
    const SaVerificationScreen(),
    const AuditLogScreen(),
    const ReportsScreen(),
    const AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 1100;

        return Scaffold(
          key: _scaffoldKey,
          drawer: isMobile ? _buildDrawer() : null,
          body: Row(
            children: [
              // Sidebar (Persistent on desktop)
              if (!isMobile)
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 210,
                      decoration: BoxDecoration(
                        color: context.surfaceC.withValues(alpha: 0.7),
                        border: Border(
                          right: BorderSide(
                            color: context.surfaceC.withValues(alpha: 0.2),
                          ),
                        ),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: _buildSidebarContent(),
                    ),
                  ),
                ),
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(isMobile),
                    Expanded(
                      child: Container(
                        color: context.bgC,
                        child: _selectedIndex < _screens.length
                            ? _screens[_selectedIndex]
                            : _screens[0],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(child: _buildSidebarContent());
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        _buildSidebarHeader(),
        SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildNavItem(0, 'Dashboard', LucideIcons.layoutDashboard),
                _buildNavItem(1, 'Student Records', LucideIcons.users),
                _buildNavItem(2, 'SA Verification', LucideIcons.landmark),
                _buildNavItem(3, 'Activity Logs', LucideIcons.history),
                _buildNavItem(4, 'Reports', LucideIcons.barChart4),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 24),
                _buildNavItem(5, 'Settings', LucideIcons.settings),
                SizedBox(height: 8),
                _buildLogoutItem(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: context.surfaceC,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/app_logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.fill,
            ),
          ),
          Flexible(
            child: Text(
              'ScholarDoc',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: context.textPri,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
              Navigator.pop(context);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : context.textSec,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? context.textPri : context.textSec,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutItem() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(LucideIcons.logOut, color: AppTheme.error, size: 20),
            SizedBox(width: 16),
            Flexible(
              child: Text(
                'Logout',
                style: TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            color: context.surfaceC.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: context.surfaceC.withValues(alpha: 0.2),
              ),
            ),
            boxShadow: AppTheme.softShadow,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              if (isMobile)
                IconButton(
                  icon: Icon(LucideIcons.menu, size: 20),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Admin Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              // Notifications
              IconButton(
                onPressed: () {},
                icon: Icon(LucideIcons.bell, size: 20),
              ),
              if (!isMobile) ...[
                SizedBox(width: 8),
                // Admin Profile
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.secondaryColor,
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: context.surfaceC,
                        ),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Admin User',
                          style: TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
