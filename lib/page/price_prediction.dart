import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'package:sih/page/api_key.dart'; // Assuming you store your API key here
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:sih/page/mandi_api_key.dart';

class pricePrediction extends StatefulWidget {
  @override
  _PricePredictionState createState() => _PricePredictionState();
}

class _PricePredictionState extends State<pricePrediction> {
  List<String> dateList = [];
  List<double> priceList = [];
  bool isLoading = false;
  List<int> showingTooltipOnSpots = [1, 3, 5];

  final String apiKey = apiKeyval;

  List<String> stateList = [];
  List<String> districtList = [];
  List<String> marketList = [];
  List<String> commodityList = [];
  List<String> varietyList = [];

  double? currentPrice;

  @override
  void initState() {
    super.initState();
    fetchWeatherAndPredictPrice();
  }

  String _getCurrentDatePrice() {
    if (dateList.isEmpty || priceList.isEmpty) return "No data available";

    // Get today's date in 'yyyy-MM-dd' format
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Check if today is in dateList
    final index = dateList.indexOf(today);

    if (index != -1) {
      return "₹ ${priceList[index].toStringAsFixed(2)}";
    } else {
      return "No price available for today.";
    }
  }

  Future<void> fetchWeatherAndPredictPrice() async {
    setState(() {
      isLoading = true;
      dateList.clear();
      priceList.clear();
    });

    try {
      Position position = await _determinePosition();

      double lat = position.latitude;
      double lon = position.longitude;

      final weatherUrl =
          'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
      final weatherResponse = await http.get(Uri.parse(weatherUrl));

      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);

        for (int i = 0; i < 7; i++) {
          double tempMax = weatherData['daily'][i]['temp']['max'].toDouble();
          double tempMin = weatherData['daily'][i]['temp']['min'].toDouble();
          double rain = (weatherData['daily'][i]['rain'] ?? 0.0).toDouble();
          String date = DateFormat('yyyy-MM-dd').format(
            DateTime.fromMillisecondsSinceEpoch(
              weatherData['daily'][i]['dt'] * 1000,
            ),
          );

          await _predictPrice(tempMax, tempMin, rain, date);
        }
      } else {
        print("Failed to fetch weather data.");
      }
    } catch (e) {
      print("Error occurred: $e");
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
      "date": date,
      "rain": rain,
      "temp_max": tempMax,
      "temp_min": tempMin,
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
          dateList.add(date);
          priceList
              .add(double.parse(data['predicted_price'].toStringAsFixed(2)));
        });
      } else {
        print(
            "Price prediction failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error in price prediction: $e");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Prediction'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[400]!, Colors.blue[900]!],
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                            "Price Prediction",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : _buildPriceChart(),
                        ),
                        SizedBox(height: 40),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                            "current price",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                            _getCurrentDatePrice(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceChart() {
    if (priceList.isEmpty) {
      return const Text("No data available to display.");
    }

    // Find the minimum and maximum prices
    double minPrice = priceList.reduce((a, b) => a < b ? a : b);
    double maxPrice = priceList.reduce((a, b) => a > b ? a : b);

    // Adjust the minimum Y to be 30 or the lowest price, whichever is lower
    double minY = minPrice < 30 ? minPrice.floorToDouble() : 30;
    // Round up the maximum Y to the nearest 10
    double maxY = (maxPrice / 10).ceil() * 10.0;

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots
            .where((index) => index < priceList.length)
            .toList(),
        spots: List.generate(
          priceList.length,
          (index) => FlSpot(index.toDouble(), priceList[index]),
        ),
        isCurved: true,
        barWidth: 4,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.4),
              Colors.green.withOpacity(0.4),
              Colors.purple.withOpacity(0.4),
            ],
          ),
        ),
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 8,
            color: Colors.blue,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ),
        gradient: LinearGradient(
          colors: [
            Colors.blue,
            Colors.green,
            Colors.purple,
          ],
          stops: const [0.1, 0.4, 0.9],
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return SizedBox(
      height: 300,
      child: Container(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
          child: LineChart(
            LineChartData(
              showingTooltipIndicators: showingTooltipOnSpots.map((index) {
                return ShowingTooltipIndicators([
                  LineBarSpot(
                    tooltipsOnBar,
                    lineBarsData.indexOf(tooltipsOnBar),
                    tooltipsOnBar.spots[index],
                  ),
                ]);
              }).toList(),
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                touchCallback:
                    (FlTouchEvent event, LineTouchResponse? response) {
                  if (response == null || response.lineBarSpots == null) {
                    return;
                  }
                  if (event is FlTapUpEvent) {
                    final spotIndex = response.lineBarSpots!.first.spotIndex;
                    setState(() {
                      if (showingTooltipOnSpots.contains(spotIndex)) {
                        showingTooltipOnSpots.remove(spotIndex);
                      } else {
                        showingTooltipOnSpots.add(spotIndex);
                      }
                    });
                  }
                },
                mouseCursorResolver:
                    (FlTouchEvent event, LineTouchResponse? response) {
                  if (response == null || response.lineBarSpots == null) {
                    return SystemMouseCursors.basic;
                  }
                  return SystemMouseCursors.click;
                },
                getTouchedSpotIndicator:
                    (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      const FlLine(color: Colors.pink),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 8,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.pink,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                    return lineBarsSpot.map((lineBarSpot) {
                      return LineTooltipItem(
                        lineBarSpot.y.toString(),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: lineBarsData,
              minY: minY,
              maxY: maxY,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final date = DateFormat('yyyy-MM-dd')
                          .parse(dateList[value.toInt()]);
                      return Text(
                        date.day.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                    reservedSize: 22,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
