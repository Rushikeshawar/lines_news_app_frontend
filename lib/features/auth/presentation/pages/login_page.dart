// lib/features/auth/presentation/pages/login_page.dart - COMPLETE WORKING VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/lines_logo.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_models.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showLoginForm = false;

  late AnimationController _splashController;
  late AnimationController _formController;
  late Animation<double> _splashFadeAnimation;
  late Animation<double> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _splashController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Splash fade out animation
    _splashFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _splashController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    // Form slide up animation
    _formSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    ));

    // Form fade in animation
    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    ));

    // Start the splash animation
    _splashController.forward();

    // Listen to splash animation completion
    _splashController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showLoginForm = true;
        });
        _formController.forward();
      }
    });
  }

  @override
  void dispose() {
    _splashController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      print('Login Page: Auth state changed');
      
      next.when(
        data: (user) {
          if (user != null) {
            print('Login Page: User authenticated, navigating to home');
            setState(() => _isLoading = false);
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go('/');
              }
            });
          } else {
            setState(() => _isLoading = false);
          }
        },
        loading: () {
          print('Login Page: Auth loading');
          setState(() => _isLoading = true);
        },
        error: (error, stack) {
          print('Login Page: Auth error: $error');
          setState(() => _isLoading = false);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_getErrorMessage(error.toString())),
                backgroundColor: AppTheme.errorColor,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Splash Screen
            if (!_showLoginForm)
              AnimatedBuilder(
                animation: _splashFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _splashFadeAnimation.value,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.newspaper,
                              size: 80,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const AnimatedLinesLogo(
                            height: 60,
                            showTagline: true,
                          ),
                          const SizedBox(height: 24),
                          CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Login Form
            if (_showLoginForm)
              AnimatedBuilder(
                animation: _formController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _formSlideAnimation.value),
                    child: Opacity(
                      opacity: _formFadeAnimation.value,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 40),
                            
                            // Logo and title
                            const Center(
                              child: AnimatedLinesLogo(
                                height: 80,
                                showTagline: true,
                              ),
                            ),
                            
                            const SizedBox(height: 48),
                            
                            // Welcome text
                            Text(
                              'Welcome Back!',
                              style: AppTextStyles.headline2,
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Sign in to your account to continue reading',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Login form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Email field
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    autocorrect: false,
                                    enabled: !_isLoading,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Enter your email',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (_) => _handleLogin(),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Password field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    enabled: !_isLoading,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      hintText: 'Enter your password',
                                      prefixIcon: const Icon(Icons.lock_outlined),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword 
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: _isLoading ? null : () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (_) => _handleLogin(),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Login button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleLogin,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text('Sign In'),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Forgot password
                                  TextButton(
                                    onPressed: _isLoading ? null : () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Forgot password feature coming soon'),
                                          backgroundColor: AppTheme.warningColor,
                                        ),
                                      );
                                    },
                                    child: const Text('Forgot Password?'),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Demo login section
                            _buildDemoLoginSection(),
                            
                            const SizedBox(height: 32),
                            
                            // Sign up link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _isLoading ? null : () => context.go('/auth/register'),
                                  child: const Text('Sign Up'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Build demo login section
  Widget _buildDemoLoginSection() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.mutedTextColor,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Demo login button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleDemoLogin,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isLoading ? Colors.grey[300]! : AppTheme.primaryColor,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.play_arrow,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
            label: Text(
              _isLoading ? 'Creating Demo Session...' : 'Try Demo Login',
              style: TextStyle(
                color: _isLoading ? Colors.grey[600] : AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Info text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Demo login provides full access to explore app features without registration',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Login handler
  Future<void> _handleLogin() async {
    if (_isLoading) {
      print('Login already in progress, ignoring request');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print('Starting login process for: $email');

    try {
      setState(() => _isLoading = true);
      
      // Clear any previous error states
      ref.invalidate(authProvider);
      
      // Wait for state to clear
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Attempt login
      await ref.read(authProvider.notifier).login(email, password);
      
      print('Login request completed');
    } catch (e) {
      print('Login error in handler: $e');
      setState(() => _isLoading = false);
    }
  }

  // Demo login handler
  Future<void> _handleDemoLogin() async {
    if (_isLoading) {
      print('Demo login already in progress, ignoring request');
      return;
    }

    print('Starting demo login');

    try {
      setState(() => _isLoading = true);
      
      // Clear any previous error states
      ref.invalidate(authProvider);
      
      // Wait for state to clear
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Attempt demo login
      await ref.read(authProvider.notifier).demoLogin();
      
      print('Demo login request completed');
    } catch (e) {
      print('Demo login error in handler: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demo login failed: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Helper method to format error messages
  String _getErrorMessage(String error) {
    if (error.contains('Invalid email or password')) {
      return 'Invalid email or password. Please check your credentials.';
    } else if (error.contains('Network error')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('Too many login attempts')) {
      return 'Too many login attempts. Please try again later.';
    } else if (error.contains('Authentication failed')) {
      return 'Authentication failed. Please check your credentials.';
    } else if (error.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (error.contains('500')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Login failed. Please try again.';
    }
  }
}