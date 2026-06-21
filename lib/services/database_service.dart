import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as dev;
import '../models/booking.dart';
import '../models/announcement.dart';

class DatabaseService {
  static final _client = Supabase.instance.client;

  // --- AUTHENTICATION ---

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  static User? get currentUser => _client.auth.currentUser;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
    String upsiId = '',
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'user_type': userType,
        'upsi_id': upsiId,
        'role': 'user', // Default role
      },
    );
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // --- PROFILES ---

  static Future<Map<String, dynamic>?> getProfile([String? userId]) async {
    try {
      final id = userId ?? currentUser?.id;
      if (id == null) return null;

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      dev.log("Error fetching profile: $e");
      return null;
    }
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final id = currentUser?.id;
      if (id == null) return;
      await _client.from('profiles').update(data).eq('id', id);
    } catch (e) {
      dev.log("Error updating profile: $e");
      throw Exception('Failed to update profile');
    }
  }

  static Future<bool> isAdmin() async {
    final profile = await getProfile();
    return profile?['role'] == 'admin';
  }

  // --- BOOKINGS ---

  static Future<List<Booking>> getBookings() async {
    try {
      final admin = await isAdmin();

      var query = _client.from('bookings').select();

      if (!admin && currentUser != null) {
        query = query.eq('user_id', currentUser!.id);
      }

      final response = await query.order('booking_date', ascending: false);
      return (response as List).map((data) => Booking.fromJson(data)).toList();
    } catch (e) {
      dev.log("Error fetching bookings: $e");
      return [];
    }
  }

  static Future<void> createBooking(Booking booking) async {
    try {
      final bookingData = booking.toJson();
      if (currentUser != null) {
        bookingData['user_id'] = currentUser!.id;
      }
      await _client.from('bookings').insert(bookingData);
    } catch (e) {
      dev.log("Error creating booking: $e");
      throw Exception('Failed to create booking');
    }
  }

  static Future<void> updateBookingStatus(String id, String newStatus) async {
    try {
      await _client.from('bookings').update({'status': newStatus}).eq('id', id);
    } catch (e) {
      dev.log("Error updating booking status: $e");
      throw Exception('Failed to update status');
    }
  }

  static Future<void> deleteBooking(String id) async {
    try {
      await _client.from('bookings').delete().eq('id', id);
    } catch (e) {
      dev.log("Error deleting booking: $e");
      throw Exception('Failed to delete booking');
    }
  }

  // --- ANNOUNCEMENTS ---

  static Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await _client
          .from('announcements')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((data) => Announcement.fromJson(data))
          .toList();
    } catch (e) {
      dev.log("Error fetching announcements: $e");
      return [];
    }
  }

  static Future<void> createAnnouncement(Announcement announcement) async {
    try {
      final data = announcement.toJson();
      if (currentUser != null) {
        data['created_by'] = currentUser!.id;
      }
      await _client.from('announcements').insert(data);
    } catch (e) {
      dev.log("Error creating announcement: $e");
      throw Exception('Failed to create announcement');
    }
  }

  static Future<void> updateAnnouncement(
    String id,
    String title,
    String content,
  ) async {
    try {
      await _client
          .from('announcements')
          .update({'title': title, 'content': content})
          .eq('id', id);
    } catch (e) {
      dev.log("Error updating announcement: $e");
      throw Exception('Failed to update announcement');
    }
  }

  static Future<void> deleteAnnouncement(String id) async {
    try {
      await _client.from('announcements').delete().eq('id', id);
    } catch (e) {
      dev.log("Error deleting announcement: $e");
      throw Exception('Failed to delete announcement');
    }
  }
}
