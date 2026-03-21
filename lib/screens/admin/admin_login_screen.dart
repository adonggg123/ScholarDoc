import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
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
      backgroundColor: AppTheme.primaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 800;
          
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
    );
  }

  Widget _buildBrandingSection(BuildContext ctx, bool isMobile) {
    return Container(
      color: AppTheme.primaryColor,
      height: isMobile ? 300 : double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 24 : 32),
              decoration: BoxDecoration(
                color: ctx.surfaceC,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                size: isMobile ? 60 : 100,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'ScholarDoc Admin',
              style: Theme.of(ctx).textTheme.displayMedium?.copyWith(
                    color: ctx.surfaceC,
                    fontSize: isMobile ? 32 : 48,
                  ),
            ),
            SizedBox(height: 16),
            Text(
              'University Scholarship System',
              style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                    color: ctx.surfaceC.withValues(alpha: 0.8),
                    fontSize: isMobile ? 16 : 20,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext ctx, bool isMobile) {
    return Container(
      color: ctx.surfaceC,
      height: isMobile ? null : double.infinity,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: EdgeInsets.all(isMobile ? 32 : 48.0),
          child: Form(
            key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Administrator Login',
                        style: isMobile 
                          ? Theme.of(ctx).textTheme.headlineMedium
                          : Theme.of(ctx).textTheme.headlineLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Enter your credentials to access the dashboard.',
                      ),
                      SizedBox(height: 48),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Admin Username',
                          prefixIcon: Icon(Icons.person_outline),
                          filled: true,
                        ),
                        validator: (value) => value!.isEmpty ? 'Enter username' : null,
                      ),
                      SizedBox(height: 24),
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
                          filled: true,
                        ),
                        validator: (value) => value!.isEmpty ? 'Enter password' : null,
                      ),
                      SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Forgot Password?'),
                        ),
                      ),
                      SizedBox(height: 40),
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
                                      ),
                                    );
                                  } finally {
                                    if (mounted) setState(() => _isLoading = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: context.surfaceC),
                              )
                            : Text('Sign In to Dashboard'),
                      ),
                      SizedBox(height: 32),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Return to Student Portal'),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
