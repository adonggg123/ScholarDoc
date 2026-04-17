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
  DateTime? _selectedDate;
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
            
            // Apply Date Filter
            final now = DateTime.now();
            if (_selectedDate == null) {
              // Default: 24h filter
              docs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = data['timestamp'];
                if (timestamp is Timestamp) {
                  final dateTime = timestamp.toDate();
                  return now.difference(dateTime).inHours < 24;
                }
                return true; // Keep old/missing timestamps for now
              }).toList();
            } else {
              // Explicit Date Filter: matching the same calendar day
              docs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = data['timestamp'];
                if (timestamp is Timestamp) {
                  final dateTime = timestamp.toDate();
                  return dateTime.year == _selectedDate!.year &&
                         dateTime.month == _selectedDate!.month &&
                         dateTime.day == _selectedDate!.day;
                }
                return false;
              }).toList();
            }

            // Apply Role Filter
            if (_roleFilter != 'All') {
              docs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String role = data['role'] ?? 'Admin';
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Activity Log (Audit Trail)', 
                              style: isMobile 
                                ? Theme.of(context).textTheme.titleLarge 
                                : Theme.of(context).textTheme.headlineMedium
                            ),
                          ],
                        ),
                      ),
                      Tooltip(
                        message: 'Refresh logs',
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _auditStream = _authService.getAuditLogsStream();
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Activity logs refreshed.'), behavior: SnackBarBehavior.floating, width: 280),
                              );
                            }
                          },
                          icon: Icon(LucideIcons.refreshCw, size: 18, color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.filter, size: 18, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Filter Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              if (_selectedDate == null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'Showing last 24h',
                    style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Field and Date Picker
          Row(
            children: [
              Expanded(
                child: TextField(
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
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2025),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppTheme.primaryColor,
                            onPrimary: Colors.white,
                            surface: context.surfaceC,
                            onSurface: context.textPri,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedDate != null ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.calendar,
                    size: 20,
                    color: _selectedDate != null ? Colors.white : context.textSec,
                  ),
                ),
              ),
              if (_selectedDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() => _selectedDate = null),
                  icon: const Icon(LucideIcons.x, size: 18),
                  tooltip: 'Clear Date Filter',
                )
              ],
            ],
          ),
          const SizedBox(height: 16),
          // Role Chips
          Row(
            children: [
              const Text('Role:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Wrap(
                spacing: 8,
                children: ['All', 'Admin', 'Student'].map<Widget>((role) {
                  final isSelected = _roleFilter == role;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(role),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _roleFilter = role);
                      },
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : context.textPri,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12,
                      ),
                      backgroundColor: context.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      ),
                      showCheckmark: false,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      } else if (diff.inMinutes < 60) timeStr = '${diff.inMinutes}m ago';
      else if (diff.inHours < 24) timeStr = '${diff.inHours}h ago';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 8),
        leading: isMobile ? null : (role == 'Student' && studentId != 'N/A')
          ? FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('students').where('studentId', isEqualTo: studentId).limit(1).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final studentData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  final String? photoUrl = studentData['profilePictureUrl'] as String?;
                  if (photoUrl != null && photoUrl.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFBC02D), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(photoUrl),
                      ),
                    );
                  }
                }
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(roleIcon, color: roleColor, size: 22),
                );
              },
            )
          : Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(roleIcon, color: roleColor, size: 22),
            ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(color: context.textPri, fontSize: 13, height: 1.5),
            children: [
              TextSpan(text: userName, style: const TextStyle(fontWeight: FontWeight.w800)),
              TextSpan(
                text: ' • $role ',
                style: TextStyle(fontSize: 11, color: roleColor, fontWeight: FontWeight.w900, letterSpacing: 0.5)
              ),
              TextSpan(text: '\n$action', style: TextStyle(fontWeight: FontWeight.w500, color: context.textPri)),
              if (studentId != 'N/A') ...[
                TextSpan(text: ' [ID: $studentId]', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor, fontSize: 11)),
              ],
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(LucideIcons.clock, size: 12, color: context.textSec.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Text(timeStr, style: TextStyle(fontSize: 11, color: context.textSec, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              Icon(LucideIcons.monitor, size: 12, color: context.textSec.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Text(platform, style: TextStyle(fontSize: 11, color: context.textSec, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
