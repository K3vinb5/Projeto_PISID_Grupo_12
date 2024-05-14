import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:pisid/widgets/custom_bar_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReadingsRoomScreen extends StatefulWidget {
  const ReadingsRoomScreen({Key? key}) : super(key: key);

  @override
  _ReadingsRoomScreenState createState() => _ReadingsRoomScreenState();
}

class _ReadingsRoomScreenState extends State<ReadingsRoomScreen> {
  late int showingTooltip;
  late Timer timer;

  @override
  void initState() {
    showingTooltip = -1;
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (Timer t) => getReadings());
    super.initState();
  }

  var readingsValues = <double>[];
  var readingsTimes = <double>[];
  var minY = 0.0;
  var maxY = 100.0;

  BarChartGroupData generateGroupData(int x, int y) {
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: showingTooltip == x ? [0] : [],
      barRods: [
        BarChartRodData(toY: y.toDouble()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    getReadings();
    int sizelist = readingsTimes.length;
    for (int i = sizelist; i < 9; i++) {
      readingsTimes.add(i + 2 + .0);
      readingsValues.add(0.0);
    }
    //sleep(Duration(seconds:2));
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 60),
        child: BarChart(
            BarChartData(
              barGroups: [
                /*generateGroupData(readingsTimes[0].toInt(),readingsValues[0].toInt()),
                generateGroupData(readingsTimes[1].toInt(),readingsValues[1].toInt()),
                generateGroupData(readingsTimes[2].toInt(),readingsValues[2].toInt()),
                generateGroupData(readingsTimes[3].toInt(),readingsValues[3].toInt()),
                generateGroupData(readingsTimes[4].toInt(),readingsValues[4].toInt()),
                generateGroupData(readingsTimes[5].toInt(),readingsValues[5].toInt()),
                generateGroupData(readingsTimes[6].toInt(),readingsValues[6].toInt()),
                generateGroupData(readingsTimes[7].toInt(),readingsValues[7].toInt()),
                generateGroupData(readingsTimes[8].toInt(),readingsValues[8].toInt()),*/
                generateGroupData(1, 0),
                generateGroupData(2, 0),
                generateGroupData(3, 17),
                generateGroupData(4, 2),
                generateGroupData(5, 14),
                generateGroupData(6, 1),
                generateGroupData(7, 1),
                generateGroupData(8, 2),
                generateGroupData(9, 29),
                generateGroupData(10, 14),
              ],
              barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchCallback: (event, response) {
                    if (response != null && response.spot != null && event is FlTapUpEvent) {
                      setState(() {
                        final x = response.spot!.touchedBarGroup.x;
                        final isShowing = showingTooltip == x;
                        if (isShowing) {
                          showingTooltip = -1;
                        } else {
                          showingTooltip = x;
                        }
                      });
                    }
                  },
                  mouseCursorResolver: (event, response) {
                    return response == null || response.spot == null
                        ? MouseCursor.defer
                        : SystemMouseCursors.click;
                  }
              ),
            ),
          ),
      ),
    );
  }

  getReadings() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    String? ip = prefs.getString('ip');
    String? port = prefs.getString('port');
    String readingsURL =
        "http://" + ip! + ":" + port! + "/scripts/getMouseRoom.php";
    var response = await http.post(Uri.parse(readingsURL),
        body: {'username': username, 'password': password});

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      var data = jsonData["readings"];
      setState(() {
        readingsValues.clear();
        readingsTimes.clear();
        minY = 0;
        maxY = 100;

        if (data != null && data.length > 0) {
          for (var reading in data) {
            double readingTime = double.parse(reading["Room"].toString());
            var value = double.parse(reading["TotalMouse"].toString());
            readingsTimes.add(readingTime);
            readingsValues.add(value);
          }
          if (readingsValues.isNotEmpty) {
            minY = readingsValues.reduce(min) - 1;
            maxY = readingsValues.reduce(max) + 1;
          }
        }
      });
    }
  }
}
