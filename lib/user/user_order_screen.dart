import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_theme.dart';
import '../models/booking.dart';
import '../services/database_service.dart';

class CartItem {
  final String poolType;
  final DateTime bookingDate;
  final String timeSlot;
  final String userType;
  final String subCategory;
  final String notes;
  final int quantity;
  final double pricePerTicket;

  CartItem({
    required this.poolType,
    required this.bookingDate,
    required this.timeSlot,
    required this.userType,
    required this.subCategory,
    required this.notes,
    required this.quantity,
    required this.pricePerTicket,
  });

  double get totalPrice => pricePerTicket * quantity;
}

class UserOrderScreen extends StatefulWidget {
  final VoidCallback onBookingSuccess;

  const UserOrderScreen({
    super.key,
    required this.onBookingSuccess,
  });

  @override
  State<UserOrderScreen> createState() => _UserOrderScreenState();
}

class _UserOrderScreenState extends State<UserOrderScreen> {
  // Selection States
  String _selectedPool = 'Kolam Utama';
  DateTime _selectedDate = DateTime.now();
  String _selectedSlot = '08:00 AM - 10:00 AM';
  int _quantity = 1;

  // New Category Selection States
  String _selectedGroup = 'Staf & Pelajar UPSI';
  String _selectedSubCategory = 'Pelajar UPSI';

  // Cart state
  final List<CartItem> _cart = [];

  // Coupon State
  final _promoController = TextEditingController();
  double _discountPercentage = 0.0;
  double _flatDiscount = 0.0;
  String? _appliedPromoCode;
  String? _promoError;

  // Categories & Pricing Rules Definition
  final Map<String, List<Map<String, dynamic>>> _categories = {
    'Staf & Pelajar UPSI': [
      {
        'name': 'Pelajar UPSI',
        'price': 0.0,
        'note': 'Sila bawa kad pelajar',
      },
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
      {
        'name': 'Dewasa',
        'price': 10.0,
        'note': 'Sila bawa kad pengenalan',
      },
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
      {
        'name': 'OKU - Dewasa',
        'price': 5.0,
        'note': 'Sila bawa kad OKU',
      },
    ],
  };

  // Pool Catalog Data
  final List<Map<String, dynamic>> _pools = [
    {
      'name': 'Kolam Utama',
      'icon': LucideIcons.trophy,
      'depth': 'Standard Olimpik',
      'desc': 'Standard Olimpik bersaiz 50 meter panjang dan 25 meter lebar dengan 10 lorong.',
    },
    {
      'name': 'Kolam Renang Biasa',
      'icon': LucideIcons.compass,
      'depth': '1.2 meter kedalaman',
      'desc': 'Kedalaman bersesuaian untuk latihan renang biasa dan santai.',
    },
    {
      'name': 'Kolam Kanak-Kanak',
      'icon': LucideIcons.smile,
      'depth': '0.5 meter kedalaman',
      'desc': 'Kawasan cetek dan selamat untuk kanak-kanak bermain air.',
    },
  ];

  // Time Slots
  final List<String> _timeSlots = [
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
    '08:00 PM - 10:00 PM',
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  double _getPricePerTicket() {
    final list = _categories[_selectedGroup] ?? [];
    final sub = list.firstWhere(
      (item) => item['name'] == _selectedSubCategory,
      orElse: () => {'price': 0.0},
    );
    return (sub['price'] as num).toDouble();
  }

  String _getNotes() {
    final list = _categories[_selectedGroup] ?? [];
    final sub = list.firstWhere(
      (item) => item['name'] == _selectedSubCategory,
      orElse: () => {'note': ''},
    );
    return sub['note'] as String;
  }

  double _getSelectedSubtotal() {
    return _getPricePerTicket() * _quantity;
  }

  double _getCartSubtotal() {
    return _cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double _getCartDiscountAmount() {
    final subtotal = _getCartSubtotal();
    double discount = (subtotal * _discountPercentage) + _flatDiscount;
    if (discount > subtotal) discount = subtotal;
    return discount;
  }

  double _getCartTotalPrice() {
    final total = _getCartSubtotal() - _getCartDiscountAmount();
    return total < 0 ? 0.00 : total;
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    setState(() {
      _promoError = null;
      if (code == 'JOMRENANG') {
        _discountPercentage = 0.20; // 20% off
        _flatDiscount = 0.0;
        _appliedPromoCode = 'JOMRENANG';
      } else if (code == 'ZUSRENANG') {
        _flatDiscount = 1.50; // RM1.50 off
        _discountPercentage = 0.0;
        _appliedPromoCode = 'ZUSRENANG';
      } else if (code.isEmpty) {
        _promoError = 'Please enter a code.';
      } else {
        _promoError = 'Invalid promo code.';
      }
    });
  }

  void _removePromo() {
    setState(() {
      _appliedPromoCode = null;
      _discountPercentage = 0.0;
      _flatDiscount = 0.0;
      _promoController.clear();
    });
  }

  void _addToCart() {
    setState(() {
      _cart.add(
        CartItem(
          poolType: _selectedPool,
          bookingDate: _selectedDate,
          timeSlot: _selectedSlot,
          userType: _selectedGroup,
          subCategory: _selectedSubCategory,
          notes: _getNotes(),
          quantity: _quantity,
          pricePerTicket: _getPricePerTicket(),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Added $_quantity x $_selectedSubCategory to cart!",
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCheckoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final double subtotal = _getCartSubtotal();
            final double discount = _getCartDiscountAmount();
            final double total = _getCartTotalPrice();
            final currentUser = DatabaseService.currentUser;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pull bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Checkout Cart",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Divider(height: 24, color: AppTheme.border),

                  // Cart Items List
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _cart.length,
                        itemBuilder: (context, idx) {
                          final item = _cart[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(LucideIcons.ticket, color: AppTheme.primaryNavy, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.subCategory,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "${item.poolType} • ${item.timeSlot}",
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        "${item.bookingDate.day}/${item.bookingDate.month}/${item.bookingDate.year}",
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.accentGold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "RM ${item.totalPrice.toStringAsFixed(2)}",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryNavy,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "${item.quantity} x RM ${item.pricePerTicket.toStringAsFixed(2)}",
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 18),
                                  onPressed: () {
                                    setModalState(() {
                                      _cart.removeAt(idx);
                                    });
                                    setState(() {});
                                    if (_cart.isEmpty) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 24, color: AppTheme.border),

                  // User Category Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.user, color: AppTheme.primaryNavy),
                        const SizedBox(width: 12),
                        Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               "${currentUser['name']} (${currentUser['userType']})",
                               style: GoogleFonts.outfit(
                                                     fontSize: 13,
                                                     fontWeight: FontWeight.bold,
                                                     color: AppTheme.textPrimary,
                                                   ),
                             ),
                             if (currentUser['upsiId'] != null && currentUser['upsiId']!.isNotEmpty)
                               Text(
                                 "ID: ${currentUser['upsiId']}",
                                 style: GoogleFonts.outfit(
                                   fontSize: 11,
                                   color: AppTheme.textSecondary,
                                 ),
                               ),
                           ],
                         ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Promo Code Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: "Enter Promo Code (e.g. JOMRENANG)",
                            errorText: _promoError,
                            suffixIcon: _appliedPromoCode != null
                                ? IconButton(
                                    icon: const Icon(Icons.cancel, color: AppTheme.textSecondary),
                                    onPressed: () {
                                      _removePromo();
                                      setModalState(() {});
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _applyPromo();
                          setModalState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGold,
                          foregroundColor: AppTheme.primaryNavy,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                  if (_appliedPromoCode != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(LucideIcons.check, color: AppTheme.success, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "Promo code $_appliedPromoCode successfully applied!",
                          style: GoogleFonts.outfit(color: AppTheme.success, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 24, color: AppTheme.border),

                  // Price Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal", style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
                      Text("RM ${subtotal.toStringAsFixed(2)}", style: GoogleFonts.outfit(color: AppTheme.textPrimary)),
                    ],
                  ),
                  if (discount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Discount", style: GoogleFonts.outfit(color: AppTheme.success)),
                        Text("-RM ${discount.toStringAsFixed(2)}", style: GoogleFonts.outfit(color: AppTheme.success)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        "RM ${total.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Place Booking Button
                  ElevatedButton(
                    onPressed: () => _confirmBooking(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.checkCheck),
                        const SizedBox(width: 8),
                        Text(
                          "Confirm & Pay RM ${total.toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _confirmBooking(BuildContext modalContext) async {
    Navigator.pop(modalContext); // Close modal sheet

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
      },
    );

    // Simulate payment processing
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    final currentUser = DatabaseService.currentUser;
    final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    // We will loop through all cart items and create a booking for each
    for (int i = 0; i < _cart.length; i++) {
      final item = _cart[i];
      final uniqueId = 'B-${timeStamp.substring(timeStamp.length - 6)}-$i';
      
      // Calculate item specific price after promo code has been distributed or applied
      final double cartSubtotal = _getCartSubtotal();
      final double cartDiscount = _getCartDiscountAmount();
      final double ratio = cartSubtotal > 0 ? (item.totalPrice / cartSubtotal) : 0;
      final double itemDiscount = cartDiscount * ratio;
      final double finalItemPrice = item.totalPrice - itemDiscount;

      final newBooking = Booking(
        id: uniqueId,
        name: currentUser['name'] ?? 'Guest',
        email: currentUser['email'] ?? 'guest@upsi.edu.my',
        phone: '01X-XXX XXXX',
        upsiId: currentUser['upsiId'] ?? '',
        userType: item.userType,
        subCategory: item.subCategory,
        poolType: item.poolType,
        bookingDate: item.bookingDate,
        timeSlot: item.timeSlot,
        quantity: item.quantity,
        totalPrice: finalItemPrice < 0 ? 0.00 : finalItemPrice,
        status: 'Approved', // Auto-approved for demo purposes
        qrCode: 'UP-$uniqueId-${item.poolType.substring(0, 3).replaceAll(" ", "").toUpperCase()}',
        notes: item.notes,
        createdAt: DateTime.now(),
      );

      // Write to database (will fall back to memory automatically)
      await DatabaseService().createBooking(newBooking);
    }

    // Clear cart
    setState(() {
      _cart.clear();
    });

    // Show Success Dialog
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.checkCircle2,
                color: AppTheme.success,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                "Bookings Confirmed!",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your swimming passes have been generated successfully. Show the QR tickets at the pool entrance.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  widget.onBookingSuccess(); // Direct back and trigger tab change
                },
                child: const Text("View My Tickets"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double selectedSubtotal = _getSelectedSubtotal();
    final List<Map<String, dynamic>> availableSubCategories = _categories[_selectedGroup] ?? [];

    return Column(
      children: [
        // Horizontal date selector (ZUS Style calendar)
        Container(
          height: 80,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;

              final String weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  width: 55,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryNavy : AppTheme.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekday,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: isSelected ? AppTheme.accentGold : AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${date.day}",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, color: AppTheme.border),

        // Main booking catalog contents
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SELECT POOL AREA
                Text(
                  "1. Select Pool Area",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: _pools.map((pool) {
                    final String name = pool['name'];
                    final isSelected = name == _selectedPool;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPool = name;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.goldLight.withValues(alpha: 0.2) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.accentGold : AppTheme.border,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryNavy : AppTheme.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                pool['icon'],
                                color: isSelected ? AppTheme.accentGold : AppTheme.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Depth: ${pool['depth']}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppTheme.accentGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    pool['desc'],
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
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 2. SELECT CATEGORY AND OPTIONS
                Text(
                  "2. Select Category & Ticket Type",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Group selector toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGroup = 'Staf & Pelajar UPSI';
                            _selectedSubCategory = _categories[_selectedGroup]![0]['name'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedGroup == 'Staf & Pelajar UPSI' ? AppTheme.primaryNavy : Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            "UPSI Staff/Student",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _selectedGroup == 'Staf & Pelajar UPSI' ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGroup = 'Orang Awam';
                            _selectedSubCategory = _categories[_selectedGroup]![0]['name'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedGroup == 'Orang Awam' ? AppTheme.primaryNavy : Colors.white,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            "Orang Awam (Public)",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _selectedGroup == 'Orang Awam' ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subcategory Dropdown list
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedGroup),
                  initialValue: _selectedSubCategory,
                  style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: "Ticket Option",
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: availableSubCategories.map((item) {
                    final double price = (item['price'] as num).toDouble();
                    final priceStr = price == 0.0 ? "Percuma" : "RM ${price.toStringAsFixed(2)}";
                    return DropdownMenuItem<String>(
                      value: item['name'] as String,
                      child: Text("${item['name']} ($priceStr)"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSubCategory = val ?? availableSubCategories[0]['name'];
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Requirements notice (Catatan Card)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.goldLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.info, color: AppTheme.primaryNavy, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Catatan Penting:",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${_getNotes()} semasa melapor diri di kolam renang.",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. SELECT TIME SLOT
                Text(
                  "3. Select Session Time",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _timeSlots.map((slot) {
                    final isSelected = slot == _selectedSlot;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSlot = slot;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryNavy : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryNavy : AppTheme.border,
                          ),
                        ),
                        child: Text(
                          slot,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 4. QUANTITY SELECTOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "4. Ticket Quantity",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.minusCircle, color: AppTheme.primaryNavy),
                          onPressed: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                            }
                          },
                        ),
                        Text(
                          "$_quantity",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.plusCircle, color: AppTheme.primaryNavy),
                          onPressed: () {
                            if (_quantity < 10) {
                              setState(() => _quantity++);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Floating Cart Summary Bar (appears when items are in cart)
        if (_cart.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentGold,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryNavy,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${_cart.length}",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Peti Tiket Anda (Cart)",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        Text(
                          "RM ${_getCartSubtotal().toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.primaryNavy.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _showCheckoutSheet,
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Checkout",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(LucideIcons.arrowRight, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Main Bottom Selection Action Bar
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
            border: const Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Selected Price",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    "RM ${selectedSubtotal.toStringAsFixed(2)}",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.plusCircle, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Add to Cart",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
