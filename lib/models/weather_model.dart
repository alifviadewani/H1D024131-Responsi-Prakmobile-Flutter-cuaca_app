/// Model data cuaca saat ini.
class CurrentWeather {
  final double temperature;
  final int humidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  const CurrentWeather({
    required this.temperature,
    required this.humidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}

/// Model perkiraan cuaca satu hari.
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final int rainProbability;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.rainProbability,
  });
}

/// Gabungan seluruh respons Forecast API.
class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const WeatherData({required this.current, required this.daily});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current =
        CurrentWeather.fromJson(json['current'] as Map<String, dynamic>);

    final d = json['daily'] as Map<String, dynamic>;
    final times = (d['time'] as List).cast<String>();
    final codes = d['weather_code'] as List;
    final maxs = d['temperature_2m_max'] as List;
    final mins = d['temperature_2m_min'] as List;
    final rains = d['precipitation_probability_max'] as List;

    final daily = <DailyForecast>[
      for (var i = 0; i < times.length; i++)
        DailyForecast(
          date: DateTime.parse(times[i]),
          weatherCode: (codes[i] as num?)?.toInt() ?? 0,
          tempMax: (maxs[i] as num?)?.toDouble() ?? 0,
          tempMin: (mins[i] as num?)?.toDouble() ?? 0,
          rainProbability: (rains[i] as num?)?.toInt() ?? 0,
        ),
    ];

    return WeatherData(current: current, daily: daily);
  }
}
