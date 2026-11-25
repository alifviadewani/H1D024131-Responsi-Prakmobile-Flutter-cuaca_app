import 'package:flutter/material.dart';

class WeatherCodeInfo {
  final String label;
  final IconData icon;
  const WeatherCodeInfo(this.label, this.icon);
}

/// Menerjemahkan WMO weather_code dari Open-Meteo.
WeatherCodeInfo describeWeather(int code) {
  switch (code) {
    case 0:
      return const WeatherCodeInfo('Cerah', Icons.wb_sunny);
    case 1:
      return const WeatherCodeInfo('Cerah berawan', Icons.wb_sunny_outlined);
    case 2:
      return const WeatherCodeInfo('Berawan sebagian', Icons.cloud_queue);
    case 3:
      return const WeatherCodeInfo('Mendung', Icons.cloud);
    case 45:
    case 48:
      return const WeatherCodeInfo('Berkabut', Icons.blur_on);
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
      return const WeatherCodeInfo('Gerimis', Icons.grain);
    case 61:
    case 63:
    case 65:
    case 66:
    case 67:
      return const WeatherCodeInfo('Hujan', Icons.water_drop);
    case 71:
    case 73:
    case 75:
    case 77:
    case 85:
    case 86:
      return const WeatherCodeInfo('Salju', Icons.ac_unit);
    case 80:
    case 81:
    case 82:
      return const WeatherCodeInfo('Hujan lebat', Icons.umbrella);
    case 95:
    case 96:
    case 99:
      return const WeatherCodeInfo('Badai petir', Icons.thunderstorm);
    default:
      return const WeatherCodeInfo('Tidak diketahui', Icons.help_outline);
  }
}
