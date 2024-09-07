import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sih/page/Bug_report.dart';
import 'package:sih/page/api_key.dart'; // Import the permission_handler package

// Replace with your actual API key.
const String apiKey = apiKeyval;

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String _errorMessage = '';
  Position? _position;
  String _address = 'Your Location'; // Initialize with default text

  int index = 1;

  final items = <Widget>[
    Icon(Icons.bug_report, size: 30),
    Icon(Icons.cloud, size: 30),
    Icon(Icons.shop, size: 30),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndFetchLocation();
  }

  Future<void> _checkPermissionsAndFetchLocation() async {
    final permissionStatus = await Permission.locationWhenInUse.status;

    if (permissionStatus.isGranted) {
      _getCurrentLocation();
    } else if (permissionStatus.isDenied) {
      final status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        _getCurrentLocation();
      } else {
        setState(() {
          _errorMessage =
              'Location permissions are denied. Please enable them in settings.';
        });
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      setState(() {
        _errorMessage =
            'Location permissions are permanently denied. Please enable them in settings.';
      });
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _position = position;
      });
      _fetchWeatherData();
      _getAddressFromLatLng(); // Fetch address after getting location
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: ${e.toString()}';
      });
    }
  }

  Future<void> _getAddressFromLatLng() async {
    if (_position == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _position!.latitude,
        _position!.longitude,
      );
      Placemark place = placemarks[0];
      setState(() {
        _address = '${place.locality}, ${place.country}'; // Update address
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting address: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchWeatherData() async {
    if (_position == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/3.0/onecall?lat=${_position!.latitude}&lon=${_position!.longitude}&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text(
            'Location permission is required to use this feature. Please enable it in the app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[400]!, Colors.blue[900]!],
            ),
          ),
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : _errorMessage.isNotEmpty
                  ? _buildErrorWidget()
                  : _weatherData == null
                      ? Center(
                          child: Text('No data available',
                              style: TextStyle(color: Colors.white)))
                      : _buildWeatherWidget(),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        index: index,
        height: 60,
        onTap: (selectedIndex) {
          setState(() {
            index = selectedIndex;
          });
          if (selectedIndex == 0) {
            // Navigate to BugDetect when the first tab (bug icon) is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BugDetect()),
            );
          }
          },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPermissionsAndFetchLocation,
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherWidget() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            SizedBox(height: 20),
            _currentWeather(),
            SizedBox(height: 20),
            _hourlyForecast(),
            SizedBox(height: 20),
            _dailyForecast(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _address, // Display the current location address
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Weather Forecast',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _currentWeather() {
    final current = _weatherData!['current'];
    final weather = current['weather'][0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Weather',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${current['temp'].toStringAsFixed(1)}°C',
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  weather['description'],
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),
            Image.network(
              "http://openweathermap.org/img/wn/${weather['icon']}@2x.png",
              height: 80,
              width: 80,
            ),
          ],
        ),
        SizedBox(height: 10),
        _buildInfoRow(
            'Feels Like', '${current['feels_like'].toStringAsFixed(1)}°C'),
        _buildInfoRow('Humidity', '${current['humidity']}%'),
        _buildInfoRow('Wind Speed', '${current['wind_speed']} m/s'),
        _buildInfoRow('UV Index', current['uvi'].toString()),
      ],
    );
  }

  Widget _hourlyForecast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Forecast',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 24,
            itemBuilder: (context, index) {
              final hourly = _weatherData!['hourly'][index];
              final weather = hourly['weather'][0];
              final dateTime =
                  DateTime.fromMillisecondsSinceEpoch(hourly['dt'] * 1000);
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Text(
                      DateFormat('ha').format(dateTime),
                      style: TextStyle(color: Colors.white),
                    ),
                    Image.network(
                      "http://openweathermap.org/img/wn/${weather['icon']}.png",
                      height: 50,
                      width: 50,
                    ),
                    Text(
                      '${hourly['temp'].toStringAsFixed(1)}°C',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dailyForecast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tomorrow\'s Forecast',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        Column(
          children: List.generate(7, (index) {
            final daily = _weatherData!['daily'][index];
            final weather = daily['weather'][0];
            final dateTime =
                DateTime.fromMillisecondsSinceEpoch(daily['dt'] * 1000);
            return Card(
              color: Colors.blue[700],
              child: ListTile(
                leading: Image.network(
                  "http://openweathermap.org/img/wn/${weather['icon']}.png",
                ),
                title: Text(
                  DateFormat('EEEE').format(dateTime),
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  '${daily['temp']['max'].toStringAsFixed(1)}°C / ${daily['temp']['min'].toStringAsFixed(1)}°C',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
