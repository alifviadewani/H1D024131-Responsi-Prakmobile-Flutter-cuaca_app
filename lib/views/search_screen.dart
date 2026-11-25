import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Bersihkan sisa hasil pencarian sebelumnya.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LocationViewModel>().onQueryChanged('');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(LocationModel location) {
    final locationVm = context.read<LocationViewModel>();
    final weatherVm = context.read<WeatherViewModel>();
    final navigator = Navigator.of(context);

    locationVm.addHistory(location.name);
    weatherVm.selectLocation(location); // memicu request cuaca baru
    navigator.pop();
  }

  void _useQuery(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
    context.read<LocationViewModel>().search(text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LocationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari nama kota...',
            border: InputBorder.none,
          ),
          onChanged: (v) {
            vm.onQueryChanged(v);
            setState(() {});
          },
          onSubmitted: vm.search,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Hapus',
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                vm.onQueryChanged('');
                setState(() {});
              },
            ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _buildBody(vm),
        ),
      ),
    );
  }

  Widget _buildBody(LocationViewModel vm) {
    // Belum mengetik: tampilkan favorit & riwayat.
    if (_controller.text.trim().length < 2) {
      return _buildSaved(vm);
    }

    switch (vm.state) {
      case ViewState.initial:
      case ViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 56),
                const SizedBox(height: 12),
                Text(vm.errorMessage, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => vm.search(_controller.text),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        );
      case ViewState.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Kota "${_controller.text}" tidak ditemukan.',
                textAlign: TextAlign.center),
          ),
        );
      case ViewState.success:
        return ListView.separated(
          itemCount: vm.results.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => _locationTile(vm, vm.results[i]),
        );
    }
  }

  Widget _locationTile(LocationViewModel vm, LocationModel l) {
    final fav = vm.isFavorite(l);
    return ListTile(
      leading: const Icon(Icons.location_on_outlined),
      title: Text(l.name),
      subtitle: Text(l.subtitle),
      trailing: IconButton(
        tooltip: fav ? 'Hapus dari favorit' : 'Simpan ke favorit',
        icon: Icon(fav ? Icons.star : Icons.star_border,
            color: fav ? Colors.amber : null),
        onPressed: () => vm.toggleFavorite(l),
      ),
      onTap: () => _select(l),
    );
  }

  Widget _buildSaved(LocationViewModel vm) {
    final text = Theme.of(context).textTheme;

    if (vm.favorites.isEmpty && vm.history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Ketik nama kota untuk mulai mencari.\nFavorit dan riwayat akan muncul di sini.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      children: [
        if (vm.favorites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Lokasi favorit',
                style:
                    text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          for (final f in vm.favorites) _locationTile(vm, f),
        ],
        if (vm.history.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text('Riwayat pencarian',
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                TextButton(
                    onPressed: vm.clearHistory, child: const Text('Hapus')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                for (final h in vm.history)
                  ActionChip(
                    avatar: const Icon(Icons.history, size: 18),
                    label: Text(h),
                    onPressed: () => _useQuery(h),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
