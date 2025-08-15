class CurrentWeather {
  final double temp;
  final String description;
  final int humidity;
  final double feelsLike;
  final double windSpeed;
  final String icon;

  CurrentWeather({
    required this.temp,
    required this.description,
    required this.humidity,
    required this.feelsLike,
    required this.windSpeed,
    required this.icon,
  });
}

class DailyForecast {
  final DateTime date;
  final double min;
  final double max;
  final String description;
  final String icon;
  final double? pop; 

  DailyForecast({
    required this.date,
    required this.min,
    required this.max,
    required this.description,
    required this.icon,
    this.pop,
  });
}

class WeatherBundle {
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherBundle({required this.current, required this.daily});
}
