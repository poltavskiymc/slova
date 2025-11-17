import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/providers/category_provider.dart';
import 'package:slova/providers/settings_provider.dart';
import 'package:slova/models/category.dart';
import 'package:slova/screens/category_editor_screen.dart';

class CategoriesManagementScreen extends ConsumerWidget {
  const CategoriesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление категориями'),
        actions: [
          IconButton(
            onPressed: () {
              // Создать новую категорию
              Navigator.push(
                context,
                MaterialPageRoute<Widget>(
                  builder: (context) => const CategoryEditorScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Создать категорию',
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) => _buildCategoriesList(context, ref, categories),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка: $error'),
        ),
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, WidgetRef ref, List<Category> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'Категорий пока нет\nНажмите + чтобы создать первую',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, ref, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, WidgetRef ref, Category category) {
    final settingsNotifier = ref.watch(userSettingsProvider.notifier);
    final isFavorite = settingsNotifier.isCategoryFavorite(category.id!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: IconButton(
          onPressed: () {
            ref.read(userSettingsProvider.notifier).toggleFavoriteCategory(category.id!);
          },
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.amber : Colors.grey,
          ),
          tooltip: isFavorite ? 'Убрать из избранного' : 'Добавить в избранное',
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isFavorite ? '⭐ В избранном' : 'Обычная категория',
          style: TextStyle(
            color: isFavorite ? Colors.amber.shade700 : Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editCategory(context, category);
                break;
              case 'delete':
                _deleteCategory(context, ref, category);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Редактировать'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Удалить', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _editCategory(context, category),
      ),
    );
  }

  void _editCategory(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (context) => CategoryEditorScreen(category: category),
      ),
    );
  }

  void _deleteCategory(BuildContext context, WidgetRef ref, Category category) {
    showDialog<Widget>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить категорию?'),
        content: Text('Вы уверены, что хотите удалить категорию "${category.name}"? Все слова в этой категории также будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Удаляем категорию из базы данных
                await ref.read(categoryRepositoryProvider).deleteCategory(category.id!);

                // Обновляем список категорий
                ref.invalidate(allCategoriesProvider);

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Категория "${category.name}" удалена')),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка удаления: $e')),
                );
              }
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
