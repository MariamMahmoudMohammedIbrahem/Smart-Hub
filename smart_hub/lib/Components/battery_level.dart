import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class BatteryIndicator extends StatelessWidget {
  final double batteryLevel; // A value between 0 and 100
  final bool isCharging;

  BatteryIndicator({required this.batteryLevel, required this.isCharging});

  @override
  Widget build(BuildContext context) {
    Color batteryColor;
    if (batteryLevel >= 70) {
      batteryColor = Colors.green;
    } else if (batteryLevel >= 30) {
      batteryColor = Colors.yellow;
    } else {
      batteryColor = Colors.red;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        LinearPercentIndicator(
          width: 200.0,
          lineHeight: 20.0,
          percent: batteryLevel,
          backgroundColor: Colors.grey[300]!,
          progressColor: batteryColor,
          center: Text("${(batteryLevel * 100).toInt()}%"),
        ),
        if (isCharging)
          Positioned(
            right: 10,
            child: Icon(
              Icons.bolt,
              color: Colors.yellow,
            ),
          ),
      ],
    );
  }
}
