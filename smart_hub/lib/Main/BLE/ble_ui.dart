import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_hub/Components/alerts.dart';
import 'package:smart_hub/Main/home/home_screen.dart';
import 'dart:async';
import '../../Components/ble_alerts.dart';
import '../../Constants/ble_constants.dart'; // For Timer functionality

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
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late Stream<BleStatus> _bleStatusStream;
  List<DiscoveredDevice> _foundDevices = [];
  late QualifiedCharacteristic _Characteristic;
  late DiscoveredDevice _connectedDevice;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  bool _isConnected = false;
  bool isScanning = false;
  Timer? _scanTimer;
  Map<String, bool> isLoadingMap = {};
  Map<String, bool> isPairedMap = {};

  bool devicePaired = false;
  String? pairedDeviceName;
  String? pairedDeviceId;

  /* Local storage  */
  late final SharedPreferences prefs;

  Map<String, StreamSubscription<ConnectionStateUpdate>> _subscriptions = {};
  Map<String, bool> connectedDevices =
      {}; // Track connection state by device ID

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
      _foundDevices.clear(); // Clear previous devices
      _controller.forward(); // Start the heartbeat animation
    });

    // Start scanning for BLE devices
    _scanStream =
        flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
      // Add devices to the discovered list if not already present
      setState(() {
        if (!_foundDevices.any((d) => d.id == device.id)) {
          if (device.name != '') {
            _foundDevices.add(device);
          }
        }
      });
    }, onError: (e) {
      print("Error scanning for devices: $e");
      stopScan();
      isScanning = false;
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
      _scanStream.cancel(); /* Stops Scanning */
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

  Future<void> disconnectDevice(String deviceId) async {
    await _connection.cancel();
    toastFun('Unpaired');
    setState(() {
      isPairedMap[deviceId] = false;
    });
  }

  Future<void> saveToLocalStorage(DiscoveredDevice device) async {
    await prefs.setString('ConnectedDevice', device.id); // save the device id
  }

  // Connect to a device
  Future<void> _connectToDevice(DiscoveredDevice device) async {
    setState(() {
      _isConnected = false;
      isLoadingMap[device.id] = true;
      isPairedMap[device.id] = false;
    });

    try {
      _connection = await flutterReactiveBle
          .connectToDevice(
        id: device.id,
        connectionTimeout: const Duration(seconds: 10),
      )
          .listen((connectionState) {
        if (connectionState.connectionState ==
            DeviceConnectionState.connected) {
          setState(() {
            // Discover services and characteristics
            _Characteristic = QualifiedCharacteristic(
              serviceId: Uuid.parse(serviceUuid),
              characteristicId: Uuid.parse(txUuid),
              deviceId: device.id,
            );

            _connectedDevice = device;
            _isConnected = true;
            toastFun('Connected to ${device.name}');
            isLoadingMap[device.id] = false;
            isPairedMap[device.id] = true;
            saveToLocalStorage(device);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => home_screen(
                  connectionNUM: _connection,
                  connectedDevice: _connectedDevice,
                  characteristic: _Characteristic,
                ),
              ),
            );
          });
        } else if (connectionState.connectionState ==
            DeviceConnectionState.disconnected) {
          setState(() {
            isLoadingMap[device.id] = false;
            isPairedMap[device.id] = false;
            _isConnected = false;
            toastFun('Not Connected');
          });
        }
      });
    } catch (e) {
      print("Error while connecting: $e");
      setState(() {
        isLoadingMap[device.id] = false;
        isPairedMap[device.id] = false;
        _isConnected = false;
      });
      toastFun('Error while Connecting');
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

  // Function to map Device name to an icon
  IconData getServiceIcon(String DeviceName) {
    if (RegExp(r"^SmartHUB\b").hasMatch(DeviceName)) {
      return Icons.battery_charging_full;
    } else if (RegExp(r"[TV]").hasMatch(DeviceName)) {
      return Icons.connected_tv_rounded;
    } else if (RegExp(r"TV").hasMatch(DeviceName)) {
      return Icons.connected_tv_rounded;
    } else if (RegExp(r"Band").hasMatch(DeviceName)) {
      return Icons.watch;
    } else if (RegExp(r"keyboard").hasMatch(DeviceName)) {
      return Icons.keyboard_alt_outlined;
    } else if (RegExp(r"mouse").hasMatch(DeviceName)) {
      return Icons.mouse;
    } else if (RegExp(r"speaker").hasMatch(DeviceName)) {
      return Icons.speaker;
    } else if (RegExp(r"printer").hasMatch(DeviceName)) {
      return Icons.print;
    } else {
      return Icons.bluetooth;
    }
  }

  Future<void> initPackages() async {
    _bleStatusStream = flutterReactiveBle.statusStream;
    prefs = await SharedPreferences.getInstance();
  }

  /**------------------------------------------------------------------**/
  @override
  void initState() {
    super.initState();
    initPackages();
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
    _scanStream.cancel();
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
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
              'Connection Setup',
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
            SizedBox(height: 40),
            // Stop Button
            if (isScanning)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Found your device ? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
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
                ],
              ),
            // Scanned Devices (cards)
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _foundDevices.length,
                itemBuilder: (context, index) {
                  final device = _foundDevices[index];

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
                                getServiceIcon(device.name),
                                color: Colors.white,
                                size: 40,
                              ),
                              SizedBox(width: 15),
                              // Device Name and Service Name
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 140,
                                    child: Text(
                                      device.name.isNotEmpty
                                          ? device.name
                                          : "Unknown device",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ("ID: ${device.id}\nRSSI: ${device.rssi}"),
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          isPairedMap[device.id] == true
                              ? ElevatedButton(
                                  onPressed: () {
                                    // Pairing logic here
                                    if (!isScanning) {
                                      disconnectDevice(device.id);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, // Button color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    'unPair',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : isLoadingMap[device.id] == true
                                  ? Container(
                                      width: 77,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Colors.blueAccent,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                      child:
                                          LoadingAnimationWidget.dotsTriangle(
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        // Pairing logic here
                                        if (!isScanning) {
                                          _connectToDevice(device);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.blueAccent, // Button color
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text(
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
