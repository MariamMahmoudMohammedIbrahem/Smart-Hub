import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:smart_hub/Main/BLE/ble_ui.dart';
import 'package:smart_hub/Main/home/home_screen.dart';
import 'package:smart_hub/Main/loading_screen.dart';

import 'Main/Support/support.dart';

late final StreamSubscription<ConnectionStateUpdate> connectionNUM;
late final DiscoveredDevice connectedDevice;
late final QualifiedCharacteristic characteristic;

void main() {
  runApp(SmartHUB());
}

class SmartHUB extends StatelessWidget {
  const SmartHUB({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        /* This screen is responsible for loading all packages used before the app launch */
        initialRoute: welcome_loading_screen.id,
        routes: {
          welcome_loading_screen.id: (context) =>
              const welcome_loading_screen(),
          ble_ui_screen.id: (context) => const ble_ui_screen(),
          home_screen.id: (context) => home_screen(
                connectionNUM: connectionNUM,
                connectedDevice: connectedDevice,
                characteristic: characteristic,
              ),
          support_screen.id: (context) => const support_screen(),
        });
  }
}
