import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:slova/models/word.dart';
import 'package:slova/models/game_result.dart';
import 'package:slova/providers/settings_provider.dart';
import 'package:slova/screens/game_result_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int categoryId;
  final String categoryName;
  final Difficulty difficulty;
  final List<Word> gameWords;

  GameScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.difficulty,
    required this.gameWords,
  }) {
    developer
        .log('GameScreen: Constructor called with ${gameWords.length} words');
  }

  @override
  ConsumerState<GameScreen> createState() {
    developer.log('GameScreen: createState called');
    return _GameScreenState();
  }
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  // Игровая логика
  List<Word> _gameWords = [];
  int _currentWordIndex = 0;
  List<Word> _guessedWords = [];
  List<Word> _skippedWords = [];

  // Таймер
  Timer? _gameTimer;
  int _remainingSeconds = 60; // Дефолтное значение, будет обновлено из настроек
  int _initialRoundDuration =
      60; // Сохраняем начальную длительность для расчета totalTime
  bool _gameStarted = false;

  // Таймеры для звуков окончания игры
  List<Timer> _endGameSoundTimers = [];

  // Обратный отсчет
  int _countdown = 3;
  bool _showCountdown = true;

  // Сенсоры
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _lastZ =
      0; // ignore: unused_field - используется для отслеживания предыдущего значения Z

  // Состояние телефона
  bool _waitingForReset = false; // Ждем возврата в вертикальное положение
  String _feedbackMessage = ''; // Сообщение обратной связи

  // Анимации
  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;
  Color _flashColor = Colors.transparent;

  // Аудио
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Устанавливаем горизонтальную ориентацию
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initializeGame();
    _setupSensors();
    _setupAnimations();
  }

  void _initializeGame() {
    developer.log(
        'GameScreen: Initializing game with ${widget.gameWords.length} words');

    // Логируем каждое слово для отладки
    for (int i = 0; i < widget.gameWords.length; i++) {
      developer.log('GameScreen: Word $i: ${widget.gameWords[i].text}');
    }

    // Проверяем, что слова загружены
    if (widget.gameWords.isEmpty) {
      developer.log('GameScreen: ERROR - No words loaded!');
      // Если слов нет, показываем ошибку и возвращаемся
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: слова не загружены')),
        );
        Navigator.of(context).pop();
      });
      return;
    }

    // Слова уже переданы через конструктор
    _gameWords = List.from(widget.gameWords)..shuffle();
    developer.log(
        'GameScreen: Game words shuffled (${_gameWords.length} words), starting countdown');

    // Запускаем обратный отсчет
    _startCountdown();
  }

  void _startCountdown() {
    developer.log('GameScreen: Starting countdown from $_countdown');
    Timer.periodic(const Duration(seconds: 1), (timer) {
      developer.log('GameScreen: Countdown: $_countdown');
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        developer.log('GameScreen: Countdown finished, starting game');
        timer.cancel();
        setState(() {
          _showCountdown = false;
        });
        _startGame();
      }
    });
  }

  void _startGame() {
    developer.log('GameScreen: Starting game with ${_gameWords.length} words');
    setState(() {
      _gameStarted = true;
    });

    // Запускаем таймер игры
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        developer.log('GameScreen: Time is up, ending game');
        _endGame();
      }
    });
  }

  void _setupSensors() {
    try {
      _accelerometerSubscription = accelerometerEvents.listen((event) {
        if (!_gameStarted || _showCountdown) return;

        // Логируем все оси для отладки
        developer.log(
            'GameScreen: Accelerometer - X: ${event.x.toStringAsFixed(2)}, Y: ${event.y.toStringAsFixed(2)}, Z: ${event.z.toStringAsFixed(2)}');

        // Определяем текущее положение телефона
        final currentZ = event.z;
        final isVertical = currentZ.abs() < 3.0; // Плюс-минус вертикально
        final isScreenDown = currentZ < -5.0; // Экран вниз
        final isScreenUp = currentZ > 5.0; // Экран вверх

        developer.log(
            'GameScreen: Position - Vertical: $isVertical, ScreenDown: $isScreenDown, ScreenUp: $isScreenUp, WaitingReset: $_waitingForReset');

        // Если ждем сброса в вертикальное положение
        if (_waitingForReset) {
          if (isVertical) {
            developer.log(
                'GameScreen: Position reset to vertical, ready for next action');
            setState(() {
              _waitingForReset = false;
              _feedbackMessage = '';
            });
          }
          return; // Игнорируем движения пока не вернемся в вертикальное положение
        }

        // Телефон кладется экраном вниз - отгадано
        if (isScreenDown) {
          developer.log(
              'GameScreen: Phone laid down screen-down (Z: ${currentZ.toStringAsFixed(2)})');
          _wordGuessed();
        }
        // Телефон поднимается экраном вверх - пропущено
        else if (isScreenUp) {
          developer.log(
              'GameScreen: Phone lifted up screen-up (Z: ${currentZ.toStringAsFixed(2)})');
          _wordSkipped();
        }

        _lastZ = currentZ;
      });
    } catch (e) {
      developer.log('GameScreen: Error setting up sensors: $e');
      // Продолжаем без датчиков
    }
  }

  void _setupAnimations() {
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flashAnimation = ColorTween(
      begin: Colors.transparent,
      end: _flashColor,
    ).animate(_flashController);

    _flashController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _playSound(String soundName) async {
    try {
      // Проверяем, что AudioPlayer еще не disposed
      if (_audioPlayer.state == PlayerState.disposed) {
        return;
      }

      await _audioPlayer.stop(); // Останавливаем предыдущий звук
      await _audioPlayer.setSource(AssetSource('audio/$soundName.mp3'));
      await _audioPlayer.resume();

      // Для колокольчика играем только первые 2.5 секунды
      if (soundName == 'beep') {
        Timer(const Duration(milliseconds: 2500), () async {
          try {
            if (_audioPlayer.state != PlayerState.disposed) {
              await _audioPlayer.stop();
            }
          } catch (e) {
            // Игнорируем ошибки остановки
          }
        });
      }
    } catch (e) {
      // Игнорируем ошибки воспроизведения
      debugPrint('Ошибка воспроизведения звука $soundName: $e');
    }
  }

  void _wordGuessed() {
    if (_currentWordIndex >= _gameWords.length) return;

    developer
        .log('GameScreen: Word guessed: ${_gameWords[_currentWordIndex].text}');

    setState(() {
      _guessedWords.add(_gameWords[_currentWordIndex]);
      _currentWordIndex++;
      _waitingForReset = true; // Ждем возврата в вертикальное положение
      _feedbackMessage = 'ВЕРНО';
      _flashColor = Colors.green.withOpacity(0.7);
    });

    _flashController.forward(from: 0.0);

    // Переходим к следующему слову через небольшую задержку
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_currentWordIndex >= _gameWords.length) {
        _endGame();
      }
    });
  }

  void _wordSkipped() {
    if (_currentWordIndex >= _gameWords.length) return;

    developer
        .log('GameScreen: Word skipped: ${_gameWords[_currentWordIndex].text}');

    setState(() {
      _skippedWords.add(_gameWords[_currentWordIndex]);
      _currentWordIndex++;
      _waitingForReset = true; // Ждем возврата в вертикальное положение
      _feedbackMessage = 'ПРОПУЩЕНО';
      _flashColor = Colors.red.withOpacity(0.7);
    });

    _flashController.forward(from: 0.0);

    // Переходим к следующему слову через небольшую задержку
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_currentWordIndex >= _gameWords.length) {
        _endGame();
      }
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _accelerometerSubscription?.cancel();

    // Звуковые сигналы окончания
    _playEndGameSounds();

    // Показываем результаты
    final result = GameResult(
      guessedWords: _guessedWords,
      skippedWords: _skippedWords,
      totalTime: _initialRoundDuration - _remainingSeconds,
      categoryId: widget.categoryId,
      categoryName: widget.categoryName,
      difficulty: widget.difficulty.name,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<Widget>(
            builder: (context) => GameResultScreen(result: result),
          ),
        );
      }
    });
  }

  void _playEndGameSounds() {
    // Очищаем предыдущие таймеры
    for (final timer in _endGameSoundTimers) {
      timer.cancel();
    }
    _endGameSoundTimers.clear();

    // Три звуковых сигнала колокольчика с паузами
    _endGameSoundTimers.add(
        Timer(const Duration(milliseconds: 500), () => _playSound('beep')));
    _endGameSoundTimers.add(
        Timer(const Duration(milliseconds: 3500), () => _playSound('beep')));
    _endGameSoundTimers.add(
        Timer(const Duration(milliseconds: 6500), () => _playSound('beep')));
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _accelerometerSubscription?.cancel();

    // Отменяем таймеры звуков окончания игры
    for (final timer in _endGameSoundTimers) {
      timer.cancel();
    }
    _endGameSoundTimers.clear();

    _flashController.dispose();
    _audioPlayer.dispose();

    // Восстанавливаем портретную ориентацию
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);

    // Инициализируем время раунда из настроек (до начала игры)
    if (!_gameStarted) {
      _remainingSeconds = settings.roundDuration;
      _initialRoundDuration = settings.roundDuration;
    }

    developer.log(
        'GameScreen: Building UI - countdown: $_countdown, showCountdown: $_showCountdown, gameStarted: $_gameStarted, currentWord: $_currentWordIndex/${_gameWords.length}');

    return Scaffold(
      backgroundColor: _flashAnimation.value ?? Colors.black,
      body: Stack(
        children: [
          // Основной контент
          Center(
            child: _showCountdown ? _buildCountdown() : _buildGameContent(),
          ),

          // Таймер в правом верхнем углу
          if (_gameStarted)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Прогресс в левом верхнем углу
          if (_gameStarted)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentWordIndex + 1}/${_gameWords.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    developer.log('GameScreen: Building countdown: $_countdown');
    return Text(
      _countdown.toString(),
      style: const TextStyle(
        fontSize: 120,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildGameContent() {
    if (_currentWordIndex >= _gameWords.length) {
      developer.log('GameScreen: Building end game screen');
      return const Text(
        'КОНЕЦ ИГРЫ',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }

    // Если ждем сброса положения, показываем сообщение обратной связи
    if (_waitingForReset && _feedbackMessage.isNotEmpty) {
      developer.log('GameScreen: Building feedback message: $_feedbackMessage');
      return Text(
        _feedbackMessage,
        style: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: _feedbackMessage == 'ВЕРНО' ? Colors.green : Colors.red,
          letterSpacing: 8,
        ),
        textAlign: TextAlign.center,
      );
    }

    final currentWord = _gameWords[_currentWordIndex].text;
    developer.log('GameScreen: Building word display: $currentWord');
    return Text(
      currentWord,
      style: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 8,
      ),
      textAlign: TextAlign.center,
    );
  }
}
