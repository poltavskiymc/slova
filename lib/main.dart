import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slova/screens/main_screen.dart';
import 'package:slova/services/data_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем данные при первом запуске
  final dataInitializer = DataInitializer();
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
