import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather_models.dart';
import '../widgets/current_weather_widget.dart';
import '../widgets/daily_forecast_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  WeatherBundle? _bundle;
  bool _loading = false;
  String? _error;
  Timer? _debounce;
  String? _currentCity;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocationWeather();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fetch weather from Open-Meteo
  Future<void> _fetchWeather(double lat, double lon, {String? city}) async {
    setState(() {
      _loading = true;
      _error = null;
      _bundle = null;
      if (city != null) _currentCity = city;
    });

    try {
      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weathercode&timezone=Asia/Karachi';
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        // Map Open-Meteo data to WeatherBundle
        final current = CurrentWeather(
          temp: (data['current_weather']['temperature'] as num).toDouble(),
          feelsLike: (data['current_weather']['temperature'] as num).toDouble(), 
          humidity: 50, 
          windSpeed: (data['current_weather']['windspeed'] as num).toDouble(),
          description: _weatherCodeToDescription(data['current_weather']['weathercode']),
          icon: _weatherCodeToIcon(data['current_weather']['weathercode']),
        );

        final daily = <DailyForecast>[];
        final dailyTempsMax = data['daily']['temperature_2m_max'];
        final dailyTempsMin = data['daily']['temperature_2m_min'];
        final dailyPop = data['daily']['precipitation_sum'];
        final dailyCodes = data['daily']['weathercode'];

        for (int i = 0; i < dailyTempsMax.length; i++) {
          daily.add(DailyForecast(
            date: DateTime.now().add(Duration(days: i)),
            max: (dailyTempsMax[i] as num).toDouble(),
            min: (dailyTempsMin[i] as num).toDouble(),
            description: _weatherCodeToDescription(dailyCodes[i]),
            icon: _weatherCodeToIcon(dailyCodes[i]),
            pop: (dailyPop[i] as num).toDouble() / 10, 
          ));
        }

        setState(() {
          _bundle = WeatherBundle(current: current, daily: daily);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch weather';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  //Weather code mapping 
  String _weatherCodeToDescription(int code) {
    if (code == 0) return 'Clear sky';
    if (code == 1 || code == 2) return 'Partly cloudy';
    if (code == 3) return 'Cloudy';
    if (code >= 61 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    return 'Unknown';
  }

  String _weatherCodeToIcon(int code) {
    if (code == 0) return '01d';
    if (code == 1 || code == 2) return '02d';
    if (code == 3) return '03d';
    if (code >= 61 && code <= 67) return '09d';
    if (code >= 71 && code <= 77) return '13d';
    return '01d';
  }

  //Fetch current location
  Future<void> _fetchCurrentLocationWeather() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _error = 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _error = 'Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _error = 'Location permissions are permanently denied.');
      return;
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _fetchWeather(pos.latitude, pos.longitude);
  }

  //Search city using Nominatim 
  Future<void> _searchCity(String cityName) async {
    if (cityName.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _bundle = null;
    });

    try {
      final url = 'https://nominatim.openstreetmap.org/search?q=$cityName&format=json&limit=1';
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final results = json.decode(res.body);
        if (results.isNotEmpty) {
          final lat = double.parse(results[0]['lat']);
          final lon = double.parse(results[0]['lon']);
          _fetchWeather(lat, lon, city: cityName);
        } else {
          setState(() {
            _error = 'City not found';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to search city';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 32, 122, 152), Color(0xFF2F80ED)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          hintText: 'Search city (e.g., Karachi)',
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: const TextStyle(color: Colors.white70),
                          isDense: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (text) {
                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                          _debounce = Timer(const Duration(milliseconds: 500), () {
                            _searchCity(text);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        backgroundColor: Colors.white.withOpacity(0.3),
                      ),
                      onPressed: () => _searchCity(_controller.text),
                      child: const Text('Find', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                //  Loading/Error 
                if (_loading) const LinearProgressIndicator(minHeight: 2, color: Colors.white),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 16),

                // Current Weather 
                if (_bundle != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: CurrentWeatherWidget(bundle: _bundle!),
                  ),

                const SizedBox(height: 16),

                //7-day forecast
                if (_bundle != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentCity != null ? '7-day forecast for $_currentCity' : '7-day forecast',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.separated(
                              itemCount: _bundle!.daily.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (ctx, i) {
                                final d = _bundle!.daily[i];
                                return DailyForecastWidget(forecast: d);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                // Empty state
                if (_bundle == null && !_loading)
                  const Expanded(
                    child: Center(
                      child: Text('Search a city or allow location to view weather.',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                          textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
