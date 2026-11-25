# Cuaca Ku – Responsi Flutter

Aplikasi cuaca Flutter yang memakai **Open-Meteo** (Forecast + Geocoding API).

## Identitas
- **Nama:** Alifvia Putri Dewani
- **NIM:** H1D024131
- **Shift KRS:** B
- **Shift Akhir:** E

## Video Penjelasan Kode
[Tonton di YouTube](https://youtu.be/EU1Y9ZmGgVg)

## Fitur
- Cari kota (request nyata ke Geocoding API)
- Cuaca terkini: suhu, terasa seperti, kelembapan, angin, curah hujan, peluang hujan
- Perkiraan 7 hari
- Favorit & riwayat pencarian tersimpan (SharedPreferences)
- Loading, data kosong, dan error handling
- Material 3, light/dark theme, layout responsif

## Struktur (MVVM)
```
lib/
├── models/        # LocationModel, WeatherData (parsing JSON)
├── services/      # OpenMeteoService (HTTP GET), StorageService (local storage)
├── viewmodels/    # WeatherViewModel, LocationViewModel (ChangeNotifier)
├── views/         # HomeScreen, SearchScreen
├── utils/         # weather_code.dart (kode WMO -> label & ikon)
└── main.dart      # Provider + Theme
```

## Implementasi API
- Geocoding: `GET https://geocoding-api.open-meteo.com/v1/search?name=...`
- Forecast: `GET https://api.open-meteo.com/v1/forecast?latitude=..&longitude=..&current=..&daily=..&timezone=auto`

## Penerapan MVVM
- **Model**: kelas data + `fromJson`
- **View**: widget UI, hanya `watch` ViewModel & memanggil method-nya
- **ViewModel**: menyimpan state (loading/success/empty/error), memanggil Service, `notifyListeners()`

## Screenshot
| Home | Search |
|------|--------|
| ![Home](screenshots/home.png) | ![Search](screenshots/search.png) |

## Cara menjalankan
```
flutter pub get
flutter run
```