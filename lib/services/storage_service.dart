import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

/// Local storage (SharedPreferences): favorit, riwayat, lokasi terakhir.
class StorageService {
  static const _favKey = 'favorites';
  static const _historyKey = 'history';
  static const _selectedKey = 'selected_location';

  final SharedPreferences _prefs;
  StorageService(this._prefs);

  List<LocationModel> loadFavorites() {
    final raw = _prefs.getStringList(_favKey) ?? [];
    return raw
        .map((e) => LocationModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<LocationModel> list) {
    return _prefs.setStringList(
        _favKey, list.map((e) => jsonEncode(e.toJson())).toList());
  }

  List<String> loadHistory() => _prefs.getStringList(_historyKey) ?? [];

  Future<void> saveHistory(List<String> list) =>
      _prefs.setStringList(_historyKey, list);

  LocationModel? loadSelectedLocation() {
    final raw = _prefs.getString(_selectedKey);
    if (raw == null) return null;
    return LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSelectedLocation(LocationModel l) =>
      _prefs.setString(_selectedKey, jsonEncode(l.toJson()));
}
