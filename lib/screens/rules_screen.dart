import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Правила игры'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎮 Правила игры "Слова на лбу"',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),

            // Основные правила
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📱 Как играть:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '1. Выберите категорию слов (Животные, Предметы, Профессии)\n'
                    '2. Выберите уровень сложности (Легкая, Средняя, Сложная, Все)\n'
                    '3. Телефон перейдет в горизонтальную ориентацию\n'
                    '4. На экране появится слово',
                    style: TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Управление игрой
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 Управление:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• Держите телефон ВЕРТИКАЛЬНО ребром на столе\n'
                    '• Положите экраном ВНИЗ = ОТГАДАЛ слово ✅\n'
                    '• Поднимите экраном ВВЕРХ = ПРОПУСТИЛ слово ❌\n'
                    '• Верните в ВЕРТИКАЛЬНОЕ положение для следующего слова',
                    style: TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Иллюстрации
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '📸 Визуальные примеры:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Исходное положение
                  Text(
                    '📱 Исходное положение:\n'
                    '████████████\n'
                    '██        ██\n'
                    '██  СЛОВО  ██\n'
                    '██        ██\n'
                    '████████████\n'
                    '(вертикально)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16),

                  // Отгадал
                  Text(
                    '✅ Отгадал слово:\n'
                    '████████████\n'
                    '████████████\n'
                    '████████████\n'
                    '████████████\n'
                    '████████████\n'
                    '(экраном вниз)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16),

                  // Пропустил
                  Text(
                    '❌ Пропустил слово:\n'
                    '████████████\n'
                    '██        ██\n'
                    '██        ██\n'
                    '██        ██\n'
                    '████████████\n'
                    '(экраном вверх)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Правила игры
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⏰ Правила игры:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• У вас есть 60 секунд на всю игру\n'
                    '• Каждое угаданное слово = +1 очко\n'
                    '• Каждое пропущенное слово = 0 очков\n'
                    '• После каждого действия обязательно вернитесь в вертикальное положение\n'
                    '• Игра закончится через 60 секунд или когда закончатся слова',
                    style: TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Советы
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Советы:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• Держите телефон устойчиво на столе\n'
                    '• Делайте движения уверенно и четко\n'
                    '• Не торопитесь - точность важнее скорости\n'
                    '• После каждого действия ждите следующего слова\n'
                    '• Попробуйте все уровни сложности!',
                    style: TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Призыв к действию
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('НАЧАТЬ ИГРУ!'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

