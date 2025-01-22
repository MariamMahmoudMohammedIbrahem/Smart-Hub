part of 'home_screen.dart';

abstract class HomeController extends State<HomeScreen> {

  /// ---------------------Local Variables Section----------------------*
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isConnected = true;
  final flutterReactiveBle = FlutterReactiveBle();
  bool isScanning = false;
  late DiscoveredDevice _connectedDevice;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  late StreamSubscription<DiscoveredDevice> _scanStream;
  final List<DiscoveredDevice> _foundDevices = [];

/* Handling AppBar vars */
  String greetingMessage = "";
  bool showGreeting = true; // To control which text is shown
  late Timer _timer;

  /* Local storage  */
  late final SharedPreferences prefs;
  late String savedDeviceID;
  bool screenReady = false;
  /* Receiving Var */
  final List<int> _receivedData = [];

  /* Variable to handle the reconnection */
  int reconnectTrial = 0;

  /* Pair loading animation */
  bool isPairLoading = false;

  /// -Frame Variables-*
  /* Battery part */
  double batteryLevel = 0.2;
  double batteryTemp = 30;
  double batteryPower = 60;
  bool batteryIsCharging = false;

  String portAName = 'PORT A';
  String portCName = 'PORT C';

  /// Port Containers name *
  // String Port1Name = 'P1';
  // String Port_Second_Container_Name = 'P2';
  // bool wireless_isCharging = false;
  /* Ports Connection */
  /* Port C */
  // bool portC_ChannelOne_isConnected = true;
  // bool portC_ChannelTwo_isConnected = false;
  double portC1Power = 0;
  double portC2Power = 0;
  /* Port A */
  // bool portA_ChannelOne_isConnected = true;
  // bool portA_ChannelTwo_isConnected = true;
  double portA1Power = 0;
  double portA2Power = 0;
  /* Others */
  bool sdCardIsConnected = false;
  bool hdmiIsConnected = false;

  String port1Name = 'P1';
  String port2Name = 'P2';
  /// ---------------------------Port END------------------------*
  Future<void> initPackages() async {
    /* Just passing the variables */
    _connection = widget.connectionNUM;
    _connectedDevice = widget.connectedDevice;
    /* Save the device in the storage */
    prefs = await SharedPreferences.getInstance();
    /* keeps listening to the connection */
    _receiveData();
    /* Check on the Connection */
    connectionChecker();
  }

  /*
  Title: Get from Local Storage
  Description: This function uses shared preference package to get some information

 */
  bool getThemeFromLocalStorage() {
    final bool screenTheme =
        prefs.getBool('Theme') ?? false; // save the device id
    return screenTheme;
  }

  /*
  Title: Save in Local Storage
  Description: This function uses shared preference package to
  save the device id
   */
  Future<void> saveToLocalStorage(DiscoveredDevice device) async {
    await prefs.setString('ConnectedDevice', device.id); // save the device id
  }

  /*
  Title: Get from Local Storage
  Description: This function uses shared preference package to get some information
               about the last connected device
 */
  void getFromLocalStorage() {
    savedDeviceID =
        prefs.getString('ConnectedDevice') ?? 'null'; // save the device id
    if (savedDeviceID != 'null') {}
  }

  /* This function scans the surrounding device to check of the device was still
  * found or not
  */
  void startDeviceScan() {
    setState(() {
      isPairLoading = true;
      reconnectTrial++;
      isConnected = false;
    });
    // Clear previously found devices before starting the scan

    // Start scanning for devices
    _scanStream =
        flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
          print(reconnectTrial);
          // Add devices to the discovered list if not already present
          setState(() {
            if (!_foundDevices.any((d) => d.id == device.id)) {
              if (device.id == widget.connectedDevice.id) {
                reconnectTrial = 0; /* reinit the variable */
                _foundDevices.clear();
                _scanStream.cancel(); // Stops scanning
                connectionChecker();
              }
              _foundDevices.add(device); // Add newly found device
            }
          });
        }, onError: (e) {
          _scanStream.cancel(); // Stops scanning on error
          setState(() {
            isPairLoading = false;
          });
        });

    // Set a timer to stop scanning after 4 seconds
    Timer(const Duration(seconds: 3), () {
      _scanStream.cancel(); // Stops scanning after 4 seconds

      if (reconnectTrial >= 2) {
        toastFun('${_connectedDevice.name} not found\nRedirecting!',
            getThemeFromLocalStorage());
        Navigator.pushReplacementNamed(context, BleScreen.id);
      } else if (reconnectTrial == 0) {
        setState(() {
          isPairLoading = false;
        });
        /* Do nothing here */
      } else {
        setState(() {
          isPairLoading = false;
        });
        toastFun(
            '${_connectedDevice.name} not found\nPlease turn it on and try again.',
            getThemeFromLocalStorage());
      }
    });
  }

  /*
  Title: Get from Local Storage
  Description: This function uses shared preference package to
  delete all variables inside the the key 'ConnectedDevice'
 */
  void deleteLocalStorage() {
    prefs.remove('ConnectedDevice'); // save the device id
  }

  /*
  Title: Get from Local Storage
  Description: This function uses shared preference package to
  delete all variables inside the the key 'ConnectedDevice'
 */
  void connectionChecker() {
    print('connectionChecker function');
    // Assuming you have access to the StreamSubscription<ConnectionStateUpdate> variable for this device
    _connection = flutterReactiveBle
        .connectToDevice(
      id: _connectedDevice.id,
      connectionTimeout: const Duration(seconds: 4),
    )
        .listen((connectionState) async {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        // Device is connected
        toastFun('Connection Restored', getThemeFromLocalStorage());
        setState(() {
          isConnected = true;
          isPairLoading = false;
        });
      } else if (connectionState.connectionState ==
          DeviceConnectionState.disconnected) {
        setState(() {
          isConnected = false;
          isPairLoading = false;
        });
        // Device is disconnected
        toastFun('Connection Lost', getThemeFromLocalStorage());
      }
    }, onError: (error) {
      toastFun('Connection Error', getThemeFromLocalStorage());
      setState(() {
        isConnected = false;
        isPairLoading = false;
      });
    });
  }

  void unPairConnection() {
    _connection.cancel();
    toastFun('unPaired', getThemeFromLocalStorage());
  }

  // Function to send data to the connected device
  Future<void> sendData(String data) async {
    await FlutterReactiveBle().writeCharacteristicWithResponse(
        widget.characteristic,
        value: data.codeUnits);
    //print('Data sent: $data');
  }

  // Function to receive data from the connected device
  void _receiveData() {
    FlutterReactiveBle()
        .subscribeToCharacteristic(widget.characteristic)
        .listen((data) {
      setState(() {
        if (_receivedData.length + data.length > 15) {
          _receivedData.clear(); // Clear the list if it exceeds the max size
        }
        _receivedData.addAll(data); // Add new bytes to the list
      });
    }, onError: (error) {
      print("Error receiving data: $error");
    });
  }

  // Convert bytes to their character representation
  String _bytesToCharacters(List<int> bytes) {
    return bytes
        .map((byte) =>
    (byte >= 32 && byte <= 126) ? String.fromCharCode(byte) : '.')
        .join(); // Replace non-printable characters with '.'
  }

  String byteDisplay(int index) {
    if (index < _receivedData.length) {
      return '0x${_receivedData[index].toRadixString(16).toUpperCase()} (${_bytesToCharacters([
        _receivedData[index]
      ])})';
    } else {
      return '0x00 (-)'; // Default for missing data
    }
  }

  // Get the appropriate greeting message based on the current time
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  // Timer to switch the message after 5 seconds
  void _startTimer() {
    _timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        showGreeting = false; // Trigger the switch to "SmartHUB"
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initPackages();
    greetingMessage = _getGreetingMessage(); // Get greeting based on time
    _startTimer(); // Start the timer to change the message after 5 seconds
  }

  @override
  void dispose() {
    super.dispose();
    widget.connectionNUM.cancel();
    _timer.cancel(); // Cancel the timer if the widget is disposed
    _scanStream.cancel(); /* Stops Scanning */
  }
}