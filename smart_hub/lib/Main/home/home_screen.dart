import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class home_screen extends StatefulWidget {
  static String id = 'home_screen';
  const home_screen({super.key});
  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<ConnectionStateUpdate> _connection;
  late QualifiedCharacteristic _writeCharacteristic;
  late QualifiedCharacteristic _readCharacteristic;

  bool isConnected = false;
  String receivedData = '';
  final TextEditingController _sendController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Get device ID from arguments or another source
    final deviceId = 'your_device_id'; // Replace with actual device ID

    _connection = flutterReactiveBle
        .connectToDevice(id: deviceId)
        .listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        setState(() {
          isConnected = true;
        });
        // Initialize characteristics after connection is established
        initializeCharacteristics(deviceId);
      } else if (connectionState.connectionState ==
          DeviceConnectionState.disconnected) {
        setState(() {
          isConnected = false;
        });
      }
    });
  }

  Future<void> initializeCharacteristics(String deviceId) async {
    try {
      // Replace with actual service and characteristic UUIDs
      final serviceId = Uuid.parse('your_service_uuid');
      final writeCharacteristicId =
          Uuid.parse('your_write_characteristic_uuid');
      final readCharacteristicId = Uuid.parse('your_read_characteristic_uuid');

      _writeCharacteristic = QualifiedCharacteristic(
        characteristicId: writeCharacteristicId,
        serviceId: serviceId,
        deviceId: deviceId,
      );

      _readCharacteristic = QualifiedCharacteristic(
        characteristicId: readCharacteristicId,
        serviceId: serviceId,
        deviceId: deviceId,
      );

      // Listen to the read characteristic for updates
      flutterReactiveBle
          .subscribeToCharacteristic(_readCharacteristic)
          .listen((data) {
        setState(() {
          receivedData = String.fromCharCodes(data);
        });
      });
    } catch (e) {
      print("Failed to initialize characteristics: $e");
    }
  }

  @override
  void dispose() {
    _connection.cancel();
    super.dispose();
  }

  Future<void> sendData(String data) async {
    try {
      await flutterReactiveBle.writeCharacteristicWithResponse(
        _writeCharacteristic,
        value: data.codeUnits,
      );
    } catch (e) {
      print("Failed to send data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Received Data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              receivedData,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _sendController,
              decoration: InputDecoration(
                labelText: 'Send Data',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (isConnected) {
                  sendData(_sendController.text);
                } else {
                  // Show message if not connected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Device not connected')),
                  );
                }
              },
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
