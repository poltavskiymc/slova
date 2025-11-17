import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slova/models/user_settings.dart';

// Provider для настроек пользователя
final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  return UserSettingsNotifier();
});

class UserSettingsNotifier extends StateNotifier<UserSettings> {
  UserSettingsNotifier() : super(const UserSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('user_settings');
    if (settingsJson != null) {
      try {
        state = UserSettings.fromJson(settingsJson as Map<String, dynamic>);
      } catch (e) {
        // Если не удалось загрузить, используем настройки по умолчанию
        state = const UserSettings();
      }
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_settings', state.toJson().toString());
  }

  void toggleFavoriteCategory(int categoryId) {
    final isFavorite = state.favoriteCategoryIds.contains(categoryId);
    final newFavorites = List<int>.from(state.favoriteCategoryIds);

    if (isFavorite) {
      newFavorites.remove(categoryId);
    } else {
      newFavorites.add(categoryId);
    }

    state = state.copyWith(favoriteCategoryIds: newFavorites);
    _saveSettings();
  }

  void setShowTimer(bool value) {
    state = state.copyWith(showTimer: value);
    _saveSettings();
  }

  void setEnableSound(bool value) {
    state = state.copyWith(enableSound: value);
    _saveSettings();
  }

  bool isCategoryFavorite(int categoryId) {
    return state.favoriteCategoryIds.contains(categoryId);
  }
}
