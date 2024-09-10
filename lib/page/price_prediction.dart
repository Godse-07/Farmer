import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'package:sih/page/api_key.dart'; // Assuming you store your API key here

class pricePrediction extends StatefulWidget {
  const pricePrediction({super.key});

  @override
  _PricePredictionState createState() => _PricePredictionState();
}

class _PricePredictionState extends State<pricePrediction> {
  List<String> predictedPrices = [];
  bool isLoading = false;

  // OpenWeather API Key
  final String apiKey =
      apiKeyval; // Replace with your actual OpenWeather API key

  Future<void> fetchWeatherAndPredictPrice() async {
    setState(() {
      isLoading = true;
      predictedPrices.clear();
    });

    try {
      // Step 1: Get the user's location
      Position position = await _determinePosition();

      double lat = position.latitude;
      double lon = position.longitude;

      // Step 2: Fetch weather data using the user's location
      final weatherUrl =
          'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
      final weatherResponse = await http.get(Uri.parse(weatherUrl));

      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);

        // Step 3: Extract weather data for the next 7 days
        for (int i = 0; i < 7; i++) {
          double tempMax = weatherData['daily'][i]['temp']['max'];
          double tempMin = weatherData['daily'][i]['temp']['min'];
          double rain = weatherData['daily'][i]['rain'] ??
              0.0; // If there's no rain, default to 0.0
          String date = DateFormat('yyyy-MM-dd').format(
            DateTime.fromMillisecondsSinceEpoch(
              weatherData['daily'][i]['dt'] *
                  1000, // Convert Unix timestamp to DateTime
            ),
          );

          // Predict price for each day
          await _predictPrice(tempMax, tempMin, rain, date);
        }
      } else {
        setState(() {
          predictedPrices.add("Failed to fetch weather data.");
        });
      }
    } catch (e) {
      setState(() {
        predictedPrices.add("Error occurred: $e");
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _predictPrice(
      double tempMax, double tempMin, double rain, String date) async {
    final String apiUrl =
        "https://web-production-ea5e7.up.railway.app/predict_price";
    final Map<String, dynamic> requestData = {
      "date": date, // Date in 'YYYY-MM-DD' format
      "rain": rain, // Rain data from weather API
      "temp_max": tempMax, // Max temp from weather API
      "temp_min": tempMin, // Min temp from weather API
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          predictedPrices.add(
              "Date: $date - Predicted price: ${data['predicted_price'].toStringAsFixed(2)}");
        });
      } else {
        setState(() {
          predictedPrices.add(
              "Date: $date - Price prediction failed: ${response.statusCode} - ${response.body}");
        });
      }
    } catch (e) {
      setState(() {
        predictedPrices.add("Date: $date - Error in price prediction: $e");
      });
    }
  }

  // Method to determine the user's position
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherAndPredictPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Prediction'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: predictedPrices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(predictedPrices[index]),
                  );
                },
              ),
      ),
    );
  }
}
