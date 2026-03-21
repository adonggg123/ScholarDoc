import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';

class StudentRecordsScreen extends StatelessWidget {
  const StudentRecordsScreen({super.key});

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
          child: DataTable(
            horizontalMargin: 20,
            columnSpacing: 24,
            headingRowHeight: 52,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 60,
            headingRowColor: WidgetStateProperty.all(AppTheme.primaryColor.withValues(alpha: 0.02)),
            columns: [
              DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPri))),
              DataColumn(label: Text('ID Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPri))),
              DataColumn(label: Text('Course & Year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPri))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPri))),
              DataColumn(label: Text('SA Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPri))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPri))),
            ],
            rows: List.generate(10, (index) => _buildDataRow(context, index)),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, int index) {
    final names = ['Juan De La Cruz', 'Maria Santos', 'Pedro Penduko', 'Liza Soberano', 'Enrique Gil'];
    final courses = ['BSCS - 3', 'BSIT - 2', 'BSECE - 4', 'BSME - 1', 'BSCE - 3'];
    final statuses = ['Pending', 'Approved', 'Rejected', 'Under Review'];
    final colors = [AppTheme.warning, AppTheme.success, AppTheme.error, AppTheme.secondaryColor];

    return DataRow(cells: [
      DataCell(Text(names[index % 5], style: TextStyle(fontSize: 13))),
      DataCell(Text('2021-00${index + 10}', style: TextStyle(fontSize: 13))),
      DataCell(Text(courses[index % 5], style: TextStyle(fontSize: 13))),
      DataCell(Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colors[index % 4].withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(statuses[index % 4], style: TextStyle(color: colors[index % 4], fontSize: 11, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text('1234-5678-XXXX', style: TextStyle(fontSize: 13))),
      DataCell(Row(
        children: [
          IconButton(icon: Icon(LucideIcons.eye, size: 16, color: AppTheme.primaryColor), onPressed: () {}),
          IconButton(icon: Icon(LucideIcons.checkSquare, size: 16, color: AppTheme.success), onPressed: () {}),
          IconButton(icon: Icon(LucideIcons.xSquare, size: 16, color: AppTheme.error), onPressed: () {}),
        ],
      )),
    ]);
  }
}
