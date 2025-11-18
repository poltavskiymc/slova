import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/providers/settings_provider.dart';
import 'package:slova/screens/categories_management_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          // Управление категориями
          ListTile(
            leading: const Icon(Icons.category, color: Colors.blue),
            title: const Text('Управление категориями'),
            subtitle: const Text('Добавить, редактировать, удалять категории'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<Widget>(
                  builder: (context) => const CategoriesManagementScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Настройки игры
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Настройки игры',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          // Показывать таймер
          SwitchListTile(
            title: const Text('Показывать таймер'),
            subtitle: const Text('Отображение оставшегося времени'),
            value: settings.showTimer,
            onChanged: (value) async {
              await ref.read(userSettingsProvider.notifier).setShowTimer(value);
            },
          ),

          // Включить звук
          SwitchListTile(
            title: const Text('Звуки'),
            subtitle: const Text('Звуковые эффекты в игре'),
            value: settings.enableSound,
            onChanged: (value) async {
              await ref.read(userSettingsProvider.notifier).setEnableSound(value);
            },
          ),

          // Длительность раунда
          ListTile(
            title: const Text('Длительность раунда'),
            subtitle: Text('${settings.roundDuration} секунд'),
            trailing: DropdownButton<int>(
              value: settings.roundDuration,
              items: const [
                DropdownMenuItem(value: 30, child: Text('30 сек')),
                DropdownMenuItem(value: 45, child: Text('45 сек')),
                DropdownMenuItem(value: 60, child: Text('1 мин')),
                DropdownMenuItem(value: 90, child: Text('1.5 мин')),
                DropdownMenuItem(value: 120, child: Text('2 мин')),
              ],
              onChanged: (value) async {
                if (value != null) {
                  await ref.read(userSettingsProvider.notifier).setRoundDuration(value);
                }
              },
            ),
          ),

          const Divider(),

          // Информация о приложении
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'О приложении',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          const ListTile(
            leading: Icon(Icons.info, color: Colors.grey),
            title: Text('Версия'),
            subtitle: Text('1.0.0'),
          ),

          const ListTile(
            leading: Icon(Icons.description, color: Colors.grey),
            title: Text('Описание'),
            subtitle: Text('Игра "Слова на лбу" с управлением наклонами телефона'),
          ),
        ],
      ),
    );
  }
}

