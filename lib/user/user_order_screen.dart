import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_theme.dart';
import '../models/booking.dart';
import '../services/database_service.dart';

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
  String _selectedPool = 'Olympic Pool';
  DateTime _selectedDate = DateTime.now();
  String _selectedSlot = '08:00 AM - 10:00 AM';
  int _quantity = 1;

  // Coupon State
  final _promoController = TextEditingController();
  double _discountPercentage = 0.0;
  double _flatDiscount = 0.0;
  String? _appliedPromoCode;
  String? _promoError;

  // Pool Catalog Data
  final List<Map<String, dynamic>> _pools = [
    {
      'name': 'Olympic Pool',
      'icon': LucideIcons.trophy,
      'depth': '1.8m - 2.2m',
      'desc': '8-lane professional swimming pool. Perfect for athletic training and lap swimming.',
      'prices': {'Student': 2.00, 'Staff': 3.00, 'Public': 5.00},
    },
    {
      'name': 'Training Pool',
      'icon': LucideIcons.compass,
      'depth': '1.2m - 1.5m',
      'desc': 'Ideal for beginners and learners. Semi-sheltered with coaching support available.',
      'prices': {'Student': 1.50, 'Staff': 2.50, 'Public': 4.00},
    },
    {
      'name': 'Kids Pool',
      'icon': LucideIcons.smile,
      'depth': '0.4m - 0.8m',
      'desc': 'Shallow water fun zone with slides and interactive water play equipment.',
      'prices': {'Student': 1.00, 'Staff': 2.00, 'Public': 3.00},
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
    final pool = _pools.firstWhere((p) => p['name'] == _selectedPool);
    final String userType = DatabaseService.currentUser['userType'] ?? 'Student';
    return (pool['prices'] as Map<String, double>)[userType] ?? 5.00;
  }

  double _getSubtotal() {
    return _getPricePerTicket() * _quantity;
  }

  double _getDiscountAmount() {
    final subtotal = _getSubtotal();
    double discount = (subtotal * _discountPercentage) + _flatDiscount;
    if (discount > subtotal) discount = subtotal;
    return discount;
  }

  double _getTotalPrice() {
    final total = _getSubtotal() - _getDiscountAmount();
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

  void _showCheckoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final double subtotal = _getSubtotal();
            final double discount = _getDiscountAmount();
            final double total = _getTotalPrice();
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
                    "Booking Checkout",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Divider(height: 24, color: AppTheme.border),

                  // Booking summary details
                  _buildSummaryRow("Pool Lane", _selectedPool),
                  _buildSummaryRow(
                    "Date",
                    "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  ),
                  _buildSummaryRow("Time Slot", _selectedSlot),
                  _buildSummaryRow("Quantity", "$_quantity x RM ${ListTile(title: Text('')).title != null ? _getPricePerTicket().toStringAsFixed(2) : ''}"),
                  const SizedBox(height: 16),

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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
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
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    final currentUser = DatabaseService.currentUser;
    final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    final uniqueId = 'B-${timeStamp.substring(timeStamp.length - 6)}';
    
    // Create new booking object
    final newBooking = Booking(
      id: uniqueId,
      name: currentUser['name'] ?? 'Guest',
      email: currentUser['email'] ?? 'guest@upsi.edu.my',
      phone: '01X-XXX XXXX',
      upsiId: currentUser['upsiId'] ?? '',
      userType: currentUser['userType'] ?? 'Public',
      poolType: _selectedPool,
      bookingDate: _selectedDate,
      timeSlot: _selectedSlot,
      quantity: _quantity,
      totalPrice: _getTotalPrice(),
      status: 'Approved', // Auto-approved for demo purposes
      qrCode: 'UP-$uniqueId-${_selectedPool.substring(0, 3).toUpperCase()}',
      createdAt: DateTime.now(),
    );

    // Write to database (will fall back to memory automatically)
    await DatabaseService().createBooking(newBooking);

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
                "Booking Confirmed!",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your swimming pass has been generated. Show the QR ticket at the pool entrance.",
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
    final double subtotal = _getSubtotal();

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
                // 1. SELECT POOL CATEGORY
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
                    final priceMap = pool['prices'] as Map<String, double>;
                    final userType = DatabaseService.currentUser['userType'] ?? 'Student';
                    final price = priceMap[userType] ?? 5.00;

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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        name,
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        "RM ${price.toStringAsFixed(2)}",
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryNavy,
                                        ),
                                      ),
                                    ],
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
                const SizedBox(height: 16),

                // 2. SELECT TIME SLOT
                Text(
                  "2. Select Session Time",
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
                const SizedBox(height: 24),

                // 3. SELECT QUANTITY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "3. Ticket Quantity",
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

        // Floating Booking Cart Bar (ZUS style slide bar)
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
                    "Total Price",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    "RM ${subtotal.toStringAsFixed(2)}",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _showCheckoutSheet,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.shoppingBag, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Check Out",
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
