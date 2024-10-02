import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:smart_hub/Main/home/components/status_circle_card.dart';

import '../../../Components/provider.dart';
import '../constants/home_constants.dart';
import 'battery_level.dart';

class batteryContainer extends StatelessWidget {
  const batteryContainer({
    super.key,
    required this.screenDataProvider,
    required this.isConnected,
    required DiscoveredDevice connectedDevice,
    required this.thermoColor,
    required this.batteryTemp,
    required this.batteryLevel,
    required this.powerColor,
    required this.batteryPower,
  }) : _connectedDevice = connectedDevice;

  final ScreenDataProvider screenDataProvider;
  final bool isConnected;
  final DiscoveredDevice _connectedDevice;
  final Color thermoColor;
  final double batteryTemp;
  final double batteryLevel;
  final Color powerColor;
  final double batteryPower;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            screenDataProvider.isThemeDark ? Color(0x15656566) : Colors.indigo,
        borderRadius: BorderRadius.all(
          Radius.circular(containerRadius),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 15,
                  top: 0,
                ),
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_connectedDevice.name}',
                style: TextStyle(
                  color: screenDataProvider.isThemeDark
                      ? Colors.white70
                      : Colors.black87,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatusCircleCard(
                  circleIcon: Icon(
                    Icons.thermostat,
                    color: thermoColor,
                  ),
                  circleRadius: statusCircleCardRadius,
                  circleText: '$batteryTemp °C',
                  isDark: screenDataProvider.isThemeDark,
                ),
              ),
              Expanded(
                child: BatteryIndicator(
                  batteryLevel: batteryLevel,
                  isCharging: false,
                  isDark: screenDataProvider.isThemeDark,
                  circleRadius: statusCircleCardRadius,
                ),
              ),
              Expanded(
                child: StatusCircleCard(
                  circleIcon: Icon(
                    Icons.flash_on,
                    color: powerColor,
                  ),
                  circleRadius: statusCircleCardRadius,
                  circleText: '$batteryPower W',
                  isDark: screenDataProvider.isThemeDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
