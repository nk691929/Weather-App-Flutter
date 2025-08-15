import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_models.dart';

class DailyForecastWidget extends StatelessWidget {
  final DailyForecast forecast;

  const DailyForecastWidget({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('EEE, MMM d').format(forecast.date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          // icon mapping
          Image.network(_iconUrl(forecast.icon), width: 50, height: 50),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  forecast.description[0].toUpperCase() + forecast.description.substring(1),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${forecast.max.toStringAsFixed(1)}° / ${forecast.min.toStringAsFixed(1)}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (forecast.pop != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '💧 ${(forecast.pop! * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _iconUrl(String icon) {
    return 'https://openweathermap.org/img/wn/$icon@2x.png';
  }
}
