import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/admin/admin_login_screen.dart';

void main() {
  runApp(const ScholarDocAdminApp());
}

class ScholarDocAdminApp extends StatelessWidget {
  const ScholarDocAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScholarDoc Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AdminLoginScreen(),
    );
  }
}
