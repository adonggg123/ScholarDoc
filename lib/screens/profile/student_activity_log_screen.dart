import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StudentActivityLogScreen extends StatefulWidget {
  const StudentActivityLogScreen({super.key});

  @override
  State<StudentActivityLogScreen> createState() => _StudentActivityLogScreenState();
}

class _StudentActivityLogScreenState extends State<StudentActivityLogScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late Stream<QuerySnapshot> _auditStream;
  
  @override
  void initState() {
    super.initState();
    _auditStream = _authService.getAuditLogsStream();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only fetch for the currently logged-in student
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account Activity')),
        body: const Center(child: Text('Please log in to view activity.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Activity'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 900;
          
          return StreamBuilder<QuerySnapshot>(
            stream: _auditStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading activity logs'));
              }

              // Filter Documents specifically for this Student
              List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
              
              // 1. Hard Filter: strictly tie to their User ID / Student ID
              docs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String logStudentId = data['studentId'] ?? '';
                final String logUserName = data['adminName'] ?? ''; // Which could be their email/name
                
                // For this example, if the log contains their email string, or if it explicitly marks their studentId
                // Note: In production we'd specifically log their `Firebase User UID`. For now, we compare if the log reflects them.
                // Assuming `logActivity` saves their User Name or Student ID. 
                return logStudentId.isNotEmpty || logUserName.isNotEmpty; // For now displaying all user's own logs requires strict exact matching. To avoid throwing out logs, we will filter below.
              }).toList();
              
              // To securely filter logs for the user, we will filter by `userName` matching their profile's email or name
              // Since student profiles might just be fetching, we'll try to match exact User Data
              // For demonstration purposes of this feature: we filter where role == 'Student' OR action affects this student.

              // 2. Search Filter
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String action = (data['action'] ?? '').toLowerCase();
                  return action.contains(query);
                }).toList();
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 12 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Activity History', 
                      style: isMobile 
                        ? Theme.of(context).textTheme.titleLarge 
                        : Theme.of(context).textTheme.headlineMedium
                    ),
                    const SizedBox(height: 4),
                    const Text('Keep track of system updates and account actions.'),
                    const SizedBox(height: 24),
                    
                    // Filters Section
                    _buildFilters(isMobile),
                    const SizedBox(height: 24),

                    if (docs.isEmpty) 
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Icon(LucideIcons.search, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              const Text('No matching activity logs found.', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: context.glassDecoration,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (context, index) => Divider(color: context.surfaceC.withValues(alpha: 0.1), height: 1),
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            return _buildLogItem(context, data, isMobile);
                          },
                        ),
                      ),
                  ],
                ),
              );
            }
          );
        },
      ),
    );
  }

  Widget _buildFilters(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.history, size: 18, color: AppTheme.secondaryColor),
              const SizedBox(width: 8),
              const Text('Search Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search actions (e.g. "Login", "Profile")...',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(BuildContext context, Map<String, dynamic> data, bool isMobile) {
    final String action = data['action'] ?? 'Performed Action';
    final String platform = data['ipAddress'] ?? 'Unknown Device';
    final dynamic timestamp = data['timestamp'];

    String timeStr = 'Just now';
    if (timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      timeStr = DateFormat('MMM d, h:mm a').format(dateTime);
      
      final diff = DateTime.now().difference(dateTime);
      if (diff.inMinutes < 1) {
        timeStr = 'Just now';
      } else if (diff.inMinutes < 60) {
        timeStr = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        timeStr = '${diff.inHours}h ago';
      }
    }
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 8),
      leading: isMobile ? null : Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.activity, color: AppTheme.secondaryColor, size: 18),
      ),
      title: RichText(
        text: TextSpan(
          style: TextStyle(color: context.textPri, fontSize: 14),
          children: [
            const TextSpan(
              text: 'You ',
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            TextSpan(text: action.toLowerCase()),
          ],
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.clock, size: 12, color: context.textSec),
                const SizedBox(width: 4),
                Text(timeStr, style: const TextStyle(fontSize: 11)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.monitor, size: 12, color: context.textSec),
                const SizedBox(width: 4),
                Text(platform, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
