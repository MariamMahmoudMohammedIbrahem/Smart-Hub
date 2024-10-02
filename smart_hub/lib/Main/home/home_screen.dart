import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_hub/Main/BLE/ble_ui.dart';
import '../../Components/alerts.dart';
import 'package:provider/provider.dart';
import 'components/battery_level.dart';
import '../../Components/drawer_list.dart';
import 'components/home_battery.dart';
import 'components/home_wireless.dart';
import 'components/loadingCards.dart';
import '../../Components/provider.dart';
import 'components/status_circle_card.dart';
import 'constants/home_constants.dart';

class HomeScreen extends StatefulWidget implements PreferredSizeWidget {
  static String id = 'home_screen';
  final StreamSubscription<ConnectionStateUpdate> connectionNUM;
  final DiscoveredDevice connectedDevice;
  final QualifiedCharacteristic characteristic;

  const HomeScreen({
    super.key,
    required this.connectionNUM, // Marking as required
    required this.connectedDevice, // Marking as required
    required this.characteristic,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// ---------------------Local Variables Section----------------------*
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isConnected = true;
  final flutterReactiveBle = FlutterReactiveBle();
  bool isScanning = false;
  late DiscoveredDevice _connectedDevice;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  late StreamSubscription<DiscoveredDevice> _scanStream;
  List<DiscoveredDevice> _foundDevices = [];

/* Handling AppBar vars */
  String greetingMessage = "";
  bool showGreeting = true; // To control which text is shown
  late Timer _timer;

  /* Local storage  */
  late final SharedPreferences prefs;
  late String savedDeviceID;
  bool screenReady = false;

  /* Variable to handle the reconnection */
  int reconnectTrial = 0;

  /* Pair loading animation */
  bool isPairLoading = false;

  /* Frame Variables */
  /* Battery part */
  double batteryLevel = 0.2;
  double batteryTemp = 30;
  double batteryPower = 60;

  /* Wireless Part */
  double wirelessPower = 23;

  /// ------------------------------------------------------------------*
  Future<void> initPackages() async {
    _connection = widget.connectionNUM;
    _connectedDevice = widget.connectedDevice;
    prefs = await SharedPreferences.getInstance();
    /* keeps listening to the connection */
    //receiveData();
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
      print(reconnectTrial);

      if (reconnectTrial >= 2) {
        toastFun('${_connectedDevice.name} not found\nRedirecting!',
            getThemeFromLocalStorage());
        Navigator.pushReplacementNamed(context, ble_ui_screen.id);
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
    print('connectionChcker function');
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
  Stream<List<int>> receiveData() {
    return FlutterReactiveBle()
        .subscribeToCharacteristic(widget.characteristic);
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

  @override
  Widget build(BuildContext context) {
    final screenDataProvider = Provider.of<ScreenDataProvider>(context);
    Color thermoColor;
    Color powerColor;
    if (batteryTemp > 70) {
      thermoColor = Colors.red;
    } else if (batteryTemp <= 70 && batteryTemp > 50) {
      thermoColor = Colors.yellow;
    } else if (batteryTemp <= 50 && batteryTemp >= 0) {
      thermoColor = Colors.green;
    } else {
      thermoColor = Colors.red;
    }
    if (batteryPower > 180) {
      powerColor = Colors.red;
    } else {
      powerColor = Color(0xffab9424);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            screenDataProvider.isThemeDark ? Colors.black26 : Colors.indigo,
        automaticallyImplyLeading: true,
        centerTitle: false, // Set to false to allow left alignment
        title: AnimatedSwitcher(
          duration: const Duration(seconds: 2), // Smooth transition duration
          child: showGreeting
              ? Center(
                  child: Text(
                    greetingMessage,
                    key: const ValueKey("greetingMessage"),
                    // Unique key for the greeting
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: screenDataProvider.isThemeDark
                          ? Colors.white
                          : Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      // Allow the title to take available space on the left
                      child: Text(
                        "HOME",
                        key: const ValueKey("smartHubTitle"),
                        textAlign: TextAlign.start,
                        // Unique key for the SmartHUB text
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: screenDataProvider.isThemeDark
                              ? Colors.white
                              : Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    // Button on the right
                    SizedBox(
                      height: 35,
                      child: isConnected
                          ? ElevatedButton(
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Color(0xffd91616),
                                ),
                                enableFeedback: true,
                                shape: WidgetStatePropertyAll(
                                  ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                unPairConnection();
                                deleteLocalStorage();
                                Navigator.pushReplacementNamed(
                                    context, ble_ui_screen.id);
                                setState(() {});
                              },
                              child: const Text(
                                'Unpair',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                style: const ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    Color(0xffb0610c),
                                  ),
                                  enableFeedback: true,
                                  shape: WidgetStatePropertyAll(
                                    ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(100),
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (isPairLoading == false) {
                                    startDeviceScan();
                                  }

                                  setState(() {});
                                },
                                child: !isPairLoading
                                    ? const Text(
                                        'Reconnect',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : LoadingAnimationWidget.dotsTriangle(
                                        color: Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                    ),
                  ],
                ),
        ),
      ),
      key: _scaffoldKey,
      drawer: drawerList(
        isConnected: isConnected,
        connectedDevice: _connectedDevice,
      ),
      backgroundColor:
          screenDataProvider.isThemeDark ? Colors.grey[900] : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !screenReady
                ? batteryContainer(
                    screenDataProvider: screenDataProvider,
                    isConnected: isConnected,
                    connectedDevice: _connectedDevice,
                    thermoColor: thermoColor,
                    batteryTemp: batteryTemp,
                    batteryLevel: batteryLevel,
                    powerColor: powerColor,
                    batteryPower: batteryPower)
                : LoadingCards(
                    cardBoarderRadius: containerRadius,
                    cardHeight: 140,
                    cardWidth: double.infinity,
                    colorOne: screenDataProvider.isThemeDark
                        ? Color(0x15656566)
                        : Color(0x221727a3),
                    colorTwo: screenDataProvider.isThemeDark
                        ? Colors.white12
                        : Color(0xaa1727a3),
                  ),
            const SizedBox(
              height: 20,
            ),
            !screenReady
                ? home_wireless(
                    isDark: screenDataProvider.isThemeDark,
                    wirelessPower: wirelessPower,
                  )
                : LoadingCards(
                    cardBoarderRadius: containerRadius,
                    cardHeight: 120,
                    cardWidth: double.infinity,
                    colorOne: screenDataProvider.isThemeDark
                        ? Color(0x15656566)
                        : Color(0x441727a3),
                    colorTwo: screenDataProvider.isThemeDark
                        ? Colors.white12
                        : Color(0x551727a3),
                  ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 50,
                left: 50,
              ),
              child: Container(
                width: double.infinity,
                height: 5,
                decoration: BoxDecoration(
                  color: screenDataProvider.isThemeDark
                      ? Colors.white12
                      : Colors.black12,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(80),
                    bottomLeft: Radius.circular(80),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            screenReady
                ? Container(
                    width: double.infinity, // Width of the circle
                    height: 120, // Height of the circle
                    decoration: BoxDecoration(
                      color: screenDataProvider.isThemeDark
                          ? Colors.white12
                          : Colors.black12, // Background color of the circle
                      borderRadius: BorderRadius.all(
                        Radius.circular(containerRadius),
                      ), // Making the container circular
                    ),
                    child: const Center(
                      child: Text(
                        "Circle",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : LoadingCards(
                    cardBoarderRadius: containerRadius,
                    cardHeight: 120,
                    cardWidth: double.infinity,
                    colorOne: Color(0x22656566),
                    colorTwo: screenDataProvider.isThemeDark
                        ? Colors.white12
                        : Colors.black12,
                  ),
            const SizedBox(
              height: 10,
            ),
            screenReady
                ? Container(
                    width: double.infinity, // Width of the circle
                    height: 120, // Height of the circle
                    decoration: BoxDecoration(
                      color: screenDataProvider.isThemeDark
                          ? Colors.white12
                          : Colors.black12, // Background color of the circle
                      borderRadius: BorderRadius.all(
                        Radius.circular(containerRadius),
                      ), // Making the container circular
                    ),
                    child: const Center(
                      child: Text(
                        "Circle",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : LoadingCards(
                    cardBoarderRadius: containerRadius,
                    cardHeight: 120,
                    cardWidth: double.infinity,
                    colorOne: Color(0x22656566),
                    colorTwo: screenDataProvider.isThemeDark
                        ? Colors.white12
                        : Colors.black12,
                  ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: screenReady
                      ? Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: screenDataProvider.isThemeDark
                                ? Colors.white12
                                : Colors.black12,
                            borderRadius: BorderRadius.all(
                              Radius.circular(containerRadius),
                            ),
                          ),
                        )
                      : LoadingCards(
                          cardBoarderRadius: containerRadius,
                          cardHeight: 120,
                          cardWidth: double.infinity,
                          colorOne: Color(0x22656566),
                          colorTwo: screenDataProvider.isThemeDark
                              ? Colors.white12
                              : Colors.black12,
                        ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: screenReady
                      ? Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: screenDataProvider.isThemeDark
                                ? Colors.white12
                                : Colors.black12,
                            borderRadius: BorderRadius.all(
                              Radius.circular(containerRadius),
                            ),
                          ),
                        )
                      : LoadingCards(
                          cardBoarderRadius: containerRadius,
                          cardHeight: 120,
                          cardWidth: double.infinity,
                          colorOne: Color(0x22656566),
                          colorTwo: screenDataProvider.isThemeDark
                              ? Colors.white12
                              : Colors.black12,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
