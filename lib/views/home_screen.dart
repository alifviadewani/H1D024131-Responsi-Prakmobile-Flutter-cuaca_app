import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/weather_model.dart';
import '../utils/weather_code.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca Ku'),
        actions: [
          IconButton(
            tooltip: 'Cari kota',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    switch (vm.state) {
      case ViewState.initial:
      case ViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewState.error:
        return _MessageView(
          icon: Icons.cloud_off,
          message: vm.errorMessage,
          actionLabel: 'Coba lagi',
          onAction: vm.loadWeather,
        );
      case ViewState.empty:
        return _MessageView(
          icon: Icons.inbox_outlined,
          message: 'Data cuaca untuk lokasi ini kosong.',
          actionLabel: 'Muat ulang',
          onAction: vm.loadWeather,
        );
      case ViewState.success:
        final weather = vm.weather!;
        return RefreshIndicator(
          onRefresh: vm.loadWeather,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _CurrentCard(vm: vm, weather: weather),
                  const SizedBox(height: 16),
                  _DetailGrid(weather: weather),
                  const SizedBox(height: 16),
                  _ForecastCard(daily: weather.daily),
                ],
              ),
            ),
          ),
        );
    }
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageView({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentCard extends StatelessWidget {
  final WeatherViewModel vm;
  final WeatherData weather;
  const _CurrentCard({required this.vm, required this.weather});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final c = weather.current;
    final info = describeWeather(c.weatherCode);

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(vm.location.name,
                style: text.headlineMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold)),
            if (vm.location.subtitle.isNotEmpty)
              Text(vm.location.subtitle,
                  style: text.bodyMedium
                      ?.copyWith(color: scheme.onPrimaryContainer)),
            const SizedBox(height: 16),
            Icon(info.icon, size: 80, color: scheme.onPrimaryContainer),
            const SizedBox(height: 8),
            Text('${c.temperature.round()}°C',
                style: text.displayLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w300)),
            Text(info.label,
                style: text.titleLarge
                    ?.copyWith(color: scheme.onPrimaryContainer)),
            const SizedBox(height: 4),
            Text('Terasa seperti ${c.apparentTemperature.round()}°C',
                style: text.bodyMedium
                    ?.copyWith(color: scheme.onPrimaryContainer)),
          ],
        ),
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final WeatherData weather;
  const _DetailGrid({required this.weather});

  @override
  Widget build(BuildContext context) {
    final c = weather.current;
    final rain = weather.daily.first.rainProbability;

    final items = [
      _InfoTile(Icons.water_drop_outlined, 'Kelembapan', '${c.humidity}%'),
      _InfoTile(Icons.air, 'Kecepatan angin',
          '${c.windSpeed.toStringAsFixed(1)} km/j'),
      _InfoTile(Icons.umbrella_outlined, 'Peluang hujan', '$rain%'),
      _InfoTile(Icons.grain, 'Curah hujan',
          '${c.precipitation.toStringAsFixed(1)} mm'),
    ];

    // Responsif: 2 kolom di layar kecil, 4 kolom di layar lebar.
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 520 ? 4 : 2;
      const gap = 12.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: items.map((e) => SizedBox(width: width, child: e)).toList(),
      );
    });
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value,
                style:
                    text.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final List<DailyForecast> daily;
  const _ForecastCard({required this.daily});

  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('Perkiraan ${daily.length} hari',
                  style: text.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            for (var i = 0; i < daily.length; i++) _row(context, daily[i], i),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, DailyForecast d, int index) {
    final info = describeWeather(d.weatherCode);
    final dayName = index == 0 ? 'Hari ini' : _days[d.date.weekday - 1];
    return ListTile(
      leading: Icon(info.icon, size: 32),
      title: Text('$dayName, ${d.date.day} ${_months[d.date.month - 1]}'),
      subtitle: Text('${info.label} • Hujan ${d.rainProbability}%'),
      trailing: Text(
        '${d.tempMax.round()}° / ${d.tempMin.round()}°',
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
