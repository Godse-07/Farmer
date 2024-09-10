import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class pricePrediction extends StatefulWidget {
  @override
  _PricePredictionState createState() => _PricePredictionState();
}

class _PricePredictionState extends State<pricePrediction> {
  final List<double> prices = [43.70, 43.13, 43.00, 43.10, 42.10, 43.11, 42.13];
  final List<int> days = [9, 10, 11, 12, 13, 14, 15];
  final List<String> day_full = [
    "09/09/24",
    "10/09/24",
    "11/09/24",
    "12/09/24",
    "13/09/24",
    "14/09/24",
    "15/09/24"
  ];

  final List<String> crop = ["Rice"];

  // Variable to hold the selected crop
  String? selectedCrop = "Rice"; // Default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Price Detection"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[400]!, Colors.blue[900]!],
            ),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(top: 8),
                padding:
                    EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                child: DropdownButton<String>(
                  value: selectedCrop,
                  items: crop.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  iconEnabledColor: Colors.black,
                  dropdownColor: Colors.white,
                  underline: SizedBox(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCrop = newValue; // Update the selected crop
                    });
                  },
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Rice Prices (Last 7 Days)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(2),
                          child: LineChart(
                            LineChartData(
                              backgroundColor: Colors.transparent,
                              gridData: FlGridData(
                                show: true,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.black.withOpacity(0.2),
                                    strokeWidth: 1,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: Colors.black.withOpacity(0.2),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const style = TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      );
                                      switch (value.toInt()) {
                                        case 0:
                                          return Text('9', style: style);
                                        case 1:
                                          return Text('10', style: style);
                                        case 2:
                                          return Text('11', style: style);
                                        case 3:
                                          return Text('12', style: style);
                                        case 4:
                                          return Text('13', style: style);
                                        case 5:
                                          return Text('14', style: style);
                                        case 6:
                                          return Text('15', style: style);
                                        default:
                                          return Container();
                                      }
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toStringAsFixed(2),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, prices[0]),
                                    FlSpot(1, prices[1]),
                                    FlSpot(2, prices[2]),
                                    FlSpot(3, prices[3]),
                                    FlSpot(4, prices[4]),
                                    FlSpot(5, prices[5]),
                                    FlSpot(6, prices[6]),
                                  ],
                                  isCurved: true,
                                  color: Colors.orange,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    checkToShowDot: (spot, barData) => true,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
                                            FlDotCirclePainter(
                                      radius: 6,
                                      color: Colors.orange,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orangeAccent.withOpacity(0.3),
                                        Colors.orangeAccent.withOpacity(0.0),
                                      ],
                                      stops: [0.5, 1.0],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text(
                                "Day",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: Colors.orange),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Price (₹)",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            days.length,
                            (index) => DataRow(
                              cells: [
                                DataCell(Text(
                                  day_full[index],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                )),
                                DataCell(Text(
                                  prices[index].toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Current Price",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "\₹${prices.last.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: pricePrediction()));
}
