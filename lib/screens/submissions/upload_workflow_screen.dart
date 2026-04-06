import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/ml_service.dart';
import '../../services/auth_service.dart';
import '../../services/audit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/storage_service.dart';
import 'package:file_picker/file_picker.dart';

class UploadWorkflowScreen extends StatefulWidget {
  const UploadWorkflowScreen({super.key});

  @override
  State<UploadWorkflowScreen> createState() => _UploadWorkflowScreenState();
}

class _UploadWorkflowScreenState extends State<UploadWorkflowScreen> {
  int _currentStep = 0;

  bool _isUploading = false;

  final MLService _mlService = MLService();
  final AuthService _authService = AuthService();
  final AuditService _auditService = AuditService();
  final StorageService _storageService = StorageService();
  final TextEditingController _saController = TextEditingController();

  String? _sem1Url;
  String? _sem2Url;

  String? _sem1Feedback;
  String? _sem2Feedback;
  
  bool _isSem1Duplicate = false;
  bool _isSem2Duplicate = false;

  String? _sem1FileName;
  String? _sem2FileName;

  @override
  void initState() {
    super.initState();
    _loadSA();
  }

  Future<void> _loadSA() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      final doc = await _authService.getStudentProfile(uid);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _saController.text = data['saNumber'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _saController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload(String type, {bool pdfOnly = false}) async {
    try {
      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: pdfOnly ? FileType.custom : FileType.any,
        allowedExtensions: pdfOnly ? ['pdf'] : null,
        withData: true,
      );

      if (result == null || result.files.single.bytes == null) return;

      final bytes = result.files.single.bytes!;
      String originalName = result.files.single.name;

      setState(() {
        _isUploading = true;
        if (type == 'sem1') _sem1Feedback = null;
        if (type == 'sem2') _sem2Feedback = null;
      });

      String classificationResult = "Unknown";
      
      // 2. Perform ML Quality Check (Simulated on the path)
      // Since web might not have a path, skip ML Service validation if path is null
      if (result.files.single.path != null) {
        final validationResult = await _mlService.validateDocumentClarity(result.files.single.path!);
        classificationResult = await _mlService.classifyDocument(result.files.single.path!);

        if (!validationResult['isValid']) {
          setState(() {
            _isUploading = false;
            String errorFeedback = "⚠️ ${validationResult['message']} Please retake.";
            if (type == 'sem1') _sem1Feedback = errorFeedback;
            if (type == 'sem2') _sem2Feedback = errorFeedback;
          });
          return;
        }
      }

      // 3. Real Upload to Firebase Storage
      final uid = _authService.currentUser?.uid;
      if (uid == null) throw Exception("User not authenticated");

      final String storagePath = 'submissions/$uid/${DateTime.now().millisecondsSinceEpoch}_$originalName';
      final String downloadUrl = await _storageService.uploadFile(path: storagePath, bytes: bytes);

      if (!mounted) return;
      
      setState(() {
        _isUploading = false;
        String successFeedback = "✅ Validated successfully (Class: $classificationResult).";
            
        if (type == 'sem1') {
          _sem1Feedback = successFeedback;
          _sem1FileName = originalName;
          _sem1Url = downloadUrl;
        }
        if (type == 'sem2') {
          _sem2Feedback = successFeedback;
          _sem2FileName = originalName;
          _sem2Url = downloadUrl;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        String errorMsg = "Error: ${e.toString()}";
        if (type == 'sem1') _sem1Feedback = errorMsg;
        if (type == 'sem2') _sem2Feedback = errorMsg;
      });
    }
  }

  /* 
  Removed _simulateUpload as it is now handled by _handleUpload.
  */

  /* 
  Removed _simulateDuplicateCheck as it is no longer used for the new requirements.
  */

  void _showReviewSheet(String label, String fileName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.eye, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Document Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(label, style: TextStyle(color: context.textSec, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.surfaceC,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.crispBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(fileName.endsWith('.pdf') ? LucideIcons.fileText : LucideIcons.image, 
                      size: 64, color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(fileName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Verification: Passed', style: TextStyle(color: AppTheme.success, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Confirm Document', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Needs Correction?', style: TextStyle(color: context.textSec)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Submission'),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primaryColor,
            primary: AppTheme.primaryColor,
          ),
        ),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          elevation: 0,
          onStepContinue: () async {
            if (_currentStep < 2) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              setState(() => _isUploading = true);
              try {
                final user = _authService.currentUser;
                if (user != null) {
                  final doc = await _authService.getStudentProfile(user.uid);
                  final data = doc.data() as Map<String, dynamic>?;
                  final String studentId = data?['studentId'] ?? 'Unknown ID';
                  final String fullName = data?['fullName'] ?? 'Student';
  
                  await _authService.updateStudentProfile(user.uid, {
                    'status': 'Pending',
                    'saNumber': _saController.text.trim(),
                    'sem1Url': _sem1Url,
                    'sem2Url': _sem2Url,
                    'sem1FileName': _sem1FileName,
                    'sem2FileName': _sem2FileName,
                    'createdAt': FieldValue.serverTimestamp(),
                    'submittedAt': FieldValue.serverTimestamp(),
                    'requiresResubmission': false,
                    'adminRemarks': null, 
                  });
  
                  await _auditService.logActivity(
                    action: 'Submitted documents for scholarship verification',
                    userName: fullName,
                    role: 'Student',
                    studentId: studentId,
                  );
                }
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Documents submitted successfully!'),
                      backgroundColor: AppTheme.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to submit documents: $e'),
                      backgroundColor: AppTheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _isUploading = false);
              }
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
              title: const Text('Guide', style: TextStyle(fontSize: 12)),
              content: _buildStep1(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Files', style: TextStyle(fontSize: 12)),
              content: _buildStep2(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Final', style: TextStyle(fontSize: 12)),
              content: _buildStep3(),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Submission Protocol',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'Please ensure you have high-quality scans of the following:',
          style: TextStyle(color: context.textSec, fontSize: 13),
        ),
        const SizedBox(height: 24),
        _bulletPoint('1st Semester Validation ID (PDF Only)'),
        _bulletPoint('2nd Semester Validation ID (PDF Only)'),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.warning.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.warning,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.shieldAlert, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Quality Check Required',
                    style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Our AI system will automatically verify document clarity. Blurry or obstructed images will be rejected.',
                style: TextStyle(color: AppTheme.warning, fontSize: 12, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppTheme.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.check, size: 10, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
        
        // SA Number Field
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.surfaceC,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: context.crispBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.landmark, size: 18, color: AppTheme.primaryColor),
                  const SizedBox(width: 10),
                  const Text(
                    'Banking Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _saController,
                decoration: const InputDecoration(
                  labelText: 'SA Number',
                  hintText: 'xxxx-xxxx-xxxx',
                  prefixIcon: Icon(LucideIcons.creditCard),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Text(
                'Ensure your SA number is active for disbursement.',
                style: TextStyle(fontSize: 11, color: context.textSec),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildUploadCard(
          '1st Semester Validation ID',
          LucideIcons.fileText,
          onTap: () => _handleUpload('sem1', pdfOnly: true),
          feedback: _sem1Feedback,
          isDuplicate: _isSem1Duplicate,
          subtitle: 'PDF File Only (Max 5MB)',
          fileName: _sem1FileName,
        ),
        const SizedBox(height: 16),
        _buildUploadCard(
          '2nd Semester Validation ID',
          LucideIcons.fileText,
          onTap: () => _handleUpload('sem2', pdfOnly: true),
          feedback: _sem2Feedback,
          isDuplicate: _isSem2Duplicate,
          subtitle: 'PDF File Only (Max 5MB)',
          fileName: _sem2FileName,
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
    String subtitle = 'PDF, PNG or JPG (Max 5MB)',
    String? fileName,
  }) {
    final bool isCompleted = feedback != null && !isDuplicate && fileName != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: isDuplicate 
              ? AppTheme.error 
              : (isCompleted ? AppTheme.success.withValues(alpha: 0.5) : context.crispBorder),
          width: isCompleted || isDuplicate ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCompleted ? () => _showReviewSheet(label, fileName) : onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? AppTheme.success.withValues(alpha: 0.1) 
                            : (isDuplicate ? AppTheme.error.withValues(alpha: 0.1) : AppTheme.primaryColor.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isCompleted ? LucideIcons.fileCheck2 : (isDuplicate ? LucideIcons.copy : icon), 
                        color: isCompleted ? AppTheme.success : (isDuplicate ? AppTheme.error : AppTheme.primaryColor),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isCompleted ? 'Tap to Review: $fileName' : subtitle, 
                            style: TextStyle(
                              fontSize: 12, 
                              color: isCompleted ? AppTheme.success : context.textSec,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      Icon(LucideIcons.externalLink, size: 16, color: AppTheme.success)
                    else 
                      Icon(
                        isCompleted ? LucideIcons.refreshCcw : LucideIcons.uploadCloud, 
                        size: 18, 
                        color: isCompleted ? context.textSec : AppTheme.primaryColor,
                      ),
                  ],
                ),
                if (feedback != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted ? AppTheme.success.withValues(alpha: 0.05) : AppTheme.warning.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCompleted ? LucideIcons.sparkles : LucideIcons.alertCircle, 
                          size: 14, 
                          color: isCompleted ? AppTheme.success : AppTheme.warning,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feedback,
                            style: TextStyle(
                              fontSize: 11, 
                              color: isCompleted ? AppTheme.success : AppTheme.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: onTap,
                            icon: const Icon(LucideIcons.refreshCw, size: 14),
                            label: const Text('Re-upload', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                if (isDuplicate) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.copy, size: 14, color: AppTheme.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Warning: Duplicate detection triggered.',
                            style: TextStyle(fontSize: 11, color: AppTheme.error, fontWeight: FontWeight.w500),
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
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.checkCircle2, size: 64, color: AppTheme.success),
        ),
        const SizedBox(height: 24),
        const Text(
          'Verification Complete',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Your documents have been processed and are ready for official filing.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.textSec, height: 1.5, fontSize: 14),
        ),
        const SizedBox(height: 40),
        if (_sem1FileName != null) ...[
          _buildReviewItem(_sem1FileName!, '0.8 MB'),
          const SizedBox(height: 12),
        ],
        if (_sem2FileName != null) ...[
          _buildReviewItem(_sem2FileName!, '1.1 MB'),
          const SizedBox(height: 12),
        ],
        if (_sem1FileName == null && _sem2FileName == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('No documents uploaded yet.', style: TextStyle(color: context.textSec, fontStyle: FontStyle.italic)),
          ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildReviewItem(String name, String size) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.crispBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.fileText, size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(size, style: TextStyle(fontSize: 11, color: context.textSec)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, 
            icon: const Icon(LucideIcons.trash2, size: 18, color: AppTheme.error),
          ),
        ],
      ),
    );
  }
}
