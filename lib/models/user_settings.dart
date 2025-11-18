class UserSettings {
  final List<int> favoriteCategoryIds;
  final bool showTimer;
  final bool enableSound;
  final int roundDuration; // в секундах

  const UserSettings({
    this.favoriteCategoryIds = const [],
    this.showTimer = true,
    this.enableSound = true,
    this.roundDuration = 60, // 60 секунд по умолчанию
  });

  UserSettings copyWith({
    List<int>? favoriteCategoryIds,
    bool? showTimer,
    bool? enableSound,
    int? roundDuration,
  }) {
    return UserSettings(
      favoriteCategoryIds: favoriteCategoryIds ?? this.favoriteCategoryIds,
      showTimer: showTimer ?? this.showTimer,
      enableSound: enableSound ?? this.enableSound,
      roundDuration: roundDuration ?? this.roundDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favoriteCategoryIds': favoriteCategoryIds,
      'showTimer': showTimer,
      'enableSound': enableSound,
      'roundDuration': roundDuration,
    };
  }

  bool isCategoryFavorite(int categoryId) {
    return favoriteCategoryIds.contains(categoryId);
  }

  factory UserSettings.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final favoriteIds = json['favoriteCategoryIds'];
      final showTimer = json['showTimer'];
      final enableSound = json['enableSound'];
      final roundDuration = json['roundDuration'];

      return UserSettings(
        favoriteCategoryIds: favoriteIds is List
            ? favoriteIds.map((e) => e as int).toList()
            : [],
        showTimer: showTimer is bool ? showTimer : true,
        enableSound: enableSound is bool ? enableSound : true,
        roundDuration: roundDuration is int ? roundDuration : 60,
      );
    }
    return const UserSettings();
  }
}
