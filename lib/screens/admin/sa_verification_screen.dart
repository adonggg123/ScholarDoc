import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

class SaVerificationScreen extends StatelessWidget {
  const SaVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SA Number Verification', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          const Text('Verify accuracy of submitted Savings Account numbers.'),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildVerificationTable(context)),
                const SizedBox(width: 32),
                Expanded(flex: 1, child: _buildVerificationPanel(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationTable(BuildContext context) {
    return Card(
      child: ListView.separated(
        itemCount: 8,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(child: Icon(LucideIcons.user)),
            title: const Text('Juan De La Cruz', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('SA: 1234-5678-9012'),
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildVerificationPanel(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 40, child: Icon(LucideIcons.user, size: 40)),
                  SizedBox(height: 16),
                  Text('Juan De La Cruz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('BSCS - 3rd Year', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            _dataField('Student ID', '2021-00421'),
            const SizedBox(height: 16),
            _dataField('Submitted SA Number', '1234-5678-9012'),
            const SizedBox(height: 16),
            _dataField('Bank Branch', 'Main University Branch'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                child: const Text('Verify and Approve'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error, side: const BorderSide(color: AppTheme.error)),
                child: const Text('Flag for Correction'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
