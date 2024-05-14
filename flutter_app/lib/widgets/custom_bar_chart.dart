import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'widgets.dart';

class CustomBarChart extends StatefulWidget {
  const CustomBarChart(
      this.values,
      {Key? key,
      this.width = double.infinity,
      required this.height,
      required this.gradientColors,
      this.icons = null,
      required this.barColors,
      required this.barGap,
      required this.titleGap,
      required this.maxValue,
      });

  final double width;
  final double height;
  final double maxValue;
  final List<Color> gradientColors;
  final List<IconData>? icons;
  final Color barColors;
  final double barGap;
  final double titleGap;
  final List<List<Object>> values;

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {

  late List<List<Object>> values;
  late int accumulative;
  List<int> markers = [5,4,3,2,1];

  @override
  void initState() {
    super.initState();
    values = widget.values;
    accumulative = (widget.maxValue / 5).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 5, right: 5, bottom: 7.0),
          child: Column(
            children: [
              Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ...widget.values.map(
                        (list) => BarWidget(
                          barGap: widget.barGap,
                          titleGap: widget.titleGap,
                          titleWidget: list[0] as Widget,
                          value: list[1] as num,
                          color: widget.barColors,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            ...markers.map((index) {
              return Text("${(index) * accumulative}");
            }),
          ],
        ),
      ],
    );
  }
}
