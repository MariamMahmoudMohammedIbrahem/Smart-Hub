part of 'loading_screen.dart';

abstract class LoadingScreenController extends State<LoadingScreen> with SingleTickerProviderStateMixin{

  double batteryLevel = 0.0;
  bool isGlobalVariableTrue = false;
  bool blePermissionGranted = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late final FlutterReactiveBle flutterReactiveBle;
  bool isScanning = false;
  late StreamSubscription<DiscoveredDevice> _scanStream;
  final List<DiscoveredDevice> _foundDevices = [];
  late DiscoveredDevice _connectedDevice;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  late QualifiedCharacteristic _characteristic;

  bool _isConnected = false;
  late String savedDeviceID;
  /* Local storage  */
  late final SharedPreferences prefs;

  /// -------------------------Functions---------------------------------*
/*
  Title: Package init
  Description: Initializing everything at first as well as checks on
               previous connected device if it was found again then
                just re-connect to it again
 */
  Future<void> initPackage() async {
    flutterReactiveBle = FlutterReactiveBle();
    prefs = await SharedPreferences.getInstance();
    // Check for Bluetooth and location permissions
    await _checkAndRequestPermissions();
    await getFromLocalStorage();
  }

  /// -------------------------------------------------------------------*
  /*
  Title: Permission checker
  Description: checks if the required permission are given
 */
  Future<void> _checkAndRequestPermissions() async {
    // Check and request Bluetooth and location permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();

    // Check the status of each permission
    if (statuses[Permission.bluetoothScan]?.isGranted == true &&
        statuses[Permission.bluetoothConnect]?.isGranted == true &&
        statuses[Permission.location]?.isGranted == true) {
      print('All required permissions granted.');
      blePermissionGranted = true;
    } else {
      print('Bluetooth and/or location permission denied.');
      errorCheck(context, 'BLE'); // Handle the case where permission is denied
      blePermissionGranted = false;
    }
  }
  void alertFun(
      BuildContext context, String title, String description, AlertType alertType) {
    Alert(
      context: context,
      type: alertType,
      title: title,
      desc: description,
      style: const AlertStyle(
        backgroundColor: Color(0x9929283A),
        alertElevation: 30,
        animationType: AnimationType.grow,
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(30),
          ),
        ),
        titleStyle: TextStyle(
          color: Colors.white, // Set the title color here
          fontSize: 24, // Adjust the font size if necessary
          fontWeight: FontWeight.bold,
        ),
        descStyle: TextStyle(
          color: Colors.white70, // Set the description text color here
          fontSize: 16,
        ),
      ),
      buttons: [
        DialogButton(
          color: Colors.white12,
          onPressed: () => Navigator.pop(context),
          radius: BorderRadius.circular(20),
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(color: Color(0xFFd5d1dd), fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  void errorCheck(BuildContext context, String errorMessage) {
    if (errorMessage == 'email-already-in-use') {
      /* show the pop up window */
      alertFun(
          context, 'Error', 'This Email is already in use!', AlertType.warning);
    } else if (errorMessage == 'weak-password') {
      alertFun(context, 'Error', 'Password must be more than 6 characters!',
          AlertType.warning);
    } else if (errorMessage == 'invalid-credential') {
      alertFun(context, 'Error', 'Email is not registered on this app!',
          AlertType.error);
    } else if (errorMessage == 'invalid-email') {
      alertFun(context, 'Error', 'Invalid Email!', AlertType.error);
    } else if (errorMessage == 'channel-error') {
      alertFun(context, 'Error', 'Empty Field!', AlertType.error);
    } else if (errorMessage == 'NotAvailable') {
      alertFun(
          context,
          'Error',
          'No Authentication Available\nUse your Email and Password!',
          AlertType.error);
    } else if (errorMessage == 'Timeout') {
      alertFun(context, 'Connection Timeout',
          'Bad internet connection\nPlease try again later!', AlertType.warning);
    } else if (errorMessage == 'SubjectMessageClear') {
      alertFun(
          context,
          'Empty Subject or Message',
          'Please ensure that all necessary containers have been properly filled!',
          AlertType.warning);
    } else if (errorMessage == 'SpeedClear') {
      alertFun(
          context,
          'Empty Container',
          'Please ensure that you have entered a correct speed integer value within range of 0 - 500 Km/h!',
          AlertType.warning);
    } else if (errorMessage == 'BLE') {
      alertFun(
          context,
          'Permission Error',
          'Please enable the access for location and bluetooth and then try again!',
          AlertType.warning);
    } else if (errorMessage == 'BLE_OFF') {
      alertFun(context, 'Bluetooth issue', 'Please turn on your bluetooth!',
          AlertType.warning);
    } else {
      alertFun(
        context,
        'Error',
        'Unknown error!\n try again',
        AlertType.error,
      );
    }
  }
  /// -------------------------------------------------------------------*
  /*
  Title: Animation
  Description: This function makes the animation of the battery
 */
  void batteryAnimation() {
    // Initialize the animation controller
    _controller = AnimationController(
      duration:
      const Duration(seconds: 6), // Duration for one full battery cycle
      vsync: this,
    );

    // Setup a tween for the battery level to animate from 0 to 1
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          batteryLevel =
              _animation.value; // Update batteryLevel as animation progresses

          // Once the battery level reaches 100%, navigate to the Bluetooth screen
          if (batteryLevel == 1 &&
              blePermissionGranted == true &&
              _isConnected == false) {
            Navigator.pushReplacementNamed(context, BleScreen.id);
          } /* In case the device was connected to another module then jump to the home screen */
          else if (batteryLevel == 1 &&
              blePermissionGranted == true &&
              _isConnected == true) {
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
          } else if (batteryLevel == 1 && blePermissionGranted == false) {
            permissionsError(context, 'BLE_PERM');
          }
          /* If the battery level exceeds a certain level then display something else */
          if (batteryLevel >= 0.75) {
            isGlobalVariableTrue = true;
          }
        });
      });

    // Start the animation, moving from 0 to 1 (0% to 100%) once
    _controller.forward();
  }

  void permissionsError(BuildContext context, String errorMessage) {
    if (errorMessage == 'BLE_PERM') {
      alertFunBLEPerm(
          context,
          'Bluetooth issue',
          'Please turn on your bluetooth and make sure you have accepted all the required permissions!',
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
  void alertFunBLEPerm(
      BuildContext context, String title, String description, AlertType alertType) {
    Alert(
      context: context,
      type: alertType,
      title: title,
      desc: description,
      style: const AlertStyle(
        backgroundColor: Color(0x9929283A),
        alertElevation: 30,
        animationType: AnimationType.grow,
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(30),
          ),
        ),
        titleStyle: TextStyle(
          color: Colors.white, // Set the title color here
          fontSize: 24, // Adjust the font size if necessary
          fontWeight: FontWeight.bold,
        ),
        descStyle: TextStyle(
          color: Colors.white70, // Set the description text color here
          fontSize: 16,
        ),
      ),
      buttons: [
        DialogButton(
          color: Colors.white12,
          onPressed: () {
            Phoenix.rebirth(context);
          },
          radius: BorderRadius.circular(20),
          width: 130,
          child: const Center(
            child: Text(
              "Restart",
              style: TextStyle(color: Color(0xFFd5d1dd), fontSize: 20),
            ),
          ),
        )
      ],
    ).show();
  }

  // Function to determine battery color based on the battery level
  Color getBatteryColor(double batteryLevel) {
    if (batteryLevel <= 0.5) {
      return Colors.red; // Battery level less than or equal to 50% is red
    } else if (batteryLevel <= 0.8) {
      return Colors.orange; // Between 50% and 80%, the color is orange
    } else {
      return Colors.green; // Above 80%, the color is green
    }
  }

  /*
  Title: Local Storage
  Description: This function uses shared preference package to get some information
               about the last connected device
 */
  Future<void> getFromLocalStorage() async {
    savedDeviceID =
        prefs.getString('ConnectedDevice') ?? 'null'; // save the device id
    if (savedDeviceID != 'null') {
      startScan();
    }
  }

  /*
  Title: Local Storage
  Description: This function Connects to the given device in case it was found
 */
  Future<void> _connectToDevice(DiscoveredDevice device) async {
    setState(() {
      _isConnected = false;
    });

    try {
      _connection = flutterReactiveBle
          .connectToDevice(
        id: device.id,
        connectionTimeout: const Duration(seconds: 6),
      )
          .listen((connectionState) {
        if (connectionState.connectionState ==
            DeviceConnectionState.connected) {
          setState(() {
            _connectedDevice = device;
            _isConnected = true;
            _characteristic = QualifiedCharacteristic(
              serviceId: Uuid.parse(serviceUuid),
              characteristicId: Uuid.parse(txUuid),
              deviceId: _connectedDevice.id,
            );
            toastFun('Connected to ${device.name}', true);
          });
        } else if (connectionState.connectionState ==
            DeviceConnectionState.disconnected) {}
      });
    } catch (e) {
      print("Error while connecting: $e");
    }
  }

  /*
  Title: BLE Scan
  Description: This function scans the surrounding BLE devices
 */
  void startScan() {
    setState(() {
      isScanning = true;
      _foundDevices.clear(); // Clear previous devices
    });

    // Start scanning for BLE devices
    _scanStream =
        flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
          // Add devices to the discovered list if not already present
          setState(() {
            if (!_foundDevices.any((d) => d.id == device.id)) {
              if (savedDeviceID == device.id) {
                _scanStream.cancel(); /* Stops Scanning */
                _connectToDevice(device);
              }
            }
          });
        }, onError: (e) {
          _scanStream.cancel(); /* Stops Scanning */
          isScanning = false;
        });
  }

  @override
  void initState() {
    super.initState();
    batteryLevel = 0;
    batteryAnimation();
    initPackage();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the animation controller when not in use
    batteryLevel = 0;
    super.dispose();
  }
}