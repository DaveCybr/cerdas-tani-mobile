import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

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
      temperature: json["current"]["temp_c"],
      condition: json["current"]["condition"]["text"],
      iconUrl: "https:${json["current"]["condition"]["icon"]}",
    );
  }
}

class WeatherService {
  final String apiKey =
      "49f13fa4f07c45538b7214514251903"; // Ganti dengan API Key dari WeatherAPI
  final String baseUrl = "http://api.weatherapi.com/v1/current.json";

  Future<Weather> fetchWeather(String city) async {
    final response =
        await http.get(Uri.parse("$baseUrl?key=$apiKey&q=$city&aqi=no"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception("Gagal mengambil data cuaca");
    }
  }
}

class _WeatherCardState extends State<WeatherCard> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final weather =
          await _weatherService.fetchWeather("Jakarta"); // Ganti sesuai kota
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Color(0xFF1FCC79).withOpacity(1), width: 1.0),
        color: const Color.fromARGB(255, 236, 248, 242),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.009,
      ),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _weather != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(_weather!.iconUrl, width: 50, height: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weather!.city,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${_weather!.temperature}°C - ${_weather!.condition}",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _fetchWeather();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1FCC79),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                      ),
                      child: Text(
                        'refresh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ],
                )
              : const Text(
                  "Gagal mengambil data cuaca",
                ),
    );
  }
}
