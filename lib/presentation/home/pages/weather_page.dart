import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fertilizer_calculator/presentation/auth/widgets/custom_back_button.dart';
import 'package:fertilizer_calculator/presentation/home/pages/dashboard_page.dart';

class Weather {
  final String city;
  final String country;
  final double temperature;
  final String condition;
  final String iconUrl;
  final double windSpeed;
  final int humidity;
  final List<Map<String, dynamic>> forecast;

  Weather({
    required this.city,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.windSpeed,
    required this.humidity,
    required this.forecast,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> forecastData =
        (json["daily"] as List).map((day) {
      String dayName = DateFormat('EEEE', 'id_ID')
          .format(DateTime.fromMillisecondsSinceEpoch(day["dt"] * 1000));
      return {
        "day": dayName,
        "icon":
            "https://openweathermap.org/img/wn/${day["weather"][0]["icon"]}.png",
        "temp": day["temp"]["day"],
        "condition": day["weather"][0]["description"],
      };
    }).toList();

    return Weather(
      city: json["name"],
      country: json["sys"]["country"],
      temperature: json["main"]["temp"],
      condition: json["weather"][0]["description"],
      iconUrl:
          "https://openweathermap.org/img/wn/${json["weather"][0]["icon"]}.png",
      windSpeed: json["wind"]["speed"],
      humidity: json["main"]["humidity"],
      forecast: forecastData,
    );
  }
}

class WeatherService {
  final String apiKey =
      "febe39931a5edb8c05a9201a6859c54c"; // Gantilah dengan API key Anda
  final String baseUrl = "https://api.openweathermap.org/data/2.5/onecall";

  Future<Weather> fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
        "$baseUrl?lat=$lat&lon=$lon&exclude=hourly,minutely&units=metric&lang=id&appid=$apiKey");
    print("Request URL: $url");
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

class WeatherPage extends StatefulWidget {
  final double lat;
  final double lon;

  const WeatherPage({Key? key, required this.lat, required this.lon})
      : super(key: key);

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late Future<Weather> _weatherFuture;
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _weatherFuture = _weatherService.fetchWeather(widget.lat, widget.lon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: FutureBuilder<Weather>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("Tidak ada data cuaca"));
          }

          Weather weather = snapshot.data!;
          String formattedDate =
              DateFormat('EEEE, d MMMM yyyy', 'id').format(DateTime.now());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: CustomBackButton(
                        context: context, destination: const DashboardPage()),
                  ),
                ),
                Text(
                  weather.city,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  weather.country,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child:
                      Image.network(weather.iconUrl, width: 120, height: 120),
                ),
                const SizedBox(height: 20),
                Text(
                  "${weather.temperature.toInt()}°C",
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(fontSize: 60),
                ),
                Text(
                  weather.condition,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${weather.windSpeed} km/h",
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(fontSize: 27),
                        ),
                        Text(
                          "Kecepatan Angin",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${weather.humidity} %",
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(fontSize: 27),
                        ),
                        Text(
                          "Kelembaban",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Prakiraan Cuaca 5 Hari ke Depan",
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: weather.forecast.map((day) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              day['day'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 10),
                            ),
                            const SizedBox(height: 5),
                            Image.network(day['icon'], width: 40, height: 50),
                            const SizedBox(height: 5),
                            Text(
                              "${day['temp']}°C",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(fontSize: 17),
                            ),
                            Text(
                              day['condition'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
