import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:smart_hub/Main/home/home_screen.dart';
import 'dart:async';

import '../../Components/alerts.dart';
import '../../Components/ble_alerts.dart'; // For Timer functionality

/**-----------------Global Variables-------------------------**/
bool g_ScreenReady = false;

/**-----------------------------------------------------------**/
class ble_ui_screen extends StatefulWidget {
  static String id = 'BLE_screen';
  const ble_ui_screen({super.key});
  @override
  State<ble_ui_screen> createState() => _ble_ui_screenState();
}

class _ble_ui_screenState extends State<ble_ui_screen>
    with SingleTickerProviderStateMixin {
  /**---------------------Local Variables Section----------------------**/
  final flutterReactiveBle = FlutterReactiveBle();
  late Stream<BleStatus> _bleStatusStream;
  List<Map<String, dynamic>> discoveredDevices = [];
  bool isScanning = false;
  Timer? _scanTimer;

  // Animation controller for button feedback
  late AnimationController _controller;
  late Animation<double> _animation;
  /**------------------------------------------------------------------**/

  /**------------------------Function Section--------------------------**/
  void ble_enable_state_check() {
    _bleStatusStream.listen((status) {
      if (status == BleStatus.ready) {
        print('Bluetooth is ON');
      } else if (status == BleStatus.poweredOff) {
        print('Bluetooth is OFF');
        errorCheckble(context, 'BLE_OFF');
      } else {
        print('Bluetooth status: $status');
      }
    });
  }

  // Function to start BLE scanning
  void startScan() {
    setState(() {
      isScanning = true;
      discoveredDevices.clear(); // Clear previous devices
      _controller.forward(); // Start the heartbeat animation
    });

    // Start scanning for BLE devices
    flutterReactiveBle.scanForDevices(withServices: []).listen((device) async {
      //if (device.name.isNotEmpty)
      {
        final services = await getDeviceServices(device.id);
        print(device.id);
        // Add devices to the discovered list if not already present
        setState(() {
          if (!discoveredDevices.any((d) => d['device'].id == device.id)) {
            discoveredDevices.add({'device': device, 'services': services});
          }
        });
      }
    }, onError: (e) {
      print("Error scanning for devices: $e");
      stopScan();
    });

    // Set a timer to stop the scan after 10 seconds
    _scanTimer = Timer(Duration(seconds: 10), () {
      stopScan();
    });
  }

  // Function to stop BLE scanning
  void stopScan() {
    setState(() {
      isScanning = false;
      _controller.stop(); // Stop heartbeat animation
    });
    // Cancel the timer if it's still running
    _scanTimer?.cancel();
  }

  // Function to handle stop button press
  void onStopButtonPressed() {
    stopScan(); // Manually stop scanning
  }

  // Function to handle scan button press
  void onScanButtonPressed() {
    if (!isScanning) {
      startScan(); // Start scanning for devices
    }
  }

  // Function to get device services
  Future<List<String>> getDeviceServices(String deviceId) async {
    try {
      // Connect to the device to discover services
      await flutterReactiveBle.connectToDevice(id: deviceId).first;
      final services = await flutterReactiveBle.discoverServices(deviceId);

      // Extract UUID strings from the services
      return services.map((service) => service.serviceId.toString()).toList();
    } catch (e) {
      print('Failed to discover services for $deviceId: $e');
      return [];
    }
  }

  // Function to map service UUID to an icon
  IconData getServiceIcon(String serviceUUID) {
    // Add logic to match specific services UUIDs with icons
    if (serviceUUID.contains("180D")) {
      return Icons.favorite; // Example: Heart rate service
    } else if (serviceUUID.contains("FFE0")) {
      return Icons
          .battery_charging_full; // Example: FFE0 is set for the smartHUB
    } else {
      return Icons.devices; // Default service icon
    }
  }

  /**------------------------------------------------------------------**/
  @override
  void initState() {
    super.initState();
    _bleStatusStream = flutterReactiveBle.statusStream;
    ble_enable_state_check();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600), // Adjust for heartbeat speed
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    // Tween for heartbeat scaling effect
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Header
            const Text(
              'SmartHub Bluetooth',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              isScanning ? 'Scanning for devices...' : 'Scan Stopped',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 40),
            // Bluetooth Button with Heartbeat Animation
            GestureDetector(
              onTap: onScanButtonPressed,
              child: Transform.scale(
                scale: isScanning
                    ? _animation.value
                    : 1.0, // Apply the scaling animation
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Colors.blueAccent, Colors.transparent],
                      stops: [0.5, 1.0],
                      center: Alignment.center,
                      radius: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            // Stop Button
            if (isScanning)
              ElevatedButton(
                onPressed: onStopButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Stop Scan',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            // Scanned Devices (cards)
            Expanded(
              child: ListView.builder(
                itemCount: discoveredDevices.length,
                itemBuilder: (context, index) {
                  final device = discoveredDevices[index]['device'];
                  final services = discoveredDevices[index]['services'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white54, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Service Icon
                              Icon(
                                getServiceIcon(
                                    services.isNotEmpty ? services[0] : ""),
                                color: Colors.white,
                                size: 40,
                              ),
                              SizedBox(width: 15),
                              // Device Name and Service Name
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    services.isNotEmpty
                                        ? 'Service: ${services[0]}'
                                        : 'No services found',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // Pairing logic here
                              if (!isScanning) {
                                try {
                                  // Attempt to connect to the device
                                  final connectionStream = flutterReactiveBle
                                      .connectToDevice(id: device.id);
                                  toastFun('Connecting');
                                  print(DeviceConnectionState.connected);
                                  await connectionStream.firstWhere((event) =>
                                      event.connectionState ==
                                      DeviceConnectionState.connected);

                                  //toastFun('Connected');
                                  //Navigator.pushNamed(context, home_screen.id);
                                  // If connected successfully, navigate to the home screen
                                } catch (e) {
                                  // Handle errors during connection
                                  print("Failed to connect to device: $e");

                                  // Show error message
                                  toastFun('Failed to Connect');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blueAccent, // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Pair',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
