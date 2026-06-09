class Booking {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? upsiId; // Student or Staff ID
  final String userType; // 'Student', 'Staff', 'Public'
  final String poolType; // 'Olympic Pool', 'Training Pool', 'Kids Pool'
  final DateTime bookingDate;
  final String timeSlot; // e.g. "08:00 AM - 10:00 AM"
  final int quantity;
  final double totalPrice;
  final String status; // 'Pending', 'Approved', 'Checked In', 'Cancelled'
  final String qrCode;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.upsiId,
    required this.userType,
    required this.poolType,
    required this.bookingDate,
    required this.timeSlot,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.qrCode,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      upsiId: json['upsi_id'],
      userType: json['user_type'] ?? 'Public',
      poolType: json['pool_type'] ?? 'Olympic Pool',
      bookingDate: DateTime.parse(json['booking_date'] ?? DateTime.now().toIso8601String()),
      timeSlot: json['time_slot'] ?? '08:00 AM - 10:00 AM',
      quantity: json['quantity'] != null ? (json['quantity'] as num).toInt() : 1,
      totalPrice: json['total_price'] != null ? (json['total_price'] as num).toDouble() : 0.0,
      status: json['status'] ?? 'Pending',
      qrCode: json['qr_code'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'upsi_id': upsiId,
      'user_type': userType,
      'pool_type': poolType,
      'booking_date': bookingDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'time_slot': timeSlot,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': status,
      'qr_code': qrCode,
    };
  }

  Booking copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? upsiId,
    String? userType,
    String? poolType,
    DateTime? bookingDate,
    String? timeSlot,
    int? quantity,
    double? totalPrice,
    String? status,
    String? qrCode,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      upsiId: upsiId ?? this.upsiId,
      userType: userType ?? this.userType,
      poolType: poolType ?? this.poolType,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

