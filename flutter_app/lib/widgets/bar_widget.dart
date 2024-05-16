import 'package:flutter/material.dart';
import 'widgets.dart';

class BarWidget extends StatelessWidget {
  const BarWidget({Key? key,
    required this.barGap,
    required this.value,
    required this.color,
    required this.titleGap,
    required this.titleWidget});

  final double barGap;
  final double titleGap;
  final Widget titleWidget;
  final num value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              SizedBox(
                width: barGap,
              ),
              Expanded(
                child: Container(
                  height: value.toDouble(),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                    color: color,
                  ),
                ),
              ),
              SizedBox(
                width: barGap,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          titleWidget,
        ],
      ),
    );
  }
}
