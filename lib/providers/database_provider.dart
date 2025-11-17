import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/services/database_service.dart';
import 'package:slova/services/data_initializer.dart';

// Provider for database initialization and data seeding
final databaseProvider = FutureProvider<void>((ref) async {
  await DatabaseService.database;
  final dataInitializer = DataInitializer();
  await dataInitializer.initializeData();
});
