import 'package:flutter/material.dart';
import 'package:slova/config/supabase_config.dart';
import 'package:slova/screens/rules_screen.dart';
import 'package:slova/screens/settings_screen.dart';
import 'package:slova/screens/categories_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isTestingConnection = false;

  Future<void> _testSupabaseConnection() async {
    if (_isTestingConnection) return;

    setState(() {
      _isTestingConnection = true;
    });

    try {
      print('🔍 Testing Supabase connection from UI...');

      final supabaseClient = Supabase.instance.client;

      // Проверяем системные категории
      final categoriesResponse = await supabaseClient
          .from(SupabaseConfig.tableSystemCategories)
          .select('name')
          .limit(3)
          .timeout(const Duration(seconds: 10));

      // Проверяем системные слова
      final wordsResponse = await supabaseClient
          .from(SupabaseConfig.tableSystemWords)
          .select('text')
          .limit(3)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      // Показываем успешный результат
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('✅ Подключение успешно!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📊 Категорий в БД: ${categoriesResponse.length}'),
              if (categoriesResponse.isNotEmpty)
                Text(
                    '📂 Примеры: ${categoriesResponse.map((c) => c['name']).join(', ')}'),
              const SizedBox(height: 8),
              Text('📝 Слов в БД: ${wordsResponse.length}'),
              if (wordsResponse.isNotEmpty)
                Text(
                    '📝 Примеры: ${wordsResponse.map((w) => w['text']).take(3).join(', ')}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Показываем ошибку
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Ошибка подключения'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTestingConnection = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Объяснилло'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Две верхние кнопки
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<Widget>(
                          builder: (context) => const RulesScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Правила',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<Widget>(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Настройки',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Список категорий
          const Expanded(
            child: CategoriesScreen(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isTestingConnection ? null : _testSupabaseConnection,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isTestingConnection
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('🔍 Проверить Supabase'),
            ),
          ),
        ],
      ),
    );
  }
}
