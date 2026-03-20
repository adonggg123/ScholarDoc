import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../services/ml_service.dart';

class SaVerificationScreen extends StatelessWidget {
  const SaVerificationScreen({super.key});

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
                'SA Number Verification', 
                style: isMobile 
                  ? Theme.of(context).textTheme.titleLarge 
                  : Theme.of(context).textTheme.headlineMedium
              ),
              const SizedBox(height: 4),
              const Text('Verify accuracy of submitted Savings Account numbers.'),
              const SizedBox(height: 32),
              if (isMobile) ...[
                _buildVerificationTable(context, isMobile),
                const SizedBox(height: 24),
                _buildVerificationPanel(context, isMobile),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildVerificationTable(context, isMobile)),
                    const SizedBox(width: 32),
                    Expanded(flex: 1, child: _buildVerificationPanel(context, isMobile)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerificationTable(BuildContext context, bool isMobile) {
    return Container(
      decoration: AppTheme.glassDecoration(opacity: 0.6, boxShadow: AppTheme.softShadow),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.05),
              child: const Icon(LucideIcons.user, size: 20, color: AppTheme.primaryColor),
            ),
            title: const Text('Juan De La Cruz', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('SA: 1234-5678-9012', style: TextStyle(fontSize: 12)),
            trailing: const Icon(LucideIcons.chevronRight, size: 18),
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildVerificationPanel(BuildContext context, bool isMobile) {
    final ml = MLService();
    final String mockSaNumber = '1234-5678-9012';
    final aiCheck = ml.detectSASuspiciousPattern(mockSaNumber);

    return Container(
      decoration: AppTheme.glassDecoration(opacity: 0.6, boxShadow: AppTheme.softShadow),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 32, 
                      backgroundColor: AppTheme.secondaryColor,
                      child: Icon(LucideIcons.user, size: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Juan De La Cruz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  const Text('BSCS - 3rd Year', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            _dataField('Student ID', '2021-00421'),
            const SizedBox(height: 16),
            _dataField('Submitted SA Number', mockSaNumber),
            const SizedBox(height: 8),
            _buildAIBadge(aiCheck),
            const SizedBox(height: 16),
            _dataField('Bank Branch', 'Main University Branch'),
            const SizedBox(height: 8),
            _buildDuplicateBadge(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success, 
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Verify and Approve', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error, 
                  side: const BorderSide(color: AppTheme.error, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Flag for Correction', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

  Widget _buildAIBadge(Map<String, dynamic> aiCheck) {
    final bool isSuspicious = aiCheck['isSuspicious'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isSuspicious ? AppTheme.warning : AppTheme.success).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: (isSuspicious ? AppTheme.warning : AppTheme.success).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.bot, size: 14, color: isSuspicious ? AppTheme.warning : AppTheme.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI Score: ${aiCheck['confidence']}% - ${aiCheck['message']}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSuspicious ? AppTheme.warning : AppTheme.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.fileCheck2, size: 14, color: AppTheme.success),
          SizedBox(width: 8),
          Text(
            'Duplicate Hash Network Check: PASSED',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.success),
          ),
        ],
      ),
    );
  }
}
