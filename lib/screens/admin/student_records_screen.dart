import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

class StudentRecordsScreen extends StatelessWidget {
  const StudentRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Student Records', style: Theme.of(context).textTheme.headlineLarge),
              Row(
                children: [
                  _buildSemesterDropdown(),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.userPlus),
                    label: const Text('Add Student'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildFilterBar(),
          const SizedBox(height: 24),
          Expanded(child: _buildStudentTable(context)),
        ],
      ),
    );
  }

  Widget _buildSemesterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Row(
        children: [
          Text('AY 2023-2024, 1st Sem', style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(width: 8),
          Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name, ID, or SA number...',
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildDropdownFilter('Status'),
            const SizedBox(width: 16),
            _buildDropdownFilter('Course'),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(LucideIcons.slidersHorizontal),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, size: 20, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildStudentTable(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ID Number', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Course & Year', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('SA Number', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(10, (index) => _buildDataRow(context, index)),
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
      DataCell(Text(names[index % 5])),
      DataCell(Text('2021-00${index + 10}')),
      DataCell(Text(courses[index % 5])),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors[index % 4].withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(statuses[index % 4], style: TextStyle(color: colors[index % 4], fontSize: 12, fontWeight: FontWeight.bold)),
      )),
      DataCell(const Text('1234-5678-XXXX')),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(LucideIcons.eye, size: 18, color: AppTheme.primaryColor), onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.checkSquare, size: 18, color: AppTheme.success), onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.xSquare, size: 18, color: AppTheme.error), onPressed: () {}),
        ],
      )),
    ]);
  }
}
