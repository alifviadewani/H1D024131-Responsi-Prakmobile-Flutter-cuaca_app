import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/open_meteo_service.dart';
import '../services/storage_service.dart';
import 'weather_viewmodel.dart';

/// ViewModel untuk Search / Location Screen.
class LocationViewModel extends ChangeNotifier {
  final OpenMeteoService _service;
  final StorageService _storage;

  LocationViewModel(this._service, this._storage);

  ViewState _state = ViewState.initial;
  List<LocationModel> _results = [];
  List<LocationModel> _favorites = [];
  List<String> _history = [];
  String _errorMessage = '';
  String _query = '';
  Timer? _debounce;
  int _requestId = 0; // mencegah respons lama menimpa respons baru

  ViewState get state => _state;
  List<LocationModel> get results => _results;
  List<LocationModel> get favorites => _favorites;
  List<String> get history => _history;
  String get errorMessage => _errorMessage;
  String get query => _query;

  void init() {
    _favorites = _storage.loadFavorites();
    _history = _storage.loadHistory();
    notifyListeners();
  }

  /// Dipanggil setiap teks berubah (debounce 500 ms).
  void onQueryChanged(String text) {
    _query = text.trim();
    _debounce?.cancel();
    if (_query.length < 2) {
      _requestId++;
      _results = [];
      _state = ViewState.initial;
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => search(_query));
  }

  Future<void> search(String name) async {
    final keyword = name.trim();
    if (keyword.length < 2) return;
    _debounce?.cancel();
    final id = ++_requestId;
    _query = keyword;
    _state = ViewState.loading;
    notifyListeners();
    try {
      final data = await _service.searchLocations(keyword);
      if (id != _requestId) return;
      _results = data;
      _state = data.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiException catch (e) {
      if (id != _requestId) return;
      _errorMessage = e.message;
      _state = ViewState.error;
    } catch (_) {
      if (id != _requestId) return;
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _state = ViewState.error;
    }
    notifyListeners();
  }

  bool isFavorite(LocationModel l) => _favorites.any((f) => f.key == l.key);

  Future<void> toggleFavorite(LocationModel l) async {
    if (isFavorite(l)) {
      _favorites = _favorites.where((f) => f.key != l.key).toList();
    } else {
      _favorites = [..._favorites, l];
    }
    notifyListeners();
    await _storage.saveFavorites(_favorites);
  }

  Future<void> addHistory(String name) async {
    _history = [name, ..._history.where((h) => h != name)].take(10).toList();
    notifyListeners();
    await _storage.saveHistory(_history);
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _storage.saveHistory(_history);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
