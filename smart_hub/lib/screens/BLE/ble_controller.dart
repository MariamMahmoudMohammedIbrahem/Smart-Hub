part of 'ble_screen.dart';

abstract class BleController extends State<BleScreen> with SingleTickerProviderStateMixin{

  /// ---------------------Local Variables Section----------------------*
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late Stream<BleStatus> _bleStatusStream;
  final List<DiscoveredDevice> _foundDevices = [];
  late QualifiedCharacteristic _characteristic;
  late DiscoveredDevice _connectedDevice;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  bool isScanning = false;
  bool isPairing = false;
  bool isNavigated = false;
  Timer? _scanTimer;
  Map<String, bool> isLoadingMap = {};
  Map<String, bool> isPairedMap = {};

  bool devicePaired = false;
  String? pairedDeviceName;
  String? pairedDeviceId;
  late String savedDeviceID;

  /* Local storage  */
  late final SharedPreferences prefs;

  final Map<String, StreamSubscription<ConnectionStateUpdate>> _subscriptions = {};
  Map<String, bool> connectedDevices =
  {}; // Track connection state by device ID

  // Animation controller for button feedback
  late AnimationController _controller;
  late Animation<double> _animation;

  /**------------------------------------------------------------------**/

  /// ------------------------Function Section--------------------------*
  void bleEnableStateCheck() {
    _bleStatusStream.listen((status) {
      if (status == BleStatus.ready) {
        print('Bluetooth is ON');
      } else if (status == BleStatus.poweredOff) {
        print('Bluetooth is OFF');
        errorCheckBle(context, 'BLE_OFF');
      } else {
        print('Bluetooth status: $status');
      }
    });
  }

  void errorCheckBle(BuildContext context, String errorMessage) {
    if (errorMessage == 'BLE_OFF') {
      alertFunBLE(context, 'Bluetooth issue', 'Please turn on your bluetooth!',
          AlertType.warning);
    } else {
      alertFunBLE(
        context,
        'Error',
        'Unknown error!\n try again',
        AlertType.error,
      );
    }
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
    _scanTimer = Timer(const Duration(seconds: 10), () {
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
    toastFun('Unpaired', true);
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
      isLoadingMap[device.id] = true;
      isPairedMap[device.id] = false;
      isNavigated = false;
    });

    try {
      _connection = flutterReactiveBle
          .connectToDevice(
        id: device.id,
        connectionTimeout: const Duration(seconds: 5),
      )
          .listen((connectionState) {
        if (connectionState.connectionState ==
            DeviceConnectionState.connected) {
          setState(() {
            isNavigated = true;
            isPairing = false;
            // Discover services and characteristics
            _characteristic = QualifiedCharacteristic(
              serviceId: Uuid.parse(serviceUuid),
              characteristicId: Uuid.parse(txUuid),
              deviceId: device.id,
            );

            _connectedDevice = device;
            toastFun('Connected to ${device.name}', true);
            isLoadingMap[device.id] = false;
            isPairedMap[device.id] = true;
            saveToLocalStorage(device);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  connectionNUM: _connection,
                  connectedDevice: _connectedDevice,
                  characteristic: _characteristic,
                ),
              ),
            );
          });
        } else if (connectionState.connectionState ==
            DeviceConnectionState.disconnected) {
          setState(() {
            isPairing = false;
            isLoadingMap[device.id] = false;
            isPairedMap[device.id] = false;
            if (isNavigated == false) toastFun('Not Connected', true);
          });
        }
      });
    } catch (e) {
      print("Error while connecting: $e");
      setState(() {
        isPairing = false;
        isLoadingMap[device.id] = false;
        isPairedMap[device.id] = false;
      });
      toastFun('Error while Connecting', true);
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
  IconData getServiceIcon(String deviceName) {
    if (RegExp(r"SmartHUB").hasMatch(deviceName)) {
      return Icons.battery_charging_full;
    } else if (RegExp(r"[TV]").hasMatch(deviceName)) {
      return Icons.connected_tv_rounded;
    } else if (RegExp(r"TV").hasMatch(deviceName)) {
      return Icons.connected_tv_rounded;
    } else if (RegExp(r"Band").hasMatch(deviceName)) {
      return Icons.watch;
    } else if (RegExp(r"Watch").hasMatch(deviceName)) {
      return Icons.watch;
    } else if (RegExp(r"keyboard").hasMatch(deviceName)) {
      return Icons.keyboard_alt_outlined;
    } else if (RegExp(r"mouse").hasMatch(deviceName)) {
      return Icons.mouse;
    } else if (RegExp(r"speaker").hasMatch(deviceName)) {
      return Icons.speaker;
    } else if (RegExp(r"printer").hasMatch(deviceName)) {
      return Icons.print;
    } else {
      return Icons.bluetooth;
    }
  }

  Future<void> initPackages() async {
    _bleStatusStream = flutterReactiveBle.statusStream;
    prefs = await SharedPreferences.getInstance();
  }

  /// ------------------------------------------------------------------*
  @override
  void initState() {
    super.initState();
    initPackages();
    bleEnableStateCheck();

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
}