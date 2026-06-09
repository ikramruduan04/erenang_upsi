class Booking {
  final String id;
  final String name;
  final String userType; // 'Student/Staff' or 'Outsider'
  final DateTime bookingDate;
  final String status; // 'Pending', 'Approved', 'Cancelled'

  Booking({
    required this.id,
    required this.name,
    required this.userType,
    required this.bookingDate,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      name: json['name'],
      userType: json['user_type'],
      bookingDate: DateTime.parse(json['booking_date']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'user_type': userType,
      'booking_date': bookingDate.toIso8601String(),
      'status': status,
    };
  }
}
