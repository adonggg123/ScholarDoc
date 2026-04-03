import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/auth_service.dart';
import '../main_layout.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: 8),
                Text(
                  'Please sign in with your student credentials.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.textSec,
                      ),
                ),
                SizedBox(height: 48),

                // Student ID Input
                TextFormField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID Number',
                    prefixIcon: Icon(Icons.badge_outlined),
                    hintText: 'e.g. 2023-12345',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your student ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_person_outlined, size: 18, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Login using your Student ID as your password.',
                          style: TextStyle(fontSize: 12, color: context.textSec, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),


                SizedBox(height: 32),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              await _authService.loginStudent(
                                studentId: _studentIdController.text.trim(),
                              );
                              if (!context.mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const MainLayout()),
                                (route) => false,
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Login failed: ${e.toString().replaceAll(RegExp(r'\[.*\]'), '').trim()}'),
                                  backgroundColor: AppTheme.error,
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          }
                        },
                  child: _isLoading 
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Sign In'),
                ),
                SizedBox(height: 24),

                // Register Prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        textStyle: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      child: Text('Register Here'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
