import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as dev;
import '../models/booking.dart';

class DatabaseService {
  final _client = Supabase.instance.client;
  
  // Static in-memory database for mock fallback
  static final List<Booking> _mockBookings = [
    Booking(
      id: 'mock-1',
      name: 'Muhammad Ikram',
      email: 'ikram@upsi.edu.my',
      phone: '012-3456789',
      upsiId: 'D20211099231',
      userType: 'Student',
      poolType: 'Olympic Pool',
      bookingDate: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '08:00 AM - 10:00 AM',
      quantity: 2,
      totalPrice: 4.00, // RM 2.00 * 2
      status: 'Approved',
      qrCode: 'RENANG-MOCK-1',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Booking(
      id: 'mock-2',
      name: 'Dr. Ahmad Fauzi',
      email: 'fauzi@upsi.edu.my',
      phone: '019-8765432',
      upsiId: 'S88319',
      userType: 'Staff',
      poolType: 'Training Pool',
      bookingDate: DateTime.now().add(const Duration(days: 2)),
      timeSlot: '04:00 PM - 06:00 PM',
      quantity: 1,
      totalPrice: 3.00, // RM 3.00 * 1
      status: 'Pending',
      qrCode: 'RENANG-MOCK-2',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Booking(
      id: 'mock-3',
      name: 'Sarah Connor',
      email: 'sarah@gmail.com',
      phone: '011-2223334',
      upsiId: '',
      userType: 'Public',
      poolType: 'Kids Pool',
      bookingDate: DateTime.now().subtract(const Duration(days: 1)),
      timeSlot: '10:00 AM - 12:00 PM',
      quantity: 3,
      totalPrice: 15.00, // RM 5.00 * 3
      status: 'Checked In',
      qrCode: 'RENANG-MOCK-3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // Current session user details (Mock Auth)
  static Map<String, String> currentUser = {
    'name': 'Muhammad Ikram',
    'email': 'ikram@student.upsi.edu.my',
    'upsiId': 'D20211099231',
    'userType': 'Student',
  };

  static bool isUseLocalFallback = false;

  // READ
  Future<List<Booking>> getBookings() async {
    if (isUseLocalFallback) {
      return List.from(_mockBookings);
    }
    
    try {
      final response = await _client
          .from('bookings')
          .select()
          .order('booking_date', ascending: false);
      return (response as List).map((data) => Booking.fromJson(data)).toList();
    } catch (e) {
      dev.log("Supabase error. Falling back to local mock database: $e");
      isUseLocalFallback = true;
      return List.from(_mockBookings);
    }
  }

  // CREATE
  Future<void> createBooking(Booking booking) async {
    if (isUseLocalFallback) {
      _mockBookings.insert(0, booking);
      return;
    }

    try {
      await _client.from('bookings').insert(booking.toJson());
    } catch (e) {
      dev.log("Supabase error. Adding to local mock database: $e");
      isUseLocalFallback = true;
      _mockBookings.insert(0, booking);
    }
  }

  // UPDATE STATUS
  Future<void> updateBookingStatus(String id, String newStatus) async {
    if (isUseLocalFallback || id.startsWith('mock-')) {
      final index = _mockBookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        final old = _mockBookings[index];
        _mockBookings[index] = old.copyWith(status: newStatus);
      }
      return;
    }

    try {
      await _client.from('bookings').update({'status': newStatus}).eq('id', id);
    } catch (e) {
      dev.log("Supabase error. Updating local mock database: $e");
      final index = _mockBookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        final old = _mockBookings[index];
        _mockBookings[index] = old.copyWith(status: newStatus);
      }
    }
  }

  // DELETE
  Future<void> deleteBooking(String id) async {
    if (isUseLocalFallback || id.startsWith('mock-')) {
      _mockBookings.removeWhere((b) => b.id == id);
      return;
    }

    try {
      await _client.from('bookings').delete().eq('id', id);
    } catch (e) {
      dev.log("Supabase error. Deleting from local mock database: $e");
      _mockBookings.removeWhere((b) => b.id == id);
    }
  }

  // Set active mock user
  static void setMockUser(String name, String email, String upsiId, String userType) {
    currentUser = {
      'name': name,
      'email': email,
      'upsiId': upsiId,
      'userType': userType,
    };
  }
}

