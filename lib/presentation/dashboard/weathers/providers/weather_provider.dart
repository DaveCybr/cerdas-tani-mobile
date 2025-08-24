// Enhanced WeatherProvider with better forecast handling
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _currentWeather;
  List<WeatherModel> _forecast = [];
  bool _isLoading = false;
  bool _isForecastLoading = false;
  String? _error;
  Position? _lastKnownPosition;

  // Getters
  WeatherModel? get currentWeather => _currentWeather;
  List<WeatherModel> get forecast => _forecast;
  bool get isLoading => _isLoading;
  bool get isForecastLoading => _isForecastLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Load weather for current location
  Future<void> loadCurrentLocationWeather() async {
    await _executeWeatherOperation(() async {
      final position = await _weatherService.getCurrentLocation();
      if (position != null) {
        _lastKnownPosition = position;
        final weather = await _weatherService.getCurrentWeatherByCoordinates(
          position.latitude,
          position.longitude,
        );
        if (weather != null) {
          _currentWeather = weather;
          return true;
        } else {
          _error = 'Tidak dapat mengambil data cuaca untuk lokasi saat ini';
          return false;
        }
      } else {
        _error =
            'Tidak dapat mengakses lokasi. Pastikan GPS aktif dan izin lokasi diberikan';
        return false;
      }
    });
  }

  /// Load weather by city name
  Future<void> loadWeatherByCity(String cityName) async {
    await _executeWeatherOperation(() async {
      final weather = await _weatherService.getCurrentWeatherByCity(cityName);
      if (weather != null) {
        _currentWeather = weather;
        // Clear last known position since we're using city search
        _lastKnownPosition = null;
        return true;
      } else {
        _error = 'Tidak dapat mengambil data cuaca untuk $cityName';
        return false;
      }
    });
  }

  /// Load weather by coordinates
  Future<void> loadWeatherByCoordinates(double lat, double lon) async {
    await _executeWeatherOperation(() async {
      final weather = await _weatherService.getCurrentWeatherByCoordinates(
        lat,
        lon,
      );
      if (weather != null) {
        _currentWeather = weather;
        _lastKnownPosition = Position(
          latitude: lat,
          longitude: lon,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        return true;
      } else {
        _error = 'Tidak dapat mengambil data cuaca untuk koordinat tersebut';
        return false;
      }
    });
  }

  /// Load weather forecast
  Future<void> loadWeatherForecast() async {
    _setForecastLoading(true);
    _clearError();

    try {
      Position? position = _lastKnownPosition;

      // If no position available, get current location
      if (position == null) {
        position = await _weatherService.getCurrentLocation();
        if (position != null) {
          _lastKnownPosition = position;
        }
      }

      if (position != null) {
        final forecastList = await _weatherService.getWeatherForecast(
          position.latitude,
          position.longitude,
        );

        if (forecastList.isNotEmpty) {
          _forecast = forecastList;

          // Also update current weather if we don't have it
          if (_currentWeather == null) {
            final currentWeather = await _weatherService
                .getCurrentWeatherByCoordinates(
                  position.latitude,
                  position.longitude,
                );
            if (currentWeather != null) {
              _currentWeather = currentWeather;
            }
          }
        } else {
          _error = 'Tidak dapat mengambil data prakiraan cuaca';
        }
      } else {
        _error = 'Tidak dapat mengakses lokasi untuk prakiraan cuaca';
      }
    } catch (e) {
      _error =
          'Terjadi kesalahan saat mengambil prakiraan cuaca: ${e.toString()}';
      debugPrint('Forecast error: $e');
    } finally {
      _setForecastLoading(false);
    }
  }

  /// Refresh weather data
  Future<void> refreshWeather() async {
    _clearError();
    await loadCurrentLocationWeather();
  }

  /// Refresh forecast data
  Future<void> refreshForecast() async {
    _clearError();
    await loadWeatherForecast();
  }

  /// Execute weather operation with loading state
  Future<bool> _executeWeatherOperation(
    Future<bool> Function() operation,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await operation();
      return success;
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      debugPrint('Weather operation error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setForecastLoading(bool loading) {
    if (_isForecastLoading != loading) {
      _isForecastLoading = loading;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void clearError() {
    _clearError();
  }

  /// Get weather summary for display
  String get weatherSummary {
    if (_currentWeather == null) return 'Data cuaca tidak tersedia';

    return '${_currentWeather!.weatherIndonesian}, ${_currentWeather!.temperatureString}';
  }

  /// Check if weather data is outdated (older than 30 minutes)
  bool get isWeatherDataOutdated {
    if (_currentWeather == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_currentWeather!.dateTime);
    return difference.inMinutes > 30;
  }

  /// Check if forecast data is outdated (older than 2 hours)
  bool get isForecastDataOutdated {
    if (_forecast.isEmpty) return true;

    final now = DateTime.now();
    final difference = now.difference(_forecast.first.dateTime);
    return difference.inHours > 2;
  }

  /// Auto refresh if data is outdated
  Future<void> autoRefreshIfNeeded() async {
    if (isWeatherDataOutdated && !_isLoading) {
      await refreshWeather();
    }
  }

  /// Auto refresh forecast if data is outdated
  Future<void> autoRefreshForecastIfNeeded() async {
    if (isForecastDataOutdated && !_isForecastLoading) {
      await refreshForecast();
    }
  }

  /// Get daily forecasts grouped by day
  List<Map<String, dynamic>> getDailyForecasts() {
    if (_forecast.isEmpty) return [];

    Map<String, List<WeatherModel>> groupedByDay = {};

    for (var forecast in _forecast) {
      String dayKey =
          '${forecast.dateTime.year}-${forecast.dateTime.month}-${forecast.dateTime.day}';
      if (!groupedByDay.containsKey(dayKey)) {
        groupedByDay[dayKey] = [];
      }
      groupedByDay[dayKey]!.add(forecast);
    }

    return groupedByDay.entries.map((entry) {
      List<WeatherModel> dayForecasts = entry.value;
      // Use the forecast closest to noon as the main weather for the day
      WeatherModel mainWeather = dayForecasts.reduce((a, b) {
        int aDiff = (a.dateTime.hour - 12).abs();
        int bDiff = (b.dateTime.hour - 12).abs();
        return aDiff <= bDiff ? a : b;
      });

      return {
        'main': mainWeather,
        'hourly': dayForecasts,
        'minTemp': dayForecasts
            .map((w) => w.temperature)
            .reduce((a, b) => a < b ? a : b),
        'maxTemp': dayForecasts
            .map((w) => w.temperature)
            .reduce((a, b) => a > b ? a : b),
      };
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
