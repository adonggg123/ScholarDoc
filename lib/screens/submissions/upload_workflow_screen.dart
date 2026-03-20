import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UploadWorkflowScreen extends StatefulWidget {
  const UploadWorkflowScreen({super.key});

  @override
  State<UploadWorkflowScreen> createState() => _UploadWorkflowScreenState();
}

class _UploadWorkflowScreenState extends State<UploadWorkflowScreen> {
  int _currentStep = 0;

  bool _isUploading = false;
  String? _validationError;
  bool _isDuplicate = false;

  void _simulateUpload() async {
    setState(() {
      _isUploading = true;
      _validationError = null;
      _isDuplicate = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isUploading = false;
      // Simulated "Machine Learning" logic
      // In a real app, this would be an API call
      _validationError = "Document is slightly blurry but readable. ML confidence: 85%";
    });
  }

  void _simulateDuplicateCheck() async {
    setState(() {
      _isUploading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _isUploading = false;
      _isDuplicate = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Documents'),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Documents submitted successfully!'),
                backgroundColor: AppTheme.success,
              ),
            );
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          } else {
            Navigator.pop(context);
          }
        },
        steps: [
          Step(
            title: const Text('Guidelines'),
            content: _buildStep1(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Upload'),
            content: _buildStep2(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Review'),
            content: _buildStep3(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Required Documents for TES Submission:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        _bulletPoint('Validated School ID (Front & Back)'),
        _bulletPoint('Billing Record / Certificate of Registration'),
        _bulletPoint('Affidavit of Waiver (if required)'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.alertTriangle, color: AppTheme.warning),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ensure all documents are clear, readable, and in PDF or JPG format.',
                  style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle2, size: 16, color: AppTheme.success),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        if (_isUploading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Analyzing document using ML...', style: TextStyle(color: AppTheme.primaryColor)),
              ],
            ),
          ),
        _buildUploadCard(
          'Validated School ID',
          LucideIcons.image,
          onTap: _simulateUpload,
          feedback: _validationError,
        ),
        const SizedBox(height: 16),
        _buildUploadCard(
          'Billing Record',
          LucideIcons.fileText,
          onTap: _simulateDuplicateCheck,
          isDuplicate: _isDuplicate,
        ),
      ],
    );
  }

  Widget _buildUploadCard(
    String label,
    IconData icon, {
    required VoidCallback onTap,
    String? feedback,
    bool isDuplicate = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDuplicate ? AppTheme.error : (feedback != null ? AppTheme.success : Colors.grey.shade200),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('PNG, JPG, or PDF up to 5MB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onTap,
                  icon: const Icon(LucideIcons.upload, color: AppTheme.textSecondary),
                ),
              ],
            ),
            if (feedback != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.sparkles, size: 14, color: AppTheme.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feedback,
                        style: const TextStyle(fontSize: 11, color: AppTheme.success),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isDuplicate) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.copy, size: 14, color: AppTheme.error),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Warning: This document has already been uploaded previously.',
                        style: TextStyle(fontSize: 11, color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return const Column(
      children: [
        Icon(LucideIcons.checkCircle, size: 64, color: AppTheme.success),
        SizedBox(height: 16),
        Text(
          'Ready for Submission',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Please review your documents before final submission.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: Icon(LucideIcons.file),
            title: Text('SchoolID_Final.jpg'),
            trailing: Icon(LucideIcons.trash2, color: AppTheme.error),
          ),
        ),
      ],
    );
  }
}
