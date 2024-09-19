import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class home_screen extends StatefulWidget {
  static String id = 'home_screen';
  final StreamSubscription<ConnectionStateUpdate> connectionNUM;
  final DiscoveredDevice connectedDevice;

  const home_screen({
    super.key,
    required this.connectionNUM, // Marking as required
    required this.connectedDevice, // Marking as required
  });
  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  // UUIDs for the HM-10 (replace with the correct UUIDs if different)
  final String _serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  final String _txUuid =
      "0000ffe1-0000-1000-8000-00805f9b34fb"; // Tx characteristic UUID for writing

  // Function to send data to the connected device
  Future<void> sendData(
      String data, QualifiedCharacteristic characteristic) async {
    await FlutterReactiveBle()
        .writeCharacteristicWithResponse(characteristic, value: data.codeUnits);
    print('Data sent: $data');
  }

  // Function to receive data from the connected device
  Stream<List<int>> receiveData(QualifiedCharacteristic characteristic) {
    return FlutterReactiveBle().subscribeToCharacteristic(characteristic);
  }

  @override
  void initState() {
    super.initState();
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
                QualifiedCharacteristic txCharacteristic =
                    QualifiedCharacteristic(
                  deviceId: widget.connectedDevice.id,
                  serviceId: Uuid.parse(_serviceUuid),
                  characteristicId: Uuid.parse(_txUuid),
                );
                sendData('Hello', txCharacteristic);
              },
              child: Text('Send Data'),
            ),
            ElevatedButton(
              onPressed: () {
                // Example: Listening to data from the connected device
                QualifiedCharacteristic rxCharacteristic =
                    QualifiedCharacteristic(
                  deviceId: widget.connectedDevice.id,
                  serviceId: Uuid.parse(_serviceUuid),
                  characteristicId: Uuid.parse(_txUuid),
                );
                receiveData(rxCharacteristic).listen((data) {
                  print('Received data: ${String.fromCharCodes(data)}');
                });
              },
              child: Text('Receive Data'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.connectionNUM.cancel();
              },
              child: Text('unpair'),
            ),
          ],
        ),
      ),
    );
  }
}
