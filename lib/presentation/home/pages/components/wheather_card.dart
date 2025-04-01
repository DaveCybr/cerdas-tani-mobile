import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/home/pages/weather_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class WeatherCard extends StatefulWidget {
  @override
  _WeatherCardState createState() => _WeatherCardState();
}

class Weather {
  final String city;
  final double temperature;
  final String condition;
  final String iconUrl;

  Weather({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json["location"]["name"],
      temperature: json["current"]["temp_c"].toDouble(),
      condition: json["current"]["condition"]["text"],
      iconUrl: "https:${json["current"]["condition"]["icon"]}",
    );
  }
}

class WeatherService {
  final String apiKey = "a6439437add444549d6125856253103";
  final String baseUrl = "https://api.weatherapi.com/v1/current.json";

  Future<Weather> fetchWeather(double lat, double lon) async {
    final url = Uri.parse("$baseUrl?key=$apiKey&q=$lat,$lon&lang=id");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      } else {
        throw Exception(
            "Gagal mengambil data cuaca. Kode: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat mengambil data: $e");
    }
  }
}

class _WeatherCardState extends State<WeatherCard> {
  final WeatherService _weatherService = WeatherService();
  late Future<Weather> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchWeather();
  }

  Position? _currentPosition;

  Future<Weather> _fetchWeather() async {
    try {
      _currentPosition = await _determinePosition(); // Simpan lokasi
      return await _weatherService.fetchWeather(
          _currentPosition!.latitude, _currentPosition!.longitude);
    } catch (e) {
      throw Exception("Gagal mendapatkan lokasi/cuaca: $e");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled)
      throw Exception("GPS tidak aktif. Aktifkan dan coba lagi.");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Izin lokasi ditolak.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Izin lokasi ditolak secara permanen. Harap atur secara manual.");
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder<Weather>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Text(
              "Error: ${snapshot.error}",
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        initializeDateFormatting();
        String formattedDate =
            DateFormat('EEEE, d MMMM yyyy', 'id').format(DateTime.now());
        final weather = snapshot.data!;
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.03),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
                color: const Color(0xFF1FCC79).withOpacity(1), width: 1.0),
            color: const Color.fromARGB(255, 236, 248, 242),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 3,
                offset: Offset(1, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network(
                    weather.iconUrl,
                    width: screenWidth * 0.2,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/cloud.png',
                      width: screenWidth * 0.2,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.city,
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey[700]),
                      ),
                      SizedBox(height: screenWidth * 0.01),
                      Text(
                        '${weather.temperature}°C',
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_currentPosition != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeatherPage(
                          lat: _currentPosition!.latitude,
                          lon: _currentPosition!.longitude,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lokasi belum tersedia")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  'View',
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.035),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
