import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../../Constants/ble_constants.dart';
import '../BLE/ble_ui.dart';

class home_screen extends StatefulWidget {
  static String id = 'home_screen';
  final StreamSubscription<ConnectionStateUpdate> connectionNUM;
  final DiscoveredDevice connectedDevice;
  final QualifiedCharacteristic characteristic;
  const home_screen({
    super.key,
    required this.connectionNUM, // Marking as required
    required this.connectedDevice, // Marking as required
    required this.characteristic,
  });
  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  // Function to send data to the connected device
  Future<void> sendData(String data) async {
    await FlutterReactiveBle().writeCharacteristicWithResponse(
        widget.characteristic,
        value: data.codeUnits);
    print('Data sent: $data');
  }

  // Function to receive data from the connected device
  Stream<List<int>> receiveData() {
    return FlutterReactiveBle()
        .subscribeToCharacteristic(widget.characteristic);
  }

  @override
  void initState() {
    super.initState();
    receiveData();
  }

  @override
  void dispose() {
    super.dispose();
    widget.connectionNUM.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Connected to: ${widget.connectedDevice.name}'),
            ElevatedButton(
              onPressed: () {
                // Example usage: Send "Hello" to the connected device

                sendData('Hello\n');
              },
              child: Text('Send Data'),
            ),
            ElevatedButton(
              onPressed: () {
                // Example: Listening to data from the connected device

                receiveData().listen((data) {
                  print('Received data: ${String.fromCharCodes(data)}');
                });
              },
              child: Text('Receive Data'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.connectionNUM.cancel();
                Navigator.pushReplacementNamed(context, ble_ui_screen.id);
              },
              child: Text('unpair'),
            ),
          ],
        ),
      ),
    );
  }
}
