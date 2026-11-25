import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/open_meteo_service.dart';
import '../services/storage_service.dart';

enum ViewState { initial, loading, success, empty, error }

/// ViewModel untuk Home / Weather Screen.
class WeatherViewModel extends ChangeNotifier {
  final OpenMeteoService _service;
  final StorageService _storage;

  WeatherViewModel(this._service, this._storage);

  // Lokasi bawaan jika belum pernah memilih kota.
  static const _defaultLocation = LocationModel(
    name: 'Purwokerto',
    admin1: 'Jawa Tengah',
    country: 'Indonesia',
    latitude: -7.4242,
    longitude: 109.2303,
  );

  ViewState _state = ViewState.initial;
  LocationModel _location = _defaultLocation;
  WeatherData? _weather;
  String _errorMessage = '';

  ViewState get state => _state;
  LocationModel get location => _location;
  WeatherData? get weather => _weather;
  String get errorMessage => _errorMessage;

  /// Dipanggil saat aplikasi dibuka: muat lokasi terakhir dari storage.
  Future<void> init() async {
    _location = _storage.loadSelectedLocation() ?? _defaultLocation;
    await loadWeather();
  }

  Future<void> selectLocation(LocationModel location) async {
    _location = location;
    await _storage.saveSelectedLocation(location);
    await loadWeather();
  }

  Future<void> loadWeather() async {
    _state = ViewState.loading;
    notifyListeners();
    try {
      final data =
          await _service.fetchWeather(_location.latitude, _location.longitude);
      _weather = data;
      _state = data.daily.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _state = ViewState.error;
    }
    notifyListeners();
  }
}
