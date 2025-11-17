import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/models/category.dart';
import 'package:slova/repositories/category_repository.dart';
import 'package:slova/providers/database_provider.dart';

// Repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  // Ensure database is initialized first
  await ref.watch(databaseProvider.future);
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getAllCategories();
});

// Single category provider
final categoryProvider = FutureProvider.family<Category?, int>((ref, categoryId) async {
  // Ensure database is initialized first
  await ref.watch(databaseProvider.future);
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategory(categoryId);
});

// Alias for categoriesProvider (backward compatibility)
final allCategoriesProvider = categoriesProvider;