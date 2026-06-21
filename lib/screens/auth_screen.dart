import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_theme.dart';
import '../services/database_service.dart';
import '../user/user_booking_screen.dart';
import 'admin/admin_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isAdminTab = false;
  bool _isLogin = true; // For User tab (Login vs Sign Up)
  bool _isLoading = false;

  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _upsiIdController = TextEditingController();
  String _userType = 'Student'; // Student, Staff, Public

  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _upsiIdController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isAdminTab) {
        // Admin Login
        await DatabaseService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) return;
        final isAdmin = await DatabaseService.isAdmin();
        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else {
          // Logged in as user but tried admin portal
          await DatabaseService.signOut();
          setState(() {
            _errorMessage = "Access Denied. You are not an admin.";
          });
        }
      } else {
        // User Portal
        if (_isLogin) {
          await DatabaseService.signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          if (!mounted) return;
          final isAdmin = await DatabaseService.isAdmin();
          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserBookingScreen()),
            );
          }
        } else {
          // Sign Up
          if (_nameController.text.trim().isEmpty ||
              _emailController.text.trim().isEmpty ||
              _passwordController.text.isEmpty) {
            setState(() {
              _errorMessage = "Please fill in all required fields.";
              _isLoading = false;
            });
            return;
          }
          await DatabaseService.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            userType: _userType,
            upsiId: _userType == 'Public' ? '' : _upsiIdController.text.trim(),
          );
          // Auto login after signup in Supabase, navigate to user screen
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserBookingScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception')
            ? e.toString()
            : "Authentication failed. Check your credentials.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 450),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Selector
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isAdminTab = false;
                    _errorMessage = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: !_isAdminTab
                              ? AppTheme.primaryNavy
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      "User Portal",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: !_isAdminTab
                            ? AppTheme.primaryNavy
                            : AppTheme.textLight,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isAdminTab = true;
                    _isLogin = true; // Admin is always login
                    _errorMessage = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _isAdminTab
                              ? AppTheme.primaryNavy
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      "Admin Portal",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isAdminTab
                            ? AppTheme.primaryNavy
                            : AppTheme.textLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            _isAdminTab
                ? "Pool Operator Sign In"
                : (_isLogin
                      ? "Welcome Back to Renang Club"
                      : "Join the Renang Club"),
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (!_isAdminTab && !_isLogin) ...[
            // Register Only Fields
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(
                  LucideIcons.user,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Email Input (Shared)
          TextField(
            controller: _emailController,
            style: const TextStyle(color: AppTheme.textPrimary),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: _isAdminTab ? "Admin Email" : "Email Address",
              prefixIcon: const Icon(
                LucideIcons.mail,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Password Input (Shared)
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(LucideIcons.lock, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 12),

          if (!_isAdminTab && !_isLogin) ...[
            // User Category
            DropdownButtonFormField<String>(
              initialValue: _userType,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: "User Category",
                prefixIcon: Icon(
                  LucideIcons.graduationCap,
                  color: AppTheme.textSecondary,
                ),
              ),
              items: ['Student', 'Staff', 'Public'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _userType = val ?? 'Student';
                });
              },
            ),
            const SizedBox(height: 12),

            if (_userType != 'Public')
              TextField(
                controller: _upsiIdController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: "$_userType ID Number",
                  prefixIcon: const Icon(
                    LucideIcons.creditCard,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleAuth,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: _isAdminTab
                  ? AppTheme.accentGold
                  : AppTheme.primaryNavy,
              foregroundColor: _isAdminTab
                  ? AppTheme.primaryNavy
                  : Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _isAdminTab
                        ? "Admin Sign In"
                        : (_isLogin ? "Sign In" : "Create Account"),
                  ),
          ),

          if (!_isAdminTab) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _errorMessage = null;
                  });
                },
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Sign In",
                  style: const TextStyle(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;

          Widget rightSide = Container(
            color: AppTheme.background,
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 24,
                  right: 24,
                  child: Image.asset(
                    'assets/upsi_logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 40,
                    ),
                    child: _buildLoginForm(context),
                  ),
                ),
              ],
            ),
          );

          if (isDesktop) {
            return Row(
              children: [
                // Left Side: Image and Text
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy,
                      image: DecorationImage(
                        image: const AssetImage('assets/upsi_pool.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.6),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "e-Renang",
                            style: GoogleFonts.outfit(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Universiti Pendidikan Sultan Idris",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentGold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Right Side: Login
                Expanded(flex: 4, child: rightSide),
              ],
            );
          }

          // Fallback Mobile Layout (Vertical)
          return Stack(
            children: [
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  image: DecorationImage(
                    image: const AssetImage('assets/upsi_pool.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.6),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "e-Renang",
                        style: GoogleFonts.outfit(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Universiti Pendidikan Sultan Idris",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/upsi_logo.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height - 280,
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildLoginForm(context),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
