import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/models/category.dart';
import 'package:slova/providers/category_provider.dart';
import 'package:slova/providers/settings_provider.dart';
import 'package:slova/screens/difficulty_selection_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final settings = ref.watch(userSettingsProvider);

    return categoriesAsync.when(
      data: (categories) {
        // Сортируем категории: избранные первыми
        final sortedCategories = List<Category>.from(categories)
          ..sort((a, b) {
            final aIsFavorite = settings.isCategoryFavorite(a.id ?? -1);
            final bIsFavorite = settings.isCategoryFavorite(b.id ?? -1);

            if (aIsFavorite && !bIsFavorite) return -1;
            if (!aIsFavorite && bIsFavorite) return 1;
            return 0; // Сохраняем порядок для категорий с одинаковым статусом избранного
          });
        if (sortedCategories.isEmpty) {
          return const Center(
            child: Text(
              'Категории пока не добавлены',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Две колонки
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1, // Квадратные кнопки
          ),
          itemCount: sortedCategories.length,
          itemBuilder: (context, index) {
            final category = sortedCategories[index];
            final isFavorite = settings.isCategoryFavorite(category.id ?? -1);

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  InkWell(
                    onTap: () {
                      if (category.id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute<Widget>(
                            builder: (context) => DifficultySelectionScreen(
                              categoryId: category.id!,
                              categoryName: category.name,
                            ),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getCategoryIcon(category.name),
                            size: 48,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isFavorite)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Ошибка: $error'),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'животные':
        return Icons.pets;
      case 'предметы':
        return Icons.inventory_2;
      case 'профессии':
        return Icons.work;
      default:
        return Icons.category;
    }
  }
}
