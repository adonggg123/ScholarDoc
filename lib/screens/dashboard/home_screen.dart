import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../submissions/upload_workflow_screen.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/announcement_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final AnnouncementService _announcementService = AnnouncementService();

  Map<String, dynamic>? _profileData;
  List<Announcement> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      final doc = await _authService.getStudentProfile(uid);
      if (doc.exists && mounted) {
        setState(() {
          _profileData = doc.data() as Map<String, dynamic>;
        });
      }
    }

    _announcementService.getActiveAnnouncements().listen(
      (list) {
        if (mounted) {
          setState(() {
            _announcements = list;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        debugPrint('Error loading announcements: $error');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );

    // Fallback timer to disable loading after 5 seconds if no announcements emit
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            pinned: true,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: const Color(0xFF0F3260),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final topPadding = MediaQuery.of(context).padding.top;
                final fullyExpandedHeight = 180.0;
                final fullyCollapsedHeight = topPadding + kToolbarHeight;

                // Calculate percentage of expansion (1.0 = fully expanded, 0.0 = collapsed)
                final double expandRatio =
                    ((constraints.maxHeight - fullyCollapsedHeight) /
                            (fullyExpandedHeight - fullyCollapsedHeight))
                        .clamp(0.0, 1.0);

                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.scale(
                        scale: 1.15,
                        child: Image.asset(
                          'assets/campus_bg.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xCC0F3260), Color(0xDD1A4F9E)],
                          ),
                        ),
                      ),
                      // Top: Logo + app name bar
                      Positioned(
                        top: -5,
                        left: -10,
                        right: 0,
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Opacity(
                              opacity: expandRatio < 0.3 ? 0.0 : expandRatio,
                              child: Row(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 45,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/app_logo.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 0),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Color(0xFFFBC02D),
                                          ],
                                        ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: const Text(
                                      'ScholarDoc',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom:
                            16 +
                            (expandRatio *
                                0), // Moves up slightly when expanded
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize:
                                        12 + (expandRatio * 4), // 12 -> 16
                                  ),
                                ),
                                SizedBox(
                                  height: 2 + (expandRatio * 2),
                                ), // 2 -> 4
                                Text(
                                  _profileData != null
                                      ? '${_profileData!['fullName']?.toString().split(' ').first}!'
                                      : 'Student!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        20 + (expandRatio * 8), // 20 -> 28
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (expandRatio > 0.5) ...[
                                  SizedBox(height: 8),
                                  _buildVerificationBadge(),
                                ],
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to profile tab - handled by parent nav
                              },
                              child: () {
                                final String? photoUrl =
                                    _profileData?['profilePictureUrl']
                                        as String?;
                                final double r = 20 + (expandRatio * 8);
                                final Widget avatar =
                                    (photoUrl != null && photoUrl.isNotEmpty)
                                    ? CircleAvatar(
                                        radius: r,
                                        backgroundColor: Colors.white24,
                                        backgroundImage: NetworkImage(photoUrl),
                                      )
                                    : CircleAvatar(
                                        radius: r,
                                        backgroundColor: Colors.white24,
                                        child: Icon(
                                          LucideIcons.user,
                                          color: Colors.white,
                                          size: r,
                                        ),
                                      );
                                // Gold border ring
                                return Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFBC02D),
                                      width: 2.5,
                                    ),
                                  ),
                                  child: avatar,
                                );
                              }(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildNotificationAlert(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Your Scholarship Status'),
                  const SizedBox(height: 14),
                  _buildStatusCard(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Submission Progress'),
                  const SizedBox(height: 14),
                  _buildProgressTracker(),
                  const SizedBox(height: 28),
                  _buildSectionHeader('Quick Actions'),
                  const SizedBox(height: 14),
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
                              MaterialPageRoute(
                                builder: (context) =>
                                    const UploadWorkflowScreen(),
                              ),
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
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Recent Updates'),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.accentColor,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_isLoading)
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                if (_announcements.isEmpty)
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No recent updates.',
                        style: TextStyle(color: context.textSec),
                      ),
                    ),
                  );

                final a = _announcements[index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: _buildAnnouncementWidget(context, a),
                );
              },
              childCount: _isLoading
                  ? 1
                  : (_announcements.isEmpty ? 1 : _announcements.length),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final String scholarshipName =
        _profileData?['scholarshipName'] ?? 'No Scholarship Assigned';
    final String status = _profileData?['status'] ?? 'Pending';
    final String? remarks = _profileData?['adminRemarks'];
    final String submittedDate =
        (_profileData?['submittedAt'] as Timestamp?)?.toDate().toString().split(
          ' ',
        )[0] ??
        'N/A';

    Color statusColor = AppTheme.warning;
    if (status == 'Approved') statusColor = AppTheme.success;
    if (status == 'Rejected') statusColor = AppTheme.error;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.premiumShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withValues(alpha: 0.03),
                statusColor.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scholarshipName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last activity on $submittedDate',
                          style: TextStyle(
                            color: context.textSec,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              if (remarks != null && remarks.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.messageSquare,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          remarks,
                          style: TextStyle(
                            color: context.textSec,
                            fontSize: 13,
                          ),
                        ),
                      ),
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

  Widget _buildVerificationBadge() {
    final status = _profileData?['status'] ?? 'Pending';
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    if (status == 'Approved' || status == 'Verified') {
      badgeColor = AppTheme.success;
      badgeIcon = LucideIcons.badgeCheck;
      badgeText = 'Verified Scholar';
    } else if (status == 'Rejected' || status == 'Needs Correction') {
      badgeColor = AppTheme.error;
      badgeIcon = LucideIcons.alertTriangle;
      badgeText = 'Needs Correction';
    } else {
      badgeColor = AppTheme.warning;
      badgeIcon = LucideIcons.hourglass;
      badgeText = 'Pending Approval';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTracker() {
    // Determine dynamic states
    bool hasProfile = _profileData != null;
    bool hasSA =
        (_profileData?['saNumber'] != null &&
        _profileData!['saNumber'].toString().isNotEmpty);
    bool hasID = _profileData?['idFrontUrl'] != null;

    // Dynamic logic based on scholarship type
    String scholarshipType = _profileData?['scholarshipName'] ?? 'Unassigned';
    bool requiresIdOnly =
        scholarshipType == 'TES' || scholarshipType == 'STUFAP';
    // Let's assume TDP or DBP require a Billing statement (we simulate a DB check here)
    bool hasBilling = _profileData?['billingUrl'] != null;

    List<Map<String, dynamic>> steps = [
      {'label': 'Profile', 'done': hasProfile},
      {'label': 'Disbursement', 'done': hasSA},
      {'label': 'Validation ID', 'done': hasID},
    ];

    if (!requiresIdOnly) {
      steps.add({'label': 'Billing Stmt', 'done': hasBilling});
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: steps.map((step) {
          bool done = step['done'];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.surfaceC,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: done ? AppTheme.success : context.crispBorder,
              ),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                Icon(
                  done ? LucideIcons.checkCircle2 : LucideIcons.circle,
                  color: done
                      ? AppTheme.success
                      : context.textSec.withValues(alpha: 0.5),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  step['label'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: done ? AppTheme.success : context.textSec,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationAlert() {
    final status = _profileData?['status'];
    if (status != 'Rejected' && status != 'Needs Correction') {
      // Also check if any critical doc is missing
      if (_profileData != null && _profileData!['idFrontUrl'] == null) {
        return _buildAlertCard(
          'Missing Required Documents',
          'Your Validation ID has not been submitted. Please upload it to proceed with processing.',
          AppTheme.warning,
        );
      }
      return const SizedBox.shrink();
    }

    return _buildAlertCard(
      'Action Required',
      _profileData?['adminRemarks'] ??
          'One or more of your documents were rejected. Please review your submission.',
      AppTheme.error,
    );
  }

  Widget _buildAlertCard(String title, String message, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.alertCircle, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildActionBtn(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: context.surfaceC,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementWidget(BuildContext context, Announcement a) {
    Color typeColor = Colors.blue;
    IconData typeIcon = LucideIcons.info;
    if (a.type == 'Deadline') {
      typeColor = AppTheme.error;
      typeIcon = LucideIcons.calendarClock;
    } else if (a.type == 'Update') {
      typeColor = AppTheme.success;
      typeIcon = LucideIcons.refreshCw;
    }

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.crispBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: typeColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(typeIcon, color: typeColor, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.content,
                            style: TextStyle(
                              color: context.textSec,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.chevronRight,
                      color: context.textSec.withValues(alpha: 0.5),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F3260),
          ),
        ),
      ],
    );
  }
}
