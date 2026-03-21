import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';

import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRecordsScreen extends StatefulWidget {
  const StudentRecordsScreen({super.key});

  @override
  State<StudentRecordsScreen> createState() => _StudentRecordsScreenState();
}

class _StudentRecordsScreenState extends State<StudentRecordsScreen> {
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  
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
              _buildHeader(context, isMobile),
              SizedBox(height: 32),
              _buildFilterBar(context, isMobile),
              SizedBox(height: 24),
              _buildStudentTable(context, isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student Records', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSemesterDropdown(context)),
              SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 12)),
                  child: Icon(LucideIcons.userPlus, size: 18),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Student Records', style: Theme.of(context).textTheme.headlineMedium),
        Row(
          children: [
            _buildSemesterDropdown(context),
            SizedBox(width: 12),
            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(LucideIcons.userPlus, size: 18),
                label: Text('Add Student', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSemesterDropdown(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text('AY 2023-2024, 1st Sem', 
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_drop_down, color: context.textSec, size: 18),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(LucideIcons.search, size: 20),
                  filled: true,
                  fillColor: context.bgC,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDropdownFilter(context, 'Status')),
                  SizedBox(width: 12),
                  Expanded(child: _buildDropdownFilter(context, 'Course')),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(12),
      decoration: context.glassDecoration,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search by name, ID, or SA number...',
                  prefixIcon: Icon(LucideIcons.search, size: 16, color: AppTheme.primaryColor),
                  filled: true,
                  fillColor: context.bgC.withValues(alpha: 0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
            ),
          ),
          SizedBox(width: 12),
          _buildDropdownFilter(context, 'Status'),
          SizedBox(width: 12),
          _buildDropdownFilter(context, 'Course'),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(LucideIcons.slidersHorizontal, size: 18, color: context.textSec),
            onPressed: () {},
            tooltip: 'Advanced Filters',
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceC.withValues(alpha: 0.5),
        border: Border.all(color: context.surfaceC.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: context.textSec, fontSize: 13, fontWeight: FontWeight.w500)),
          SizedBox(width: 6),
          Icon(Icons.arrow_drop_down, size: 18, color: context.textSec),
        ],
      ),
    );
  }

  Widget _buildStudentTable(BuildContext context, bool isMobile) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: context.glassDecoration,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: isMobile ? 800 : 1000),
          child: StreamBuilder<QuerySnapshot>(
            stream: _authService.getStudentsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Error: ${snapshot.error}')));
              
              // If we have no data yet (first load), show a stable loading indicator
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No students registered yet.')));

              return DataTable(
                horizontalMargin: 20,
                columnSpacing: 24,
                headingRowHeight: 52,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 60,
                headingRowColor: WidgetStateProperty.all(AppTheme.primaryColor.withValues(alpha: 0.02)),
                columns: [
                  DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.textPri, letterSpacing: 0.2))),
                  DataColumn(label: Text('ID Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.textPri, letterSpacing: 0.2))),
                  DataColumn(label: Text('Course & Year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.textPri, letterSpacing: 0.2))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.textPri, letterSpacing: 0.2))),
                  DataColumn(label: Text('SA Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.textPri, letterSpacing: 0.2))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.textPri, letterSpacing: 0.2))),
                ],
                rows: docs.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final doc = entry.value;
                  final data = doc.data() as Map<String, dynamic>;
                  final String name = data['fullName'] ?? 'N/A';
                  final String studentId = data['studentId'] ?? 'N/A';
                  final String course = data['course'] ?? 'N/A';
                  final String year = data['year'] ?? 'N/A';
                  final String status = data['status'] ?? 'Pending';
                  final String saNumber = data['familyDetails']?['saNumber'] ?? 'Not Provided';

                  if (_searchQuery.isNotEmpty && 
                      !name.toLowerCase().contains(_searchQuery) &&
                      !studentId.toLowerCase().contains(_searchQuery)) {
                    return null;
                  }

                  return _buildDataRow(context, name, studentId, '$course - $year', status, saNumber, isEven: index % 2 == 0);
                }).whereType<DataRow>().toList(),
              );
            }
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, String name, String studentId, String courseYear, String status, String saNumber, {bool isEven = false}) {
    Color statusColor = AppTheme.warning;
    if (status == 'Approved') statusColor = AppTheme.success;
    if (status == 'Rejected') statusColor = AppTheme.error;
    if (status == 'Under Review') statusColor = AppTheme.secondaryColor;

    return DataRow(
      color: WidgetStateProperty.all(isEven ? Colors.transparent : context.surfaceC.withValues(alpha: 0.1)),
      cells: [
        DataCell(Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        DataCell(Text(studentId, style: TextStyle(fontSize: 13, color: context.textSec))),
        DataCell(Text(courseYear, style: TextStyle(fontSize: 13, color: context.textSec))),
        DataCell(Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              SizedBox(width: 6),
              Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        )),
        DataCell(Text(saNumber, style: TextStyle(fontSize: 13, color: saNumber == 'Not Provided' ? Colors.grey : context.textPri))),
        DataCell(Row(
          children: [
            _buildActionIcon(LucideIcons.eye, AppTheme.primaryColor, () {}),
            SizedBox(width: 8),
            _buildActionIcon(LucideIcons.checkSquare, AppTheme.success, () {}),
            SizedBox(width: 8),
            _buildActionIcon(LucideIcons.xSquare, AppTheme.error, () {}),
          ],
        )),
      ]
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
