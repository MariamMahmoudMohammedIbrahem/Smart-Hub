import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_hub/Main/BLE/ble_ui.dart';
import '../../Components/alerts.dart';
import 'package:card_loading/card_loading.dart';
import 'package:provider/provider.dart';
import '../../Components/drawer_list.dart';
import '../../Components/loadingCards.dart';
import '../../Components/provider.dart';
import '../../Constants/home_constants.dart';

class home_screen extends StatefulWidget implements PreferredSizeWidget {
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  /**---------------------Local Variables Section----------------------**/
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isConnected = true;
  final flutterReactiveBle = FlutterReactiveBle();
  bool isScanning = false;
  late StreamSubscription<ConnectionStateUpdate> _connecetion;

/* Handling AppBar vars */
  String greetingMessage = "";
  bool showGreeting = true; // To control which text is shown
  late Timer _timer;

  /* Local storage  */
  late final SharedPreferences prefs;
  late String SavedDeviceID;
  bool screenReady = false;

  /* Variable to handle the reconnection */
  int reconnectTrial = 0;

  /* Pair loading animation */
  bool isPairLoading = false;

  /**------------------------------------------------------------------**/
  Future<void> initPackages() async {
    _connecetion = widget.connectionNUM;
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
    SavedDeviceID =
        prefs.getString('ConnectedDevice') ?? 'null'; // save the device id
    if (SavedDeviceID != 'null') {}
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
    setState(() {
      isPairLoading = true;
    });
    // Assuming you have access to the StreamSubscription<ConnectionStateUpdate> variable for this device
    _connecetion = flutterReactiveBle
        .connectToDevice(
      id: widget.connectedDevice.id,
      connectionTimeout: const Duration(seconds: 5),
    )
        .listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        // Device is connected
        toastFun('Connection Restored', getThemeFromLocalStorage());
        setState(() {
          isConnected = true;
          isPairLoading = false;
          reconnectTrial = 0; // Reset the number of the reconnect trials
        });
      } else if (connectionState.connectionState ==
          DeviceConnectionState.disconnected) {
        setState(() {
          isConnected = false;
          isPairLoading = false;
          reconnectTrial++;
        });
        // Device is disconnected
        if (reconnectTrial <= 2) {
          toastFun('Connection Lost', getThemeFromLocalStorage());
        } else {
          toastFun('Device not found', getThemeFromLocalStorage());
        }
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
    _connecetion.cancel();
    toastFun('unPaired', getThemeFromLocalStorage());
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
  }

  @override
  Widget build(BuildContext context) {
    final screenDataProvider = Provider.of<ScreenDataProvider>(context);
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
                        "Smart HUB",
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
                    Container(
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
                          : Container(
                              width: 120,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    reconnectTrial >= 3
                                        ? Color(0xffd91616)
                                        : Color(0xffb0610c),
                                  ),
                                  enableFeedback: true,
                                  shape: const WidgetStatePropertyAll(
                                    ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(100),
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (isPairLoading == false) {
                                    connectionChecker();
                                    if (reconnectTrial >= 3) {
                                      Navigator.pushReplacementNamed(
                                          context, ble_ui_screen.id);
                                    }
                                  }

                                  setState(() {});
                                },
                                child: !isPairLoading
                                    ? Text(
                                        reconnectTrial >= 3
                                            ? 'Exit'
                                            : 'Reconnect',
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
        connectedDevice: widget.connectedDevice,
      ),
      backgroundColor:
          screenDataProvider.isThemeDark ? Colors.grey[900] : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: screenDataProvider.isThemeDark
                    ? Colors.white12
                    : Colors.black12,
                borderRadius: BorderRadius.all(
                  Radius.circular(containerRadius),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.battery_charging_full,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Device Name:',
                                style: TextStyle(
                                  color: screenDataProvider.isThemeDark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                widget.connectedDevice.name != ''
                                    ? '${widget.connectedDevice.name}'
                                    : 'Unknown',
                                style: TextStyle(
                                  color: screenDataProvider.isThemeDark
                                      ? Colors.white70
                                      : Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'MAC Address:',
                                style: TextStyle(
                                  color: screenDataProvider.isThemeDark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                '${widget.connectedDevice.id}',
                                style: TextStyle(
                                  color: screenDataProvider.isThemeDark
                                      ? Colors.white70
                                      : Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'RSSI:',
                                style: TextStyle(
                                  color: screenDataProvider.isThemeDark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                '${widget.connectedDevice.rssi} dBm',
                                style: TextStyle(
                                  color: screenDataProvider.isThemeDark
                                      ? Colors.white70
                                      : Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Status:',
                                style: TextStyle(
                                  color: screenDataProvider.isThemeDark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                isConnected ? 'Connected' : 'Disconnected',
                                style: TextStyle(
                                  color: isConnected
                                      ? Colors.green
                                      : Color(0xffd91616),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
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
                                : Container(
                                    width: 120,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                          reconnectTrial >= 3
                                              ? Color(0xffd91616)
                                              : Color(0xffb0610c),
                                        ),
                                        enableFeedback: true,
                                        shape: const WidgetStatePropertyAll(
                                          ContinuousRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(100),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (isPairLoading == false) {
                                          connectionChecker();
                                          if (reconnectTrial >= 3) {
                                            Navigator.pushReplacementNamed(
                                                context, ble_ui_screen.id);
                                          }
                                        }

                                        setState(() {});
                                      },
                                      child: !isPairLoading
                                          ? Text(
                                              reconnectTrial >= 3
                                                  ? 'Exit'
                                                  : 'Reconnect',
                                              style: const TextStyle(
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
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                      right: 10,
                    ),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: screenReady
                      ? Container(
                          width: double.infinity,
                          height: 300,
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
                          cardHeight: 300,
                          cardWidth: double.infinity,
                        ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: screenReady
                      ? Container(
                          width: double.infinity,
                          height: 300,
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
                          cardHeight: 300,
                          cardWidth: double.infinity,
                        ),
                ),
              ],
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
                  borderRadius: BorderRadius.only(
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
                    child: Center(
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
                    child: Center(
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
                        ),
                ),
                SizedBox(
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
