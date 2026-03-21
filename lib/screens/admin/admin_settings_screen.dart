import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _emailNotifications = true;
  bool _smsAlerts = false;
  bool _autoAssign = true;
  bool _requireMfa = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 900;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Settings', 
                style: isMobile 
                  ? Theme.of(context).textTheme.titleLarge 
                  : Theme.of(context).textTheme.headlineMedium
              ),
              SizedBox(height: 4),
              Text('Manage platform preferences and security configurations.', style: TextStyle(color: context.textSec)),
              SizedBox(height: 32),
              
              if (isMobile) ...[
                _buildSection('Security & Access', _buildSecuritySettings()),
                SizedBox(height: 24),
                _buildSection('Notifications', _buildNotificationSettings()),
                SizedBox(height: 24),
                _buildSection('Workflow Automations', _buildWorkflowSettings()),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1, 
                      child: Column(
                        children: [
                          _buildSection('Security & Access', _buildSecuritySettings()),
                          SizedBox(height: 32),
                          _buildSection('Workflow Automations', _buildWorkflowSettings()),
                        ],
                      ),
                    ),
                    SizedBox(width: 32),
                    Expanded(
                      flex: 1, 
                      child: _buildSection('Notifications', _buildNotificationSettings()),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      decoration: context.glassDecoration.copyWith(
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Require Multi-Factor Auth (MFA)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          subtitle: Text('Enforce 2FA for all administrative accounts.', style: TextStyle(fontSize: 12, color: context.textSec)),
          value: _requireMfa,
          activeTrackColor: AppTheme.primaryColor,
          onChanged: (val) => setState(() => _requireMfa = val),
        ),
        Divider(height: 32),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Change Password', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          subtitle: Text('Last changed 45 days ago.', style: TextStyle(fontSize: 12, color: context.textSec)),
          trailing: Icon(LucideIcons.chevronRight, size: 18),
          onTap: () {},
        ),
        Divider(height: 32),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Active Sessions', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          subtitle: Text('Manage devices currently logged into this account.', style: TextStyle(fontSize: 12, color: context.textSec)),
          trailing: Icon(LucideIcons.chevronRight, size: 18),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Email Notifications', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          subtitle: Text('Receive daily summaries of pending applications.', style: TextStyle(fontSize: 12, color: context.textSec)),
          value: _emailNotifications,
          activeTrackColor: AppTheme.primaryColor,
          onChanged: (val) => setState(() => _emailNotifications = val),
        ),
        Divider(height: 32),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('SMS Critical Alerts', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          subtitle: Text('Get texted immediately if AI detects high-risk fraud.', style: TextStyle(fontSize: 12, color: context.textSec)),
          value: _smsAlerts,
          activeTrackColor: AppTheme.primaryColor,
          onChanged: (val) => setState(() => _smsAlerts = val),
        ),
      ],
    );
  }

  Widget _buildWorkflowSettings() {
    return Column(
      children: [
        ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeProvider().themeNotifier,
          builder: (context, theme, _) {
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Dark Mode Interface', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              subtitle: Text('Switch between Light and Slate Dark mode.', style: TextStyle(fontSize: 12, color: context.textSec)),
              value: theme == ThemeMode.dark,
              activeTrackColor: AppTheme.primaryColor,
              onChanged: (val) => ThemeProvider().toggleTheme(),
            );
          },
        ),
        Divider(height: 32),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Auto-Assign Reviewers', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          subtitle: Text('Automatically round-robin incoming tasks to available admins.', style: TextStyle(fontSize: 12, color: context.textSec)),
          value: _autoAssign,
          activeTrackColor: AppTheme.primaryColor,
          onChanged: (val) => setState(() => _autoAssign = val),
        ),
        Divider(height: 32),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Machine Learning Thresholds', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          subtitle: Text('Adjust confidence limits for automatic AI rejection.', style: TextStyle(fontSize: 12, color: context.textSec)),
          trailing: Icon(LucideIcons.sliders, size: 18, color: AppTheme.primaryColor),
          onTap: () {},
        ),
      ],
    );
  }
}
