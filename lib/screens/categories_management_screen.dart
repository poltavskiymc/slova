import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/providers/category_provider.dart';
import 'package:slova/providers/settings_provider.dart';
import 'package:slova/providers/word_provider.dart';
import 'package:slova/models/category.dart';
import 'package:slova/screens/category_editor_screen.dart';

class CategoriesManagementScreen extends ConsumerStatefulWidget {
  const CategoriesManagementScreen({super.key});

  @override
  ConsumerState<CategoriesManagementScreen> createState() => _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState extends ConsumerState<CategoriesManagementScreen> {
  bool _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление категориями'),
        actions: [
          // Переключатель для показа только избранных
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
            },
            icon: Icon(
              _showOnlyFavorites ? Icons.star : Icons.star_border,
              color: _showOnlyFavorites ? Colors.amber : Colors.white,
            ),
            label: Text(
              _showOnlyFavorites ? 'Избранные' : 'Все',
              style: const TextStyle(color: Colors.white),
            ),
          ),
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
    // Фильтруем категории, исключая искусственные (например, "Все")
    final realCategories = categories.where((category) {
      // Исключаем категории без реального содержимого или искусственные
      // Пока просто исключаем категории с определенными именами
      return !['Все', 'All'].contains(category.name);
    }).toList();

    if (realCategories.isEmpty) {
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
      itemCount: realCategories.length,
      itemBuilder: (context, index) {
        final category = realCategories[index];
        return _buildCategoryCard(context, ref, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, WidgetRef ref, Category category) {
    final settings = ref.watch(userSettingsProvider);
    final isFavorite = settings.isCategoryFavorite(category.id!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: IconButton(
          onPressed: () async {
            final notifier = ref.read(userSettingsProvider.notifier);
            await notifier.toggleFavoriteCategory(category.id!);
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Показываем количество слов в категории
            Consumer(
              builder: (context, ref, child) {
                final wordCountAsync = ref.watch(wordCountByCategoryProvider(category.id!));
                return wordCountAsync.when(
                  data: (count) => Text(
                    '$count слов',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 40,
                    height: 12,
                    child: LinearProgressIndicator(),
                  ),
                  error: (error, stack) => const Text(
                    '? слов',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
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
          ],
        ),
        onTap: () => _editCategory(context, category),
      ),
    );
  }

  void _editCategory(BuildContext context, Category category) {
    print('CategoriesManagement: Editing category - id: ${category.id}, name: ${category.name}');
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

                // Обновляем все связанные провайдеры
                ref.invalidate(allCategoriesProvider);
                // Также инвалидируем счетчики слов для всех категорий
                // (в будущем можно оптимизировать, инвалидируя только для удаленной категории)

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
