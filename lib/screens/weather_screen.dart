import 'package:flutter/material.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  String cityName = 'Delhi';
  Map<String, dynamic>? weatherData;
  bool isLoading = false;

  Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await _weatherService.fetchWeather(cityName);
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load weather data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.indigo[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                setState(() {
                  cityName = value;
                  weatherData = null;
                });
                fetchWeather();
              },
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : weatherData == null
                    ? Center(
                        child: Text(
                          'Enter a city name to get the weather information.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Expanded(
                        child: buildWeatherInfo(),
                      ),
          ],
        ),
      ),
    );
  }

  // Weather info UI
  Widget buildWeatherInfo() {
    if (weatherData == null) {
      return Center(
        child: Text('Weather data is not available.'),
      );
    }

    final condition = weatherData!['weather'][0]['description'];
    final tempC = weatherData!['main']['temp'].toString();
    final iconUrl = 'https://openweathermap.org/img/w/${weatherData!['weather'][0]['icon']}.png';
    final humidity = weatherData!['main']['humidity'].toString();
    final windSpeed = weatherData!['wind']['speed'].toString();
    final city = weatherData!['name'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          city,
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: Colors.indigo[900],
              ),
        ),
        SizedBox(height: 20),
        Image.network(iconUrl, width: 100),
        Text(
          '$tempC°C',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        Text(
          condition,
          style: TextStyle(fontSize: 22, color: Colors.indigo[600]),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            weatherTile('Humidity', '$humidity%'),
            weatherTile('Wind', '$windSpeed m/s'),
          ],
        ),
      ],
    );
  }

  Widget weatherTile(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.indigo[800],
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
      ],
    );
  }
}
