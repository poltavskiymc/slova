import 'package:slova/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for Supabase operations
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  /// Check if user is authenticated
  bool get isAuthenticated => client.auth.currentUser != null;

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Sign out current user
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from(SupabaseConfig.tableProfiles)
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await client
          .from(SupabaseConfig.tableProfiles)
          .update(data)
          .eq('id', userId);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Sync local data to Supabase
  Future<void> syncData(Map<String, dynamic> data) async {
    // TODO: Implement data synchronization
    print('Syncing data to Supabase: $data');
  }

  /// Get data from Supabase
  Future<List<Map<String, dynamic>>> getData(
    String table, {
    Map<String, dynamic>? filters,
    String? select,
  }) async {
    try {
      var query = client.from(table).select(select ?? '*');

      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value as Object);
        });
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting data from $table: $e');
      return [];
    }
  }
}
