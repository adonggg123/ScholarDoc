import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import '../main_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _fatherAgeController = TextEditingController();
  final TextEditingController _fatherOccController = TextEditingController();
  
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _motherAgeController = TextEditingController();
  final TextEditingController _motherOccController = TextEditingController();
  
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _tribeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _fatherNameController.dispose();
    _fatherAgeController.dispose();
    _fatherOccController.dispose();
    _motherNameController.dispose();
    _motherAgeController.dispose();
    _motherOccController.dispose();
    _incomeController.dispose();
    _religionController.dispose();
    _tribeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
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
                  'Join ScholarDoc',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: 8),
                Text(
                  'Register your student credentials to start managing your TES documents.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.textSec,
                      ),
                ),
                SizedBox(height: 32),

                // Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'e.g. Juan De La Cruz',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

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
                SizedBox(height: 16),

                // Email Input
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'University Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'e.g. juan@university.edu.ph',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Password Input
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Confirm Password Input
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                
                // Section Divider: Family Information
                Row(
                  children: [
                    Icon(Icons.family_restroom, color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Family Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Divider(),
                SizedBox(height: 16),

                // Father's Information
                TextFormField(
                  controller: _fatherNameController,
                  decoration: const InputDecoration(
                    labelText: "Father's Full Name",
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'e.g. Roberto De La Cruz',
                  ),
                  validator: (value) => value!.isEmpty ? "Enter father's name" : null,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _fatherAgeController,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          hintText: 'e.g. 50',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? "Enter age" : null,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _fatherOccController,
                        decoration: const InputDecoration(
                          labelText: 'Occupation',
                          hintText: 'e.g. Farmer',
                        ),
                        validator: (value) => value!.isEmpty ? "Enter occupation" : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Mother's Information
                TextFormField(
                  controller: _motherNameController,
                  decoration: const InputDecoration(
                    labelText: "Mother's Full Name (Maiden Name)",
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'e.g. Maria Clara',
                  ),
                  validator: (value) => value!.isEmpty ? "Enter mother's name" : null,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _motherAgeController,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          hintText: 'e.g. 48',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? "Enter age" : null,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _motherOccController,
                        decoration: const InputDecoration(
                          labelText: 'Occupation',
                          hintText: 'e.g. Housewife',
                        ),
                        validator: (value) => value!.isEmpty ? "Enter occupation" : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Household Financial Detail
                TextFormField(
                  controller: _incomeController,
                  decoration: const InputDecoration(
                    labelText: 'Total Yearly Family Income',
                    prefixIcon: Icon(Icons.payments_outlined),
                    hintText: 'e.g. 150000',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Enter yearly income" : null,
                ),
                SizedBox(height: 16),

                // Cultural & Religious Background
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _religionController,
                        decoration: const InputDecoration(
                          labelText: 'Religion',
                          hintText: 'e.g. Catholic',
                        ),
                        validator: (value) => value!.isEmpty ? "Enter religion" : null,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _tribeController,
                        decoration: const InputDecoration(
                          labelText: 'Tribe',
                          hintText: 'e.g. Tagalog',
                        ),
                        validator: (value) => value!.isEmpty ? "Enter tribe" : null,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 48),

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_passwordController.text != _confirmController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppTheme.error),
                              );
                              return;
                            }
                            
                            setState(() => _isLoading = true);
                            try {
                              Map<String, dynamic> studentData = {
                                'fullName': _nameController.text.trim(),
                                'studentId': _studentIdController.text.trim(),
                                'email': _emailController.text.trim(),
                                'role': 'student',
                                'familyDetails': {
                                  'fatherName': _fatherNameController.text.trim(),
                                  'fatherAge': _fatherAgeController.text.trim(),
                                  'fatherOccupation': _fatherOccController.text.trim(),
                                  'motherName': _motherNameController.text.trim(),
                                  'motherAge': _motherAgeController.text.trim(),
                                  'motherOccupation': _motherOccController.text.trim(),
                                  'yearlyIncome': _incomeController.text.trim(),
                                  'religion': _religionController.text.trim(),
                                  'tribe': _tribeController.text.trim(),
                                },
                              };

                              await _authService.registerStudent(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                                studentData: studentData,
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
                                  content: Text(e.toString().replaceAll(RegExp(r'\[.*\]'), '').trim()),
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
                      : Text('Create Account'),
                ),
                SizedBox(height: 24),

                // Login Prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        textStyle: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      child: Text('Sign In Here'),
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
