import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'All'; // 'All', 'Admin', 'Student'
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
    return LayoutBuilder(
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

            // Filter Documents
            List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
            
            // Apply Role Filter
            if (_roleFilter != 'All') {
              docs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String role = data['role'] ?? 'Admin'; // Default to admin for old logs
                return role == _roleFilter;
              }).toList();
            }

            // Apply Search Filter
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              docs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String action = (data['action'] ?? '').toLowerCase();
                final String name = (data['adminName'] ?? '').toLowerCase();
                final String studentId = (data['studentId'] ?? '').toLowerCase();
                return action.contains(query) || name.contains(query) || studentId.contains(query);
              }).toList();
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Log (Audit Trail)', 
                    style: isMobile 
                      ? Theme.of(context).textTheme.titleLarge 
                      : Theme.of(context).textTheme.headlineMedium
                  ),
                  const SizedBox(height: 4),
                  const Text('Track all administrative actions and system updates for transparency.'),
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
              Icon(LucideIcons.filter, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text('Filter Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search by user, action, or Student ID...',
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
          const SizedBox(height: 16),
          // Role Chips
          Row(
            children: [
              const Text('Role:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Wrap(
                spacing: 8,
                children: ['All', 'Admin', 'Student'].map((role) {
                  final isSelected = _roleFilter == role;
                  return ChoiceChip(
                    label: Text(role),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _roleFilter = role);
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(BuildContext context, Map<String, dynamic> data, bool isMobile) {
    final String action = data['action'] ?? 'Performed Action';
    final String userName = data['adminName'] ?? 'Unknown User';
    final String role = data['role'] ?? 'Admin';
    final String studentId = data['studentId'] ?? 'N/A';
    final String platform = data['ipAddress'] ?? 'Unknown Device';
    final dynamic timestamp = data['timestamp'];
    
    // Select styling based on role
    final bool isAdmin = role == 'Admin';
    final Color roleColor = isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor;
    final IconData roleIcon = isAdmin ? LucideIcons.shieldCheck : LucideIcons.graduationCap;

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
          color: roleColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(roleIcon, color: roleColor, size: 18),
      ),
      title: RichText(
        text: TextSpan(
          style: TextStyle(color: context.textPri, fontSize: 14),
          children: [
            TextSpan(text: '$userName ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: ' ($role) ',
              style: TextStyle(fontSize: 11, color: roleColor, fontWeight: FontWeight.bold)
            ),
            TextSpan(text: action),
            if (studentId != 'N/A') ...[
              const TextSpan(text: ' for Student ID: '),
              TextSpan(text: studentId, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
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
                Text('Platform: $platform', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
