class UserSettings {
  final List<int> favoriteCategoryIds;
  final bool showTimer;
  final bool enableSound;

  const UserSettings({
    this.favoriteCategoryIds = const [],
    this.showTimer = true,
    this.enableSound = true,
  });

  UserSettings copyWith({
    List<int>? favoriteCategoryIds,
    bool? showTimer,
    bool? enableSound,
  }) {
    return UserSettings(
      favoriteCategoryIds: favoriteCategoryIds ?? this.favoriteCategoryIds,
      showTimer: showTimer ?? this.showTimer,
      enableSound: enableSound ?? this.enableSound,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favoriteCategoryIds': favoriteCategoryIds,
      'showTimer': showTimer,
      'enableSound': enableSound,
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

      return UserSettings(
        favoriteCategoryIds: favoriteIds is List ? favoriteIds.map((e) => e as int).toList() : [],
        showTimer: showTimer is bool ? showTimer : true,
        enableSound: enableSound is bool ? enableSound : true,
      );
    }
    return const UserSettings();
  }
}
