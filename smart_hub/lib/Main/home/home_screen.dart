import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../../Components/alerts.dart';
import '../../Components/drawer_list.dart';
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
  /**---------------------Local Variables Section----------------------**/
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isConnected = true;
  final flutterReactiveBle = FlutterReactiveBle();
  /**------------------------------------------------------------------**/

  void connectionChecker() {
    // Assuming you have access to the StreamSubscription<ConnectionStateUpdate> variable for this device

    flutterReactiveBle.connectToDevice(id: widget.connectedDevice.id).listen(
        (connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        // Device is connected
        toastFun('Connected');
        print('Device ${widget.connectedDevice.name} is still connected.');
      } else if (connectionState.connectionState ==
          DeviceConnectionState.disconnected) {
        // Device is disconnected
        toastFun('disConnected');
        print('Device ${widget.connectedDevice.name} is disconnected.');
      } else {
        toastFun('Already connected');
      }
    }, onError: (error) {
      print('Error connecting to device: $error');
      toastFun('error');
    });
  }

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
      key: _scaffoldKey,
      drawer: drawerList(
        isConnected: isConnected,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            child: IconButton(
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                size: 30,
              ),
            ),
          ),
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
              connectionChecker();
            },
            child: Text('unpair'),
          ),
        ],
      ),
    );
  }
}
