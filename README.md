# slova
The game words on the forehead

## Описание
Flutter приложение для игры "Слова на лбу" для Android и iOS.

## Требования
- Flutter SDK (последняя версия)
- Android Studio / Xcode (для разработки)
- Android SDK (для Android)
- Xcode (для iOS, только на macOS)

## Установка зависимостей
```bash
flutter pub get
```

## Запуск приложения

### Android
```bash
flutter run
```
или
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

## Сборка релизных версий

### Android
```bash
flutter build apk
```
или для App Bundle:
```bash
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

## Структура проекта
- `lib/main.dart` - главный файл приложения
- `android/` - конфигурация для Android
- `ios/` - конфигурация для iOS
- `pubspec.yaml` - зависимости проекта
