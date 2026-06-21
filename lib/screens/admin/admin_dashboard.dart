import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_theme.dart';
import '../../models/booking.dart';
import '../../services/database_service.dart';
import '../auth_screen.dart';

import '../../models/announcement.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = false;
  List<Booking> _bookings = [];
  List<Announcement> _announcements = [];
  String _searchQuery = '';
  String _statusFilter = 'All'; // All, Pending, Approved, Checked In, Cancelled
  int _selectedTab = 0; // 0: Dashboard, 1: Manage Inbox

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final list = await DatabaseService.getAnnouncements();
      if (mounted) {
        setState(() {
          _announcements = list;
        });
      }
    } catch (e) {
      // Ignored
    }
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final list = await DatabaseService.getBookings();
      if (mounted) {
        setState(() {
          _bookings = list;
        });
      }
    } catch (e) {
      // Gracefully handled by service local fallback
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    await DatabaseService.updateBookingStatus(id, status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Booking status updated to '$status'")),
    );
    _fetchBookings();
  }

  Future<void> _deleteBooking(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Booking?"),
        content: const Text(
          "Are you sure you want to permanently delete this booking?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.deleteBooking(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking deleted successfully.")),
      );
      _fetchBookings();
    }
  }

  // Opens dialog to manually add a walk-in booking
  void _showAddBookingDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final upsiIdController = TextEditingController();

    // Selection states
    String group = 'Staf & Pelajar UPSI';
    String subCategory = 'Pelajar UPSI';
    String poolType = 'Kolam Utama';
    String timeSlot = 'Sesi Petang (2.30 ptg - 6.30 ptg)';
    int quantity = 1;

    // Pricing categories
    final Map<String, List<Map<String, dynamic>>> categories = {
      'Staf & Pelajar UPSI': [
        {'name': 'Pelajar UPSI', 'price': 0.0, 'note': 'Sila bawa kad pelajar'},
        {
          'name': 'Staf/SUKSIS/SISPA/PALAPES - Suami/Isteri',
          'price': 3.0,
          'note': 'Sila bawa kad pekerja',
        },
        {
          'name': 'Staf/SUKSIS/SISPA/PALAPES - Anak (0-7 tahun)',
          'price': 0.0,
          'note': 'Sila bawa kad pekerja',
        },
        {
          'name': 'Staf/SUKSIS/SISPA/PALAPES - Anak (8 tahun ke atas)',
          'price': 3.0,
          'note': 'Sila bawa kad pekerja',
        },
        {
          'name': 'Staf Holding/Sambilan/RA',
          'price': 3.0,
          'note': 'Sila bawa kad pekerja/bukti perkhidmatan',
        },
      ],
      'Orang Awam': [
        {
          'name': 'Kanak-kanak (0-4 tahun)',
          'price': 0.0,
          'note': 'Sila bawa MyKid',
        },
        {
          'name': 'Kanak-kanak (5-7 tahun)',
          'price': 1.0,
          'note': 'Sila bawa MyKid',
        },
        {
          'name': 'Pelajar Sekolah & IPT (8-18 tahun)',
          'price': 5.0,
          'note': 'Sila bawa kad pelajar/Kad Pengenalan',
        },
        {'name': 'Dewasa', 'price': 10.0, 'note': 'Sila bawa kad pengenalan'},
        {
          'name': 'Warga Emas (60 tahun ke atas)',
          'price': 5.0,
          'note': 'Sila bawa kad pengenalan',
        },
        {
          'name': 'Pesara / Pencen Kerajaan',
          'price': 5.0,
          'note': 'Sila bawa kad pencen',
        },
        {
          'name': 'OKU - Kanak-kanak (0-7 tahun)',
          'price': 0.0,
          'note': 'Sila bawa kad OKU',
        },
        {
          'name': 'OKU - Kanak-kanak (8-17 tahun)',
          'price': 3.0,
          'note': 'Sila bawa kad OKU',
        },
        {'name': 'OKU - Dewasa', 'price': 5.0, 'note': 'Sila bawa kad OKU'},
      ],
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final availableSubs = categories[group] ?? [];

            double getPricePerTicket() {
              final item = availableSubs.firstWhere(
                (element) => element['name'] == subCategory,
                orElse: () => <String, dynamic>{'price': 0.0},
              );
              return (item['price'] as num).toDouble();
            }

            String getNotes() {
              final item = availableSubs.firstWhere(
                (element) => element['name'] == subCategory,
                orElse: () => <String, dynamic>{'note': ''},
              );
              return item['note'] as String;
            }

            double total = getPricePerTicket() * quantity;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Manual Walk-In Creator",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(labelText: "Full Name"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: "Email (Optional)",
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Group Category Selector
                    DropdownButtonFormField<String>(
                      initialValue: group,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: "Category Group",
                      ),
                      items: ['Staf & Pelajar UPSI', 'Orang Awam'].map((g) {
                        return DropdownMenuItem(value: g, child: Text(g));
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          group = val ?? 'Staf & Pelajar UPSI';
                          subCategory = categories[group]![0]['name'] as String;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Ticket Sub-category Selector
                    DropdownButtonFormField<String>(
                      key: ValueKey(group),
                      initialValue: subCategory,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Ticket Type",
                      ),
                      items: availableSubs.map((item) {
                        final String name = item['name'] as String;
                        final double price = (item['price'] as num).toDouble();
                        final priceStr = price == 0.0
                            ? "Percuma"
                            : "RM ${price.toStringAsFixed(2)}";
                        return DropdownMenuItem(
                          value: name,
                          child: Text("$name ($priceStr)"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          subCategory =
                              val ?? availableSubs[0]['name'] as String;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    if (group != 'Orang Awam') ...[
                      TextField(
                        controller: upsiIdController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: "UPSI Student/Staff ID",
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    DropdownButtonFormField<String>(
                      initialValue: poolType,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: "Pool Section",
                      ),
                      items:
                          [
                            'Kolam Utama',
                            'Kolam Renang Biasa',
                            'Kolam Kanak-Kanak',
                          ].map((p) {
                            return DropdownMenuItem(value: p, child: Text(p));
                          }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          poolType = val ?? 'Kolam Utama';
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: timeSlot,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: "Time Session",
                      ),
                      items:
                          [
                            'Sesi Pagi (8.30 pg - 12.30 tghari)',
                            'Sesi Petang (2.30 ptg - 6.30 ptg)',
                            'Sesi Petang - Ladies Day (2.30 ptg - 6.30 ptg)',
                            'Sesi Petang (3.00 ptg - 6.30 ptg)',
                          ].map((s) {
                            return DropdownMenuItem(value: s, child: Text(s));
                          }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          timeSlot = val ?? 'Sesi Petang (2.30 ptg - 6.30 ptg)';
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Catatan box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.goldLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        "Catatan: Sila pastikan pelawat membawa dokumen: ${getNotes()}",
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quantity:",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.minusCircle),
                              onPressed: () {
                                if (quantity > 1) {
                                  setModalState(() => quantity--);
                                }
                              },
                            ),
                            Text(
                              "$quantity",
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.plusCircle),
                              onPressed: () {
                                setModalState(() => quantity++);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Calculated Total:"),
                        Text(
                          "RM ${total.toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;

                    final timeStamp = DateTime.now().millisecondsSinceEpoch
                        .toString();
                    final uniqueId =
                        'W-${timeStamp.substring(timeStamp.length - 6)}';

                    final newBooking = Booking(
                      id: uniqueId,
                      name: nameController.text.trim(),
                      email: emailController.text.trim().isNotEmpty
                          ? emailController.text.trim()
                          : null,
                      upsiId: upsiIdController.text.trim().isNotEmpty
                          ? upsiIdController.text.trim()
                          : null,
                      userType: group,
                      subCategory: subCategory,
                      poolType: poolType,
                      bookingDate: DateTime.now(),
                      timeSlot: timeSlot,
                      quantity: quantity,
                      totalPrice: total,
                      status: 'Approved',
                      qrCode: 'UP-$uniqueId-WALKIN',
                      notes: getNotes(),
                      createdAt: DateTime.now(),
                    );

                    await DatabaseService.createBooking(newBooking);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _fetchBookings();
                  },
                  child: const Text("Create Booking"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Media Query for responsive layouts
    final bool isWide = MediaQuery.of(context).size.width >= 850;

    // Filter Bookings
    final filtered = _bookings.where((b) {
      final matchesSearch =
          b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (b.email ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (b.upsiId ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.id.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _statusFilter == 'All' || b.status == _statusFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    // Stats calculations
    final int totalCount = _bookings.length;
    final int pendingCount = _bookings
        .where((b) => b.status == 'Pending')
        .length;
    final int activeCount = _bookings
        .where((b) => b.status == 'Checked In')
        .length;
    final double revenue = _bookings
        .where((b) => b.status != 'Cancelled')
        .fold(0.0, (sum, b) => sum + b.totalPrice);

    final sidebar = Container(
      width: 250,
      color: AppTheme.primaryNavy,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.droplets,
                color: AppTheme.accentGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "e-Renang Admin",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _SidebarItem(
            icon: LucideIcons.layoutDashboard,
            label: "Dashboard",
            isActive: _selectedTab == 0,
            onTap: () {
              setState(() {
                _selectedTab = 0;
              });
            },
          ),
          _SidebarItem(
            icon: LucideIcons.plusCircle,
            label: "Manual Walk-in",
            onTap: _showAddBookingDialog,
          ),
          _SidebarItem(
            icon: LucideIcons.refreshCw,
            label: "Sync/Refresh",
            onTap: _fetchBookings,
          ),
          _SidebarItem(
            icon: LucideIcons.messageSquare,
            label: "Manage Inbox",
            isActive: _selectedTab == 1,
            onTap: () {
              setState(() {
                _selectedTab = 1;
              });
            },
          ),
          const Spacer(),
          _SidebarItem(
            icon: LucideIcons.logOut,
            label: "Log Out",
            onTap: () async {
              await DatabaseService.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );

    final mainContent = Column(
      children: [
        // Top Bar
        Container(
          height: 70,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              if (!isWide) ...[
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(
                      LucideIcons.menu,
                      color: AppTheme.primaryNavy,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  _selectedTab == 0 ? "Booking Overview" : "Manage Inbox",
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Image.asset(
                'assets/upsi_logo.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.border),

        // Content Area
        Expanded(
          child: _selectedTab == 0
              ? (_isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentGold,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats Counters Row
                            LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxis = constraints.maxWidth > 900
                                    ? 4
                                    : (constraints.maxWidth > 500 ? 2 : 1);
                                return GridView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxis,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 2.2,
                                      ),
                                  children: [
                                    _buildStatCard(
                                      "Total Bookings",
                                      "$totalCount",
                                      LucideIcons.calendar,
                                      Colors.blue,
                                    ),
                                    _buildStatCard(
                                      "Pending Requests",
                                      "$pendingCount",
                                      LucideIcons.clock,
                                      Colors.orange,
                                    ),
                                    _buildStatCard(
                                      "In Pool Now",
                                      "$activeCount",
                                      LucideIcons.droplets,
                                      Colors.teal,
                                    ),
                                    _buildStatCard(
                                      "Total Revenue",
                                      "RM ${revenue.toStringAsFixed(2)}",
                                      LucideIcons.coins,
                                      Colors.green,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // Filter and Table Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Booking Manager (${filtered.length})",
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                // Dropdown filters
                                DropdownButton<String>(
                                  value: _statusFilter,
                                  underline: const SizedBox(),
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.primaryNavy,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  items:
                                      [
                                        'All',
                                        'Pending',
                                        'Approved',
                                        'Checked In',
                                        'Cancelled',
                                      ].map((f) {
                                        return DropdownMenuItem(
                                          value: f,
                                          child: Text(f),
                                        );
                                      }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _statusFilter = val ?? 'All';
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Bookings list
                            if (filtered.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Center(
                                  child: Text(
                                    "No matching bookings found.",
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final booking = filtered[index];
                                  return _buildBookingItem(booking);
                                },
                              ),
                          ],
                        ),
                      ))
              : _buildInboxManagementContent(),
        ),
      ],
    );

    return Scaffold(
      drawer: !isWide ? Drawer(child: sidebar) : null,
      body: Row(
        children: [
          if (isWide) sidebar,
          Expanded(child: mainContent),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
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
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(Booking booking) {
    Color statusColor;
    switch (booking.status) {
      case 'Approved':
        statusColor = AppTheme.success;
        break;
      case 'Checked In':
        statusColor = AppTheme.primaryNavy;
        break;
      case 'Pending':
        statusColor = AppTheme.warning;
        break;
      default:
        statusColor = AppTheme.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info panel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          booking.name,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.goldLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${booking.userType} (${booking.subCategory})",
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "ID: ${booking.id} | ${booking.poolType} | ${booking.timeSlot}",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (booking.email != null && booking.email!.isNotEmpty)
                      Text(
                        "Email: ${booking.email} ${booking.upsiId != null && booking.upsiId!.isNotEmpty ? '| ID: ${booking.upsiId!}' : ''}",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              // Status + Quantity
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.status,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${booking.quantity} Pax | RM ${booking.totalPrice.toStringAsFixed(2)}",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20, color: AppTheme.border),

          // Operational Controls for Admin
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (booking.status == 'Pending')
                ElevatedButton.icon(
                  onPressed: () => _updateStatus(booking.id, 'Approved'),
                  icon: const Icon(LucideIcons.checkCircle, size: 14),
                  label: const Text("Approve"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
              if (booking.status == 'Approved')
                ElevatedButton.icon(
                  onPressed: () => _updateStatus(booking.id, 'Checked In'),
                  icon: const Icon(LucideIcons.checkSquare, size: 14),
                  label: const Text("Check In"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
              if (booking.status != 'Cancelled' &&
                  booking.status != 'Checked In') ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _updateStatus(booking.id, 'Cancelled'),
                  icon: const Icon(LucideIcons.xCircle, size: 14),
                  label: const Text("Cancel"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  LucideIcons.trash2,
                  color: AppTheme.error,
                  size: 18,
                ),
                onPressed: () => _deleteBooking(booking.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInboxManagementContent() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAnnouncementDialog,
        backgroundColor: AppTheme.accentGold,
        foregroundColor: AppTheme.primaryNavy,
        icon: const Icon(LucideIcons.plus),
        label: const Text(
          "New Announcement",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _announcements.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.inbox,
                    size: 48,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No announcements yet.",
                    style: GoogleFonts.outfit(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _announcements.length,
              itemBuilder: (context, index) {
                final announcement = _announcements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                announcement.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                LucideIcons.edit,
                                color: Colors.blue,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _showEditAnnouncementDialog(announcement),
                            ),
                            IconButton(
                              icon: const Icon(
                                LucideIcons.trash2,
                                color: AppTheme.error,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _deleteAnnouncement(announcement.id),
                            ),
                          ],
                        ),
                        Text(
                          "Posted on ${announcement.createdAt.day}/${announcement.createdAt.month}/${announcement.createdAt.year}",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          announcement.content,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddAnnouncementDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "New Announcement",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Content"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
              try {
                final ann = Announcement(
                  id: '',
                  title: titleCtrl.text,
                  content: contentCtrl.text,
                  createdAt: DateTime.now(),
                );
                await DatabaseService.createAnnouncement(ann);
                if (!mounted) return;
                Navigator.pop(ctx);
                _fetchAnnouncements();
              } catch (e) {
                // error
              }
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  void _showEditAnnouncementDialog(Announcement announcement) {
    final titleCtrl = TextEditingController(text: announcement.title);
    final contentCtrl = TextEditingController(text: announcement.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Edit Announcement",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Content"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
              try {
                await DatabaseService.updateAnnouncement(
                  announcement.id,
                  titleCtrl.text,
                  contentCtrl.text,
                );
                if (!mounted) return;
                Navigator.pop(ctx);
                _fetchAnnouncements();
              } catch (e) {
                // error
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAnnouncement(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Announcement?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.deleteAnnouncement(id);
      _fetchAnnouncements();
    }
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accentGold.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive
                    ? AppTheme.accentGold
                    : Colors.white.withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isActive
                      ? AppTheme.accentGold
                      : Colors.white.withValues(alpha: 0.8),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
