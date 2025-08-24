// lib/core/models/weather_model.dart
import 'package:flutter/material.dart';

class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final String description;
  final String mainWeather;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final DateTime dateTime;
  final int weatherId;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.mainWeather,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.dateTime,
    required this.weatherId,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? json['city']?['name'] ?? 'Unknown',
      country: json['sys']?['country'] ?? json['city']?['country'] ?? 'Unknown',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      mainWeather: json['weather'][0]['main'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      pressure: json['main']['pressure'] ?? 0,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000,
      ),
      weatherId: json['weather'][0]['id'] ?? 800,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'description': description,
      'mainWeather': mainWeather,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'pressure': pressure,
      'dateTime': dateTime.toIso8601String(),
      'weatherId': weatherId,
    };
  }

  // Get weather icon based on weather ID
  IconData get weatherIcon {
    switch (weatherId) {
      // Thunderstorm
      case >= 200 && < 300:
        return Icons.thunderstorm;
      // Drizzle
      case >= 300 && < 400:
        return Icons.grain;
      // Rain
      case >= 500 && < 600:
        return Icons.water_drop;
      // Snow
      case >= 600 && < 700:
        return Icons.ac_unit;
      // Atmosphere (fog, mist, etc.)
      case >= 700 && < 800:
        return Icons.foggy;
      // Clear sky
      case 800:
        return Icons.wb_sunny;
      // Clouds
      case > 800:
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }

  // Get formatted temperature
  String get temperatureString => '${temperature.round()}°C';

  // Get formatted date
  String get formattedDate {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];

    return '${days[dateTime.weekday % 7]}, ${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  // Get location string
  String get locationString => '$cityName, $country';

  // Get weather condition in Indonesian
  String get weatherIndonesian {
    switch (mainWeather.toLowerCase()) {
      case 'clear':
        return 'Cerah';
      case 'clouds':
        return 'Berawan';
      case 'rain':
        return 'Hujan';
      case 'drizzle':
        return 'Gerimis';
      case 'thunderstorm':
        return 'Badai Petir';
      case 'snow':
        return 'Salju';
      case 'mist':
      case 'fog':
        return 'Berkabut';
      case 'haze':
        return 'Kabut Asap';
      default:
        return description;
    }
  }

  @override
  String toString() {
    return 'WeatherModel(cityName: $cityName, temperature: $temperature, description: $description)';
  }
}
