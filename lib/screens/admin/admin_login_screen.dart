import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import 'admin_main_layout.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B), // Slate 800
              Color(0xFF0F172A), // Slate 900
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 900;
            
            if (isMobile) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildBrandingSection(context, true),
                    _buildLoginForm(context, true),
                  ],
                ),
              );
            }
            
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildBrandingSection(context, false),
                ),
                Expanded(
                  flex: 2,
                  child: _buildLoginForm(context, false),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandingSection(BuildContext ctx, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64),
      height: isMobile ? 300 : double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(
              Icons.school,
              size: isMobile ? 40 : 56,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 32),
          Text(
            'ScholarDoc',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 32 : 56,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          Text(
            'ADMINISTRATION PANEL',
            style: TextStyle(
              color: Colors.blue.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Enterprise-grade scholarship management\nand student synchronization system.',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext ctx, bool isMobile) {
    return Container(
      color: Colors.white,
      height: isMobile ? null : double.infinity,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: EdgeInsets.all(isMobile ? 32 : 48.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Authorized personnel only. Please sign in.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.shield_outlined, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) => value!.isEmpty ? 'Field required' : null,
                ),
                      SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Secure Password',
                    prefixIcon: Icon(Icons.key_outlined, size: 20),
                    fillColor: Colors.grey.shade50,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                  ),
                  validator: (value) => value!.isEmpty ? 'Field required' : null,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              await _authService.loginAdmin(
                                username: _usernameController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                              if (!ctx.mounted) return;
                              Navigator.pushReplacement(
                                ctx,
                                MaterialPageRoute(
                                    builder: (context) => const AdminMainLayout()),
                              );
                            } catch (e) {
                              if (!ctx.mounted) return;
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceAll('Exception: ', '')),
                                  backgroundColor: AppTheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Authorized Access Only'),
                ),
                SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Return to Student Portal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
