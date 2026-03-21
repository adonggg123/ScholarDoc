import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/ml_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _saController = TextEditingController(text: '1234-5678-9012');
  final MLService _mlService = MLService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            onPressed: () {
              // Logout logic
            },
            icon: Icon(LucideIcons.logOut, color: AppTheme.error),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(LucideIcons.user, size: 60, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Juan De La Cruz',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'BS Computer Science - 3rd Year',
              style: TextStyle(color: context.textSec),
            ),
            SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Personal Information'),
                  SizedBox(height: 16),
                  _buildProfileField('Full Name', 'Juan De La Cruz', LucideIcons.user),
                  SizedBox(height: 16),
                  _buildProfileField('Student ID', '2021-00421', LucideIcons.badgeCheck),
                  SizedBox(height: 16),
                  _buildProfileField('Email', 'juan.dlc@university.edu.ph', LucideIcons.mail),
                  SizedBox(height: 32),
                  _buildSectionTitle('App Preferences'),
                  SizedBox(height: 16),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: ThemeProvider().themeNotifier,
                    builder: (context, theme, _) {
                      return SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        subtitle: Text('Switch between Light and Slate Dark mode.', style: TextStyle(fontSize: 12, color: context.textSec)),
                        value: theme == ThemeMode.dark,
                        activeTrackColor: AppTheme.primaryColor,
                        onChanged: (val) => ThemeProvider().toggleTheme(),
                      );
                    },
                  ),
                  SizedBox(height: 32),
                  _buildSectionTitle('Banking Details'),
                  SizedBox(height: 8),
                  Text(
                    'Provide your Savings Account (SA) number for scholarship fund disbursement.',
                    style: TextStyle(fontSize: 12, color: context.textSec),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _saController,
                    decoration: const InputDecoration(
                      labelText: 'SA Number',
                      hintText: 'xxxx-xxxx-xxxx',
                      prefixIcon: Icon(LucideIcons.creditCard),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your SA Number';
                      }
                      final mlCheck = _mlService.detectSASuspiciousPattern(value);
                      if (mlCheck['isSuspicious']) {
                        return mlCheck['message'] as String;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated successfully')),
                          );
                        }
                      },
                      child: Text('Update Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildProfileField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: context.textSec)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.surfaceC,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: context.textSec),
              SizedBox(width: 12),
              Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
