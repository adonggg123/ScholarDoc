import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/ml_service.dart';
import '../../services/auth_service.dart';
import '../../services/audit_service.dart';
import '../auth/welcome_screen.dart';
import 'student_activity_log_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _saController = TextEditingController(text: '1234-5678-9012');
  final AuthService _authService = AuthService();
  final MLService _mlService = MLService();
  final AuditService _auditService = AuditService();
  
  Map<String, dynamic>? _profileData;
  bool _isProfileLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      final doc = await _authService.getStudentProfile(uid);
      if (doc.exists) {
        setState(() {
          _profileData = doc.data() as Map<String, dynamic>;
          _isProfileLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              // Execute logout
              await _authService.logout();
              
              if (context.mounted) {
                // Clear entire navigation stack and push to Welcome
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            icon: const Icon(LucideIcons.logOut, color: AppTheme.error),
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
            if (_isProfileLoading)
              CircularProgressIndicator()
            else ...[
              Text(
                _profileData?['fullName'] ?? 'Student Name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_profileData?['course'] ?? 'Course'} - ${_profileData?['year'] ?? 'Year Level'}',
                style: TextStyle(color: context.textSec),
              ),
            ],
            SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Personal Information'),
                  SizedBox(height: 16),
                  _buildProfileField('Full Name', _profileData?['fullName'] ?? 'Loading...', LucideIcons.user),
                  SizedBox(height: 16),
                  _buildProfileField('Student ID', _profileData?['studentId'] ?? 'Loading...', LucideIcons.badgeCheck),
                  SizedBox(height: 16),
                  _buildProfileField('Email', _profileData?['email'] ?? 'Loading...', LucideIcons.mail),
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Note: In production, there would be an update to Firestore here for the SA number.

                          // Log the profile update activity
                          await _auditService.logActivity(
                            action: 'Updated Profile (SA number)',
                            userName: _profileData?['fullName'] ?? 'Student',
                            role: 'Student',
                            studentId: _profileData?['studentId'],
                          );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated successfully')),
                          );
                        }
                      },
                      child: Text('Update Profile'),
                    ),
                  ),
                  SizedBox(height: 32),
                  _buildSectionTitle('Security & Privacy'),
                  SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentActivityLogScreen(),
                        ),
                      );
                    },
                    icon: Icon(LucideIcons.history, size: 18),
                    label: Text('View Account Activity'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      alignment: Alignment.centerLeft,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
