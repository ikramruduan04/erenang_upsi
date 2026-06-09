import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';

class DatabaseService {
  final _client = Supabase.instance.client;

  // READ
  Future<List<Booking>> getBookings() async {
    final response = await _client
        .from('bookings')
        .select()
        .order('booking_date');
    return (response as List).map((data) => Booking.fromJson(data)).toList();
  }

  // CREATE
  Future<void> createBooking(Booking booking) async {
    await _client.from('bookings').insert(booking.toJson());
  }

  // UPDATE
  Future<void> updateBookingStatus(String id, String newStatus) async {
    await _client.from('bookings').update({'status': newStatus}).eq('id', id);
  }

  // DELETE
  Future<void> deleteBooking(String id) async {
    await _client.from('bookings').delete().eq('id', id);
  }
}
