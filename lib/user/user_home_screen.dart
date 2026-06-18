import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../services/database_service.dart';

class UserHomeScreen extends StatelessWidget {
  final VoidCallback onBookNowPressed;

  const UserHomeScreen({
    super.key,
    required this.onBookNowPressed,
  });

  @override
  Widget build(BuildContext context) {
    final user = DatabaseService.currentUser;
    final String name = user['name'] ?? 'User';
    final String userType = user['userType'] ?? 'Student';
    
    // Determine membership tier details
    String tier = "Bronze Swimmer";
    int sessions = 3;
    int nextTierSessions = 10;
    double progress = sessions / nextTierSessions;
    Color tierColor = const Color(0xFFCD7F32); // Bronze

    if (userType == 'Staff') {
      tier = "Silver Swimmer";
      sessions = 7;
      progress = sessions / nextTierSessions;
      tierColor = const Color(0xFFC0C0C0); // Silver
    } else if (userType == 'Public') {
      tier = "Bronze Swimmer";
      sessions = 1;
      progress = sessions / nextTierSessions;
      tierColor = const Color(0xFFCD7F32); // Bronze
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $name 👋",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    "Ready for a refreshing swim?",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.goldLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.award, size: 16, color: AppTheme.primaryNavy),
                    const SizedBox(width: 4),
                    Text(
                      userType,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ZUS Membership Tier Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryNavy, Color(0xFF001F47)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.club, color: tierColor, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          tier,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "$sessions / $nextTierSessions swims",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Book ${nextTierSessions - sessions} more sessions to unlock premium benefits!",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onBookNowPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: AppTheme.primaryNavy,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.calendarPlus, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Book Swim Session Now",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Banner Slider (Mocked ZUS Promo Banner with UPSI Pool Image)
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/upsi_pool.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryNavy.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "KOLAM RENANG UPSI",
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Beat the Heat for only RM 2.00",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Affordable swimming lanes available daily. Jom Mandi!",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Real-time Pool Stats (Aesthetic additions)
          Text(
            "Pool Live Status",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  icon: LucideIcons.thermometer,
                  label: "Water Temp",
                  value: "27.5 °C",
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  icon: LucideIcons.activity,
                  label: "pH Level",
                  value: "7.3 (Optimal)",
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  icon: LucideIcons.users,
                  label: "Live Count",
                  value: "14 swimmers",
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pool Rules & Guidelines
          Text(
            "Swimming Guidelines",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildGuidelineItem(
            icon: LucideIcons.shieldAlert,
            title: "Proper Swimwear Required",
            subtitle: "Strictly nylon or spandex swimsuits only. Cotton apparel is prohibited.",
          ),
          _buildGuidelineItem(
            icon: LucideIcons.clock,
            title: "Operating Hours",
            subtitle: "• Isnin: Tutup sempena penyelenggaraan & pembersihan\n• Selasa - Khamis: Sesi Petang (2.30 ptg - 6.30 ptg)\n• Rabu (Ladies Day): Sesi Petang (2.30 ptg - 6.30 ptg)\n• Jumaat: Sesi Petang (3.00 ptg - 6.30 ptg)\n• Sabtu & Ahad: Sesi Pagi (8.30 pg - 12.30 tghari) & Sesi Petang (2.30 ptg - 6.30 ptg)",
          ),
          _buildGuidelineItem(
            icon: LucideIcons.heartPulse,
            title: "Health & Safety",
            subtitle: "Shower before entering. Do not swim if feeling unwell or under medication.",
          ),
          const SizedBox(height: 24),

          // Pool Location & Facilities Section
          Text(
            "Pool Location & Facilities",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Detail
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.mapPin, color: AppTheme.primaryNavy, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Lokasi Kolam",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Kolam Renang Universiti Pendidikan Sultan Idris (UPSI)\nJalan Proton City, 35900 Tanjong Malim, Perak.",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Link: https://maps.app.goo.gl/gtFbvunvHxJVHJP6A",
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Google Maps Buttons (Interactive Open & Copy Fallback)
                          Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  final Uri url = Uri.parse("https://maps.app.goo.gl/gtFbvunvHxJVHJP6A");
                                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Could not open maps. Copying link instead.",
                                            style: GoogleFonts.outfit(color: Colors.white),
                                          ),
                                          backgroundColor: AppTheme.error,
                                        ),
                                      );
                                    }
                                    Clipboard.setData(const ClipboardData(text: "https://maps.app.goo.gl/gtFbvunvHxJVHJP6A"));
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryNavy,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryNavy.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.navigation, color: AppTheme.accentGold, size: 14),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Open Google Maps",
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    const ClipboardData(text: "https://maps.app.goo.gl/gtFbvunvHxJVHJP6A"),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Pautan lokasi disalin!",
                                        style: GoogleFonts.outfit(color: Colors.white),
                                      ),
                                      backgroundColor: AppTheme.primaryNavy,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.border, width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.copy, color: AppTheme.textSecondary, size: 14),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Copy Link",
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppTheme.border),
                
                // Amenities/Facilities Detail
                Text(
                  "Kemudahan Kolam (Facilities & Amenities):",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                
                // Toilets & Shower
                _buildAmenityRow(
                  icon: LucideIcons.bath,
                  label: "Tandas & Pancuran Air (Toilets & Showers)",
                  desc: "Kemudahan tandas dan pancuran mandi yang lengkap di kedua-dua bilik lelaki dan wanita.",
                ),
                const SizedBox(height: 12),
                
                // Parking Space
                _buildAmenityRow(
                  icon: LucideIcons.car,
                  label: "Kawasan Parkir (Parking Space)",
                  desc: "Kawasan meletak kenderaan disediakan secara percuma dan luas berhampiran pintu masuk kolam.",
                ),
                const SizedBox(height: 12),
                
                // Changing Room
                _buildAmenityRow(
                  icon: LucideIcons.shirt,
                  label: "Bilik Salin Pakaian (Changing Room)",
                  desc: "Bilik persalinan berasingan yang selesa bagi menjaga privasi pengunjung.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.goldLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryNavy, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityRow({
    required IconData icon,
    required String label,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryNavy, Color(0xFF003884)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryNavy.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Icon(icon, color: AppTheme.accentGold, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
