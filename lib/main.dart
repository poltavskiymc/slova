import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/config/supabase_config.dart';
import 'package:slova/screens/main_screen.dart';
import 'package:slova/services/data_initializer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Устанавливаем портретную ориентацию по умолчанию для всего приложения
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Инициализируем Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Инициализируем сервис данных
  final dataInitializer = DataInitializer();

  // Синхронизируем данные с Supabase (если доступно)
  try {
    print('🔄 Syncing data with Supabase...');

    final supabaseClient = Supabase.instance.client;

    // Загружаем системные категории
    final categoriesResponse = await supabaseClient
        .from(SupabaseConfig.tableSystemCategories)
        .select('id, name, description')
        .eq('is_active', true)
        .timeout(const Duration(seconds: 10));

    print('📊 Loaded ${categoriesResponse.length} categories from Supabase');

    // Загружаем системные слова
    final wordsResponse = await supabaseClient
        .from(SupabaseConfig.tableSystemWords)
        .select('id, category_id, text, difficulty')
        .timeout(const Duration(seconds: 10));

    print('📝 Loaded ${wordsResponse.length} words from Supabase');

    // Синхронизируем с локальной БД
    await dataInitializer.syncFromSupabase(categoriesResponse, wordsResponse);
  } catch (e) {
    print('⚠️ Supabase sync failed: $e');
    print('📱 App will continue with local SQLite database only');
  }

  // Инициализируем локальные данные (если нужно)
  await dataInitializer.initializeData();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slova',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
