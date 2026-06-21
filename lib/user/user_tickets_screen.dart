import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_theme.dart';
import '../models/booking.dart';
import '../services/database_service.dart';

class UserTicketsScreen extends StatefulWidget {
  const UserTicketsScreen({super.key});

  @override
  State<UserTicketsScreen> createState() => _UserTicketsScreenState();
}

class _UserTicketsScreenState extends State<UserTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = false;
  List<Booking> _allBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserBookings() async {
    setState(() => _isLoading = true);
    try {
      // getBookings() already filters by user_id for non-admin users
      final list = await DatabaseService.getBookings();
      setState(() {
        _allBookings = list;
      });
    } catch (e) {
      // Handled internally
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showTicketDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ticket Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.droplets,
                            color: AppTheme.accentGold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "e-Renang Entry Ticket",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Digital QR Mockup
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: _buildMockQRCode(booking.qrCode),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        booking.qrCode,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Details Grid
                      _buildTicketDetailRow("Swimmer Name", booking.name),
                      _buildTicketDetailRow("Category Group", booking.userType),
                      _buildTicketDetailRow("Ticket Type", booking.subCategory),
                      if (booking.notes.isNotEmpty)
                        _buildTicketDetailRow("Catatan", booking.notes),
                      if (booking.upsiId != null && booking.upsiId!.isNotEmpty)
                        _buildTicketDetailRow("UPSI ID", booking.upsiId!),
                      _buildTicketDetailRow("Pool Section", booking.poolType),
                      _buildTicketDetailRow(
                        "Date",
                        "${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}",
                      ),
                      _buildTicketDetailRow("Time Session", booking.timeSlot),
                      _buildTicketDetailRow(
                        "Tickets / Slots",
                        "${booking.quantity} Pax",
                      ),
                      _buildTicketDetailRow(
                        "Price Paid",
                        "RM ${booking.totalPrice.toStringAsFixed(2)}",
                      ),

                      const Divider(height: 32, color: AppTheme.border),

                      // Instructions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            LucideIcons.info,
                            color: AppTheme.accentGold,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Please present this QR code to the swimming pool staff at the entry turnstile. Proper swimming apparel is required.",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
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
          ),
        );
      },
    );
  }

  Widget _buildTicketDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Generates a mock QR code in UI using nested containers
  Widget _buildMockQRCode(String data) {
    return Container(
      width: 140,
      height: 140,
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          // Outer border corners representing QR alignment anchors
          Positioned(top: 0, left: 0, child: _qrAnchor()),
          Positioned(top: 0, right: 0, child: _qrAnchor()),
          Positioned(bottom: 0, left: 0, child: _qrAnchor()),

          // Random pixel dots simulation
          Center(
            child: Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(4),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: 49,
                itemBuilder: (context, index) {
                  // Standard pseudo-random logic to simulate QR structure
                  final isFilled =
                      (index * 7 + 13) % 5 == 0 ||
                      (index % 3 == 0) ||
                      (index > 40 && index % 2 == 0);
                  return Container(
                    color: isFilled ? AppTheme.primaryNavy : Colors.transparent,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrAnchor() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryNavy, width: 4),
      ),
      padding: const EdgeInsets.all(4),
      child: Container(color: AppTheme.primaryNavy),
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.ticket, size: 64, color: AppTheme.textLight),
            const SizedBox(height: 16),
            Text(
              "No Tickets Found",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Book a swimming slot in the Catalog tab.",
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserBookings,
      color: AppTheme.accentGold,
      child: ListView.builder(
        itemCount: bookings.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final booking = bookings[index];

          Color statusBg;
          Color statusText;
          switch (booking.status) {
            case 'Approved':
              statusBg = AppTheme.success.withValues(alpha: 0.15);
              statusText = AppTheme.success;
              break;
            case 'Checked In':
              statusBg = AppTheme.primaryNavy.withValues(alpha: 0.15);
              statusText = AppTheme.primaryNavy;
              break;
            case 'Pending':
              statusBg = AppTheme.warning.withValues(alpha: 0.15);
              statusText = AppTheme.warning;
              break;
            default: // Cancelled
              statusBg = AppTheme.error.withValues(alpha: 0.15);
              statusText = AppTheme.error;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showTicketDetails(booking),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Date Card
                    Container(
                      width: 65,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.goldLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ][booking.bookingDate.month - 1].toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          Text(
                            "${booking.bookingDate.day}",
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Booking Core Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.poolType,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.timeSlot,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  booking.status,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${booking.quantity} Pax",
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // QR ticket stub divider & mini QR icon
                    Container(
                      height: 50,
                      width: 1.5,
                      color: AppTheme.border,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                    ),

                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.qrCode,
                          color: AppTheme.primaryNavy,
                          size: 28,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "SCAN",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter active bookings (Pending, Approved)
    final active = _allBookings
        .where((b) => b.status == 'Approved' || b.status == 'Pending')
        .toList();
    // Filter past bookings (Checked In, Cancelled)
    final history = _allBookings
        .where((b) => b.status == 'Checked In' || b.status == 'Cancelled')
        .toList();

    return Column(
      children: [
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryNavy,
            unselectedLabelColor: AppTheme.textLight,
            indicatorColor: AppTheme.primaryNavy,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: "Active Passes"),
              Tab(text: "Booking History"),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.border),

        // Tab View
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGold),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(active),
                    _buildBookingList(history),
                  ],
                ),
        ),
      ],
    );
  }
}
