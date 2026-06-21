import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_theme.dart';
import '../services/database_service.dart';
import '../models/announcement.dart';
import '../screens/auth_screen.dart';
import 'user_home_screen.dart';
import 'user_order_screen.dart';
import 'user_tickets_screen.dart';

class UserBookingScreen extends StatefulWidget {
  const UserBookingScreen({super.key});

  @override
  State<UserBookingScreen> createState() => _UserBookingScreenState();
}

class _UserBookingScreenState extends State<UserBookingScreen> {
  int _currentIndex = 0;
  
  // Ref to refresh ticket tab when booking is successful
  final GlobalKey<UserTicketsScreenState> _ticketsKey = GlobalKey<UserTicketsScreenState>();

  // Profile data
  Map<String, dynamic>? _profile;
  List<Announcement> _announcements = [];
  int _sessionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileAndAnnouncements();
  }

  Future<void> _loadProfileAndAnnouncements() async {
    final profile = await DatabaseService.getProfile();
    final announcements = await DatabaseService.getAnnouncements();
    final bookings = await DatabaseService.getBookings();
    final completed = bookings.where((b) => b.status == 'Checked In').length;
    if (mounted) {
      setState(() {
        _profile = profile;
        _announcements = announcements;
        _sessionCount = completed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // List of screens
    final List<Widget> screens = [
      UserHomeScreen(
        onBookNowPressed: () {
          setState(() {
            _currentIndex = 1; // Direct to Book tab
          });
        },
      ),
      UserOrderScreen(
        onBookingSuccess: () {
          setState(() {
            _currentIndex = 2; // Direct to Tickets tab
          });
          _ticketsKey.currentState?.loadUserBookings();
        },
      ),
      UserTicketsScreen(key: _ticketsKey),
      _buildInboxScreen(),
      _buildProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.droplets, color: AppTheme.accentGold, size: 22),
            const SizedBox(width: 8),
            Text(
              "e-Renang UPSI",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bellRing, color: AppTheme.accentGold, size: 20),
            onPressed: () {
              setState(() {
                _currentIndex = 3; // Direct to Inbox
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: Image.asset(
              'assets/upsi_logo.png',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _ticketsKey.currentState?.loadUserBookings();
          }
          if (index == 3 || index == 4) {
            _loadProfileAndAnnouncements(); // Refresh when switching to inbox/profile
          }
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryNavy,
        unselectedItemColor: AppTheme.textLight,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home, size: 20),
            activeIcon: Icon(LucideIcons.home, size: 22),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendarPlus, size: 20),
            activeIcon: Icon(LucideIcons.calendarPlus, size: 22),
            label: 'Book Slot',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.ticket, size: 20),
            activeIcon: Icon(LucideIcons.ticket, size: 22),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.messageSquare, size: 20),
            activeIcon: Icon(LucideIcons.messageSquare, size: 22),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user, size: 20),
            activeIcon: Icon(LucideIcons.user, size: 22),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // --- INBOX SCREEN (Fetches from Supabase) ---
  Widget _buildInboxScreen() {
    if (_announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.inbox, size: 48, color: AppTheme.textLight),
            const SizedBox(height: 16),
            Text(
              "No announcements yet",
              style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfileAndAnnouncements,
      child: ListView.builder(
        itemCount: _announcements.length,
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          final item = _announcements[index];
          final isNew = DateTime.now().difference(item.createdAt).inHours < 24;
          final timeAgo = _formatTimeAgo(item.createdAt);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "NEW",
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textLight),
                ),
                const Divider(height: 20, color: AppTheme.border),
                Text(
                  item.content,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    if (diff.inDays < 7) return "${diff.inDays} days ago";
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  // --- PROFILE SCREEN (Editable, Supabase-backed) ---
  Widget _buildProfileScreen() {
    final String name = _profile?['name'] ?? 'User';
    final String email = _profile?['email'] ?? DatabaseService.currentUser?.email ?? 'N/A';
    final String type = _profile?['user_type'] ?? 'Student';
    final String upsiId = _profile?['upsi_id'] ?? 'N/A';
    final String phone = _profile?['phone'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Details Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.primaryNavy,
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        email,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (phone.isNotEmpty)
                        Text(
                          phone,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.goldLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          "$type - ID: $upsiId",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(LucideIcons.edit, size: 16),
              label: const Text("Edit Profile"),
              onPressed: () => _showEditProfileDialog(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryNavy,
                side: const BorderSide(color: AppTheme.primaryNavy),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // User Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildProfileStatCard(
                  icon: LucideIcons.checkSquare,
                  value: "$_sessionCount sessions",
                  label: "Swims Completed",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProfileStatCard(
                  icon: LucideIcons.coins,
                  value: "${_sessionCount * 20} pts",
                  label: "Renang Club Points",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Account Options
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _buildProfileOption(
                  icon: LucideIcons.helpCircle,
                  title: "Help & Support Desk",
                  subtitle: "Frequently asked questions, email contact",
                ),
                _buildProfileOption(
                  icon: LucideIcons.info,
                  title: "Terms & Conditions",
                  subtitle: "Pool rules, cancellation policies",
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Log Out Button
          OutlinedButton.icon(
            icon: const Icon(LucideIcons.logOut, size: 18),
            label: const Text("Log Out Account"),
            onPressed: () async {
              await DatabaseService.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              foregroundColor: AppTheme.error,
              side: const BorderSide(color: AppTheme.error, width: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // --- EDIT PROFILE DIALOG ---
  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _profile?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: _profile?['phone'] ?? '');
    final upsiIdCtrl = TextEditingController(text: _profile?['upsi_id'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Edit Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(LucideIcons.user),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: Icon(LucideIcons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: upsiIdCtrl,
                  decoration: const InputDecoration(
                    labelText: "UPSI ID / Staff ID",
                    prefixIcon: Icon(LucideIcons.creditCard),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await DatabaseService.updateProfile({
                    'name': nameCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'upsi_id': upsiIdCtrl.text.trim(),
                  });
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  _loadProfileAndAnnouncements();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Profile updated!", style: GoogleFonts.outfit(color: Colors.white)),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to update: $e", style: GoogleFonts.outfit(color: Colors.white)),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.goldLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryNavy, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryNavy, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppTheme.textLight),
      onTap: () {},
    );
  }
}
