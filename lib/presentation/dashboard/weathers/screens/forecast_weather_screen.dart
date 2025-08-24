// lib/presentation/weather/screens/weather_forecast_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({Key? key}) : super(key: key);

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadForecastData();
    });
  }

  Future<void> _loadForecastData() async {
    final weatherProvider = context.read<WeatherProvider>();
    await weatherProvider.loadWeatherForecast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Prediksi Cuaca',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadForecastData,
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<WeatherProvider>(
          builder: (context, weatherProvider, child) {
            if (weatherProvider.isLoading && weatherProvider.forecast.isEmpty) {
              return _buildLoadingView();
            }

            if (weatherProvider.hasError && weatherProvider.forecast.isEmpty) {
              return _buildErrorView(weatherProvider);
            }

            if (weatherProvider.forecast.isEmpty) {
              return _buildEmptyView();
            }

            return _buildForecastView(weatherProvider);
          },
        ),
      ),
    );
  }

  Widget _buildForecastView(WeatherProvider weatherProvider) {
    // Group forecast by day and get daily forecast for next 3 days
    final dailyForecasts = _getDailyForecasts(weatherProvider.forecast);

    return RefreshIndicator(
      onRefresh: _loadForecastData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current weather summary
            if (weatherProvider.currentWeather != null)
              _buildCurrentWeatherSummary(weatherProvider.currentWeather!),

            const SizedBox(height: 20),

            // Title
            const Text(
              'Prediksi 3 Hari Ke Depan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),

            // Daily forecasts
            ...dailyForecasts
                .take(3)
                .map((dayForecast) => _buildDayForecastCard(dayForecast))
                .toList(),

            const SizedBox(height: 20),

            // Hourly forecast for today
            if (dailyForecasts.isNotEmpty)
              _buildTodayHourlyForecast(dailyForecasts.first['hourly']),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherSummary(WeatherModel weather) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(weather.weatherIcon, color: Colors.white, size: 50),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuaca Saat Ini',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather.locationString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      weather.temperatureString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      weather.weatherIndonesian,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayForecastCard(Map<String, dynamic> dayData) {
    final WeatherModel mainWeather = dayData['main'];
    final List<WeatherModel> hourlyData = dayData['hourly'];

    // Calculate min and max temperature for the day
    double minTemp = hourlyData
        .map((w) => w.temperature)
        .reduce((a, b) => a < b ? a : b);
    double maxTemp = hourlyData
        .map((w) => w.temperature)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day header
          Row(
            children: [
              Icon(mainWeather.weatherIcon, color: AppColors.primary, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayName(mainWeather.dateTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      _getFormattedDate(mainWeather.dateTime),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${maxTemp.round()}°/${minTemp.round()}°',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    mainWeather.weatherIndonesian,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.lightText,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Weather details
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  Icons.water_drop,
                  '${mainWeather.humidity}%',
                  'Kelembaban',
                ),
                _buildWeatherDetail(
                  Icons.air,
                  '${mainWeather.windSpeed.toStringAsFixed(1)} m/s',
                  'Angin',
                ),
                _buildWeatherDetail(
                  Icons.compress,
                  '${mainWeather.pressure} hPa',
                  'Tekanan',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayHourlyForecast(List<WeatherModel> hourlyData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prediksi Per Jam Hari Ini',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyData.take(8).length, // Show next 8 hours
            itemBuilder: (context, index) {
              final weather = hourlyData[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${weather.dateTime.hour.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      weather.weatherIcon,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather.temperatureString,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.darkText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.lightText, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Memuat prediksi cuaca...',
            style: TextStyle(color: AppColors.lightText, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(WeatherProvider weatherProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Prediksi Cuaca',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              weatherProvider.error ?? 'Terjadi kesalahan',
              style: const TextStyle(color: AppColors.lightText, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadForecastData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: AppColors.lightText, size: 64),
            SizedBox(height: 16),
            Text(
              'Data Prediksi Tidak Tersedia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Periksa koneksi internet Anda',
              style: TextStyle(color: AppColors.lightText, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getDailyForecasts(List<WeatherModel> forecasts) {
    Map<String, List<WeatherModel>> groupedByDay = {};

    for (var forecast in forecasts) {
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

      return {'main': mainWeather, 'hourly': dayForecasts};
    }).toList();
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);

    final difference = targetDay.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Hari Ini';
      case 1:
        return 'Besok';
      case 2:
        return 'Lusa';
      default:
        const days = [
          'Minggu',
          'Senin',
          'Selasa',
          'Rabu',
          'Kamis',
          'Jumat',
          'Sabtu',
        ];
        return days[date.weekday % 7];
    }
  }

  String _getFormattedDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
