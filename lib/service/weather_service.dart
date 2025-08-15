import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> fetchWeather(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
      '$baseUrl?latitude=$latitude&longitude=$longitude&current_weather=true&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=Asia/Karachi',
    ));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
