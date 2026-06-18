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

  // User Form Controllers
  final _nameController = TextEditingController(text: 'Muhammad Ikram');
  final _emailController = TextEditingController(
    text: 'ikram@student.upsi.edu.my',
  );
  final _upsiIdController = TextEditingController(text: 'D20211099231');
  String _userType = 'Student'; // Student, Staff, Public

  // Admin Form Controllers
  final _adminUsernameController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  String? _adminError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _upsiIdController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  void _handleUserLogin() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Name and Email.')),
      );
      return;
    }

    final String group = _userType == 'Public' ? 'Orang Awam' : 'Staf & Pelajar UPSI';

    // Set user profile in DatabaseService
    DatabaseService.setMockUser(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _userType == 'Public' ? '' : _upsiIdController.text.trim(),
      group,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserBookingScreen()),
    );
  }

  void _handleAdminLogin() {
    final username = _adminUsernameController.text.trim();
    final password = _adminPasswordController.text;

    if (username == 'admin' && password == 'admin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    } else {
      setState(() {
        _adminError =
            'Invalid credentials. (Hint: Use demo bypass or admin/admin)';
      });
    }
  }

  void _handleDemoLogin(String type) {
    if (type == 'student') {
      DatabaseService.setMockUser(
        'Muhammad Ikram',
        'ikram@student.upsi.edu.my',
        'D20211099231',
        'Staf & Pelajar UPSI',
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UserBookingScreen()),
      );
    } else if (type == 'public') {
      DatabaseService.setMockUser(
        'John Smith',
        'john.smith@gmail.com',
        '',
        'Orang Awam',
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UserBookingScreen()),
      );
    } else if (type == 'admin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Stack(
        children: [
          // Background swimming pool subtle patterns (Stylized wave elements)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentGold.withValues(alpha: 0.05),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Header
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.accentGold.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.droplets,
                      color: AppTheme.accentGold,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "e-Renang UPSI",
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    "PREMIUM SWIMMING POOL BOOKING",
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Card
                  Container(
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
                                onTap: () =>
                                    setState(() => _isAdminTab = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
                                onTap: () => setState(() => _isAdminTab = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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

                        if (!_isAdminTab) ...[
                          // USER LOGIN FORM
                          Text(
                            "Join the Renang Club",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Name Input
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

                          // Email Input
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: Icon(
                                LucideIcons.mail,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // User Type Select
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
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _userType = val ?? 'Student';
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Student ID (Conditional)
                          if (_userType != 'Public')
                            TextField(
                              controller: _upsiIdController,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                labelText: "$_userType ID Number",
                                prefixIcon: const Icon(
                                  LucideIcons.creditCard,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: _handleUserLogin,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text("Enter Booking Portal"),
                          ),
                        ] else ...[
                          // ADMIN LOGIN FORM
                          Text(
                            "Pool Operator Sign In",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_adminError != null) ...[
                            Text(
                              _adminError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          TextField(
                            controller: _adminUsernameController,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: const InputDecoration(
                              labelText: "Username",
                              prefixIcon: Icon(
                                LucideIcons.userCheck,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: _adminPasswordController,
                            obscureText: true,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: const InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(
                                LucideIcons.lock,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: _handleAdminLogin,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: AppTheme.accentGold,
                              foregroundColor: AppTheme.primaryNavy,
                            ),
                            child: const Text("Admin Sign In"),
                          ),
                        ],

                        // Divider & Demo Quick Logins
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: AppTheme.border)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "DEMO QUICK ACCESS",
                                style: TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: AppTheme.border)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Quick Logins
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleDemoLogin('student'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                child: const Text("Student"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleDemoLogin('public'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                child: const Text("Guest"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleDemoLogin('admin'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                child: const Text("Admin"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
