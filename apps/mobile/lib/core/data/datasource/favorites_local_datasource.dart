import 'package:shared_preferences/shared_preferences.dart';

/// Local datasource for favorites using SharedPreferences
class FavoritesLocalDataSource {
  final SharedPreferences _prefs;
  static const _key = 'favorite_pokemon_ids';

  FavoritesLocalDataSource(this._prefs);

  /// Get all favorite Pokemon IDs
  Future<Set<int>> getFavoriteIds() async {
    final stringIds = _prefs.getStringList(_key) ?? [];
    return stringIds.map((id) => int.parse(id)).toSet();
  }

  /// Add a Pokemon to favorites
  Future<void> addFavorite(int id) async {
    final ids = await getFavoriteIds();
    ids.add(id);
    await _prefs.setStringList(_key, ids.map((id) => id.toString()).toList());
  }

  /// Remove a Pokemon from favorites
  Future<void> removeFavorite(int id) async {
    final ids = await getFavoriteIds();
    ids.remove(id);
    await _prefs.setStringList(_key, ids.map((id) => id.toString()).toList());
  }

  /// Check if a Pokemon is favorited
  Future<bool> isFavorite(int id) async {
    final ids = await getFavoriteIds();
    return ids.contains(id);
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(int id) async {
    final isFav = await isFavorite(id);
    if (isFav) {
      await removeFavorite(id);
      return false;
    } else {
      await addFavorite(id);
      return true;
    }
  }

  /// Clear all favorites
  Future<void> clearAll() async {
    await _prefs.remove(_key);
  }
}
