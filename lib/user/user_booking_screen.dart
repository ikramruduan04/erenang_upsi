import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_theme.dart';
import '../services/database_service.dart';
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
  final GlobalKey<State> _ticketsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final user = DatabaseService.currentUser;
    final String userEmail = user['email'] ?? 'guest@upsi.edu.my';

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
        },
      ),
      UserTicketsScreen(key: _ticketsKey),
      _buildInboxScreen(),
      _buildProfileScreen(userEmail),
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

  // Beautiful simple inbox page
  Widget _buildInboxScreen() {
    final announcements = [
      {
        'title': '🏊 Jadual Pembersihan Kolam Utama',
        'time': '2 hours ago',
        'content': 'Sila ambil maklum bahawa Kolam Utama (Olimpik) akan ditutup bagi pembersihan rutin pada pagi Khamis dari jam 8:00 AM hingga 12:00 PM. Kolam-kolam lain beroperasi seperti biasa.',
        'isNew': true,
      },
      {
        'title': '🎉 Swim Club Bronze Membership Active!',
        'time': '1 day ago',
        'content': 'Welcome to the Renang Club. Complete swimming sessions to earn points and upgrade your membership status to Silver Swimmer!',
        'isNew': false,
      },
      {
        'title': '📢 Pool Dress Code Reminder',
        'time': '3 days ago',
        'content': 'All swimmers must wear appropriate nylon/spandex swimwear. Cotton shirts and track pants are strictly prohibited inside the pools.',
        'isNew': false,
      },
    ];

    return ListView.builder(
      itemCount: announcements.length,
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, index) {
        final item = announcements[index];
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
                      item['title'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (item['isNew'] as bool)
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
                item['time'] as String,
                style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textLight),
              ),
              const Divider(height: 20, color: AppTheme.border),
              Text(
                item['content'] as String,
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
    );
  }

  // Premium Profile Page
  Widget _buildProfileScreen(String email) {
    final user = DatabaseService.currentUser;
    final String name = user['name'] ?? 'User';
    final String type = user['userType'] ?? 'Student';
    final String upsiId = user['upsiId'] ?? 'N/A';

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
                    name.substring(0, 1).toUpperCase(),
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
          const SizedBox(height: 20),

          // User Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildProfileStatCard(
                  icon: LucideIcons.checkSquare,
                  value: type == 'Staff' ? "7 sessions" : "3 sessions",
                  label: "Swims Completed",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProfileStatCard(
                  icon: LucideIcons.coins,
                  value: type == 'Staff' ? "140 pts" : "60 pts",
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
                  icon: LucideIcons.sliders,
                  title: "Booking Preferences",
                  subtitle: "Notifications, default ticket values",
                ),
                _buildProfileOption(
                  icon: LucideIcons.shieldCheck,
                  title: "Account Security",
                  subtitle: "Change password, connected accounts",
                ),
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
            onPressed: () {
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

