import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Правила игры'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Правила игры "Слова на лбу"',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Как играть:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. Выберите категорию и уровень сложности\n'
              '2. На экране телефона появится слово\n'
              '3. Держите телефон на лбу так, чтобы другие игроки видели слово\n'
              '4. Задавайте вопросы, чтобы угадать слово\n'
              '5. Другие игроки могут отвечать только "да" или "нет"\n'
              '6. Угадайте слово как можно быстрее!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Советы:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Начните с общих вопросов (живое/неживое, предмет/животное и т.д.)\n'
              '• Используйте вопросы о размере, цвете, месте\n'
              '• Не бойтесь задавать уточняющие вопросы',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

