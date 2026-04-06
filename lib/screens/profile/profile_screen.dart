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
  final _saController = TextEditingController();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _sectionController = TextEditingController();
  final _emailController = TextEditingController();
  
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
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _profileData = data;
          _nameController.text = data['fullName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _contactController.text = data['contactNumber'] ?? '';
          _sectionController.text = data['section'] ?? '';
          _saController.text = data['saNumber'] ?? '1234-5678-9012';
          _isProfileLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _saController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _sectionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await _authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            icon: const Icon(LucideIcons.logOut, color: Colors.white70),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Header with Gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.primaryColor, Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: Icon(LucideIcons.user, size: 60, color: AppTheme.primaryColor),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.camera, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_isProfileLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else ...[
                    Text(
                      _profileData?['fullName'] ?? 'Student Name',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_profileData?['course'] ?? 'Course'} • ${_profileData?['year'] ?? 'Year'}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    context,
                    'Personal Information',
                    LucideIcons.user,
                    [
                      _buildEditableField('Full Name', _nameController, LucideIcons.user),
                      const SizedBox(height: 20),
                      _buildEditableField('Contact Number', _contactController, LucideIcons.phone),
                      const SizedBox(height: 20),
                      _buildEditableField('Section', _sectionController, LucideIcons.layers),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    context,
                    'Academic & Program',
                    LucideIcons.graduationCap,
                    [
                      _buildProfileField('Scholarship Program', _profileData?['scholarshipName'] ?? 'Not Assigned', LucideIcons.star),
                      const SizedBox(height: 20),
                      _buildProfileField('Student ID', _profileData?['studentId'] ?? '...', LucideIcons.badgeCheck),
                      const SizedBox(height: 20),
                      _buildProfileField('Email Address', _profileData?['email'] ?? '...', LucideIcons.mail),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    context,
                    'App Preferences',
                    LucideIcons.settings,
                    [
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeProvider().themeNotifier,
                        builder: (context, theme, _) {
                          return SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            subtitle: Text('Switch between Light and Slate Dark mode.', style: TextStyle(fontSize: 12, color: context.textSec)),
                            value: theme == ThemeMode.dark,
                            activeTrackColor: AppTheme.primaryColor,
                            onChanged: (val) => ThemeProvider().toggleTheme(),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    context,
                    'Banking Details',
                    LucideIcons.landmark,
                    [
                      Text(
                        'Provide your Savings Account (SA) number for scholarship fund disbursement.',
                        style: TextStyle(fontSize: 13, color: context.textSec, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _saController,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'SA Number',
                          hintText: 'xxxx-xxxx-xxxx',
                          prefixIcon: const Icon(LucideIcons.creditCard),
                          fillColor: context.bgC,
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
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, Color(0xFF2563EB)],
                      ),
                      boxShadow: AppTheme.premiumShadow,
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final uid = _authService.currentUser?.uid;
                          if (uid != null) {
                            try {
                              Map<String, dynamic> updates = {
                                'fullName': _nameController.text.trim(),
                                'contactNumber': _contactController.text.trim(),
                                'section': _sectionController.text.trim(),
                                'saNumber': _saController.text.trim(),
                              };
                              
                              await _authService.updateStudentProfile(uid, updates);
                              
                              await _auditService.logActivity(
                                action: 'Updated Profile (SA number)',
                                userName: _nameController.text.trim(),
                                role: 'Student',
                                studentId: _profileData?['studentId'],
                              );
                              
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated successfully'),
                                  backgroundColor: AppTheme.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              _loadProfile();
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Security & Privacy'),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentActivityLogScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.surfaceC,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.crispBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: context.textSec.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(LucideIcons.history, size: 20, color: context.textSec),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'View Account Activity',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ),
                          Icon(LucideIcons.chevronRight, size: 18, color: context.textSec.withValues(alpha: 0.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: context.crispBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: context.textSec, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.bgC.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.crispBorder),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: context.textSec),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: context.textSec, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            fillColor: context.bgC.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Field cannot be empty' : null,
        ),
      ],
    );
  }
}
