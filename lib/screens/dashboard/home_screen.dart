import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../submissions/upload_workflow_screen.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final String? uid = authService.currentUser?.uid;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: context.bgC,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: FutureBuilder<DocumentSnapshot>(
                future: uid != null ? authService.getStudentProfile(uid) : null,
                builder: (context, snapshot) {
                  String displayName = 'Student';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    displayName = data['fullName']?.toString().split(' ').first ?? 'Student';
                  }
                  return Text(
                    'Hello, $displayName!',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 24,
                    ),
                  );
                },
              ),
              centerTitle: false,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Scholarship Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16),
                  _buildStatusCard(context),
                  SizedBox(height: 32),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionBtn(
                          context,
                          'Upload Docs',
                          LucideIcons.uploadCloud,
                          AppTheme.primaryColor,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UploadWorkflowScreen()),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildActionBtn(
                          context,
                          'View History',
                          LucideIcons.history,
                          AppTheme.secondaryColor,
                          () {
                            // Navigate to history
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Recent Updates',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: _buildUpdateItem(context, index),
                );
              },
              childCount: 3,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.05),
              AppTheme.primaryColor.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TES Scholarship',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Academic Year 2023-2024',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pending Review',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.6,
                backgroundColor: Colors.grey.shade200,
                color: AppTheme.primaryColor,
                minHeight: 8,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '3 of 5 documents verified',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '60%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateItem(BuildContext context, int index) {
    final titles = [
      'Document Approved',
      'Resubmission Required',
      'New Guidelines Posted'
    ];
    final subtitles = [
      'Your Birth Certificate has been verified.',
      'Signature missing on Billing Record.',
      'Please check updated submission requirements.'
    ];
    final icons = [
      LucideIcons.checkCircle2,
      LucideIcons.alertCircle,
      LucideIcons.info
    ];
    final colors = [AppTheme.success, AppTheme.error, AppTheme.secondaryColor];

    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors[index].withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icons[index], color: colors[index], size: 24),
        ),
        title: Text(
          titles[index],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitles[index]),
        trailing: Icon(Icons.chevron_right, color: context.textSec),
      ),
    );
  }
}
