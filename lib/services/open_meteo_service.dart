import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Semua HTTP GET ke Open-Meteo ada di sini.
class OpenMeteoService {
  static const _timeout = Duration(seconds: 15);

  /// Geocoding API: cari kota berdasarkan nama.
  Future<List<LocationModel>> searchLocations(String name) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': name,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });
    final json = await _get(uri);
    final results = json['results'] as List<dynamic>?;
    if (results == null) return []; // tidak ada hasil
    return results
        .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Forecast API: cuaca terkini + perkiraan 7 hari.
  Future<WeatherData> fetchWeather(double lat, double lon) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$lat',
      'longitude': '$lon',
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    final json = await _get(uri);
    try {
      return WeatherData.fromJson(json);
    } catch (_) {
      throw ApiException('Data cuaca dari server tidak lengkap.');
    }
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode != 200) {
        throw ApiException('Server mengembalikan error (${res.statusCode}).');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Waktu permintaan habis. Coba lagi.');
    } on FormatException {
      throw ApiException('Format respons tidak valid.');
    } catch (_) {
      throw ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet.');
    }
  }
}
