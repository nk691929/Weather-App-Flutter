import 'package:flutter/material.dart';
import '../models/weather_models.dart';

class CurrentWeatherWidget extends StatelessWidget {
  final WeatherBundle bundle;

  const CurrentWeatherWidget({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final c = bundle.current;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Image.network(_iconUrl(c.icon), width: 80, height: 80),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.description[0].toUpperCase() + c.description.substring(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${c.temp.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _infoChip(context, 'Feels', '${c.feelsLike.toStringAsFixed(1)}°C'),
                    _infoChip(context, 'Humidity', '${c.humidity}%'),
                    _infoChip(context, 'Wind', '${c.windSpeed.toStringAsFixed(1)} m/s'),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }


  Widget _infoChip(BuildContext context, String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label: $value',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      );


  String _iconUrl(String icon) {
    return 'https://openweathermap.org/img/wn/$icon@2x.png';
  }
}
