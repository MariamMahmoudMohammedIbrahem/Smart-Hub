import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Components/alerts.dart';
import 'package:card_loading/card_loading.dart';
import 'package:provider/provider.dart';
import '../../Components/drawer_list.dart';
import '../../Components/provider.dart';

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
  bool isScanning = false;
  late StreamSubscription<ConnectionStateUpdate> _connecetion;
  /* Local storage  */
  late final SharedPreferences prefs;
  late String SavedDeviceID;
  bool testVar = false;
  bool screenTheme = false;
  /**------------------------------------------------------------------**/
  Future<void> initPackages() async {
    _connecetion = widget.connectionNUM;
    prefs = await SharedPreferences.getInstance();
    /* keeps listening to the connection */
    connectionChecker();
  }

  /*
  Title: Save in Local Storage
  Description: This function uses shared preference package to
  save the device id
   */
  Future<void> saveToLocalStorage(DiscoveredDevice device) async {
    receiveData();
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
    if (SavedDeviceID != 'null') {}
  }
  /*
  Title: Get from Local Storage
  Description: This function uses shared preference package to
  delete all variables inside the the key 'ConnectedDevice'
 */

  void connectionChecker() {
    // Assuming you have access to the StreamSubscription<ConnectionStateUpdate> variable for this device
    _connecetion = flutterReactiveBle
        .connectToDevice(
      id: widget.connectedDevice.id,
      connectionTimeout: const Duration(seconds: 5),
    )
        .listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        // Device is connected
        toastFun('Connection Restored');
        setState(() {
          isConnected = true;
        });
      } else if (connectionState.connectionState ==
          DeviceConnectionState.disconnected) {
        setState(() {
          isConnected = false;
        });
        // Device is disconnected
        toastFun('Connection Lost');
      }
    }, onError: (error) {
      toastFun('Connection Error');
      setState(() {
        isConnected = false;
      });
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
    initPackages();
  }

  @override
  void dispose() {
    super.dispose();
    widget.connectionNUM.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScreenDataProvider(), // Provide your data provider
      child: Scaffold(
        key: _scaffoldKey,
        drawer: drawerList(
          isConnected: isConnected,
          screenTheme: screenTheme,
        ),
        backgroundColor: screenTheme ? Colors.black : Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Consumer<ScreenDataProvider>(
              builder: (context, provider, child) {
                return provider.isDeviceConnected
                    ? Container(
                        width: 200,
                        height: 200,
                        color: Colors.blue,
                        child: Center(child: Text("First Container")),
                      )
                    : Container(
                        width: 200,
                        height: 200,
                        color: Colors.green,
                        child: Center(child: Text("Second Container")),
                      );
              },
            ),
            Container(
              margin: const EdgeInsets.only(left: 10, top: 20),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87,
              ),
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
            testVar
                ? Container(
                    width: 200.0, // Width of the circle
                    height: 200.0, // Height of the circle
                    decoration: BoxDecoration(
                      color: Colors.white12, // Background color of the circle
                      shape: BoxShape.circle, // Making the container circular
                    ),
                    child: Center(
                      child: Text(
                        "Circle",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : CardLoading(
                    height: 200,
                    width: 200,
                    borderRadius: BorderRadius.all(Radius.circular(10000)),
                    margin: EdgeInsets.only(bottom: 10),
                    cardLoadingTheme: CardLoadingTheme(
                        colorOne: Colors.white12, colorTwo: Colors.black12),
                  ),
            Text('Connected to: ${widget.connectedDevice.name}'),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  setState(() {
                    Provider.of<ScreenDataProvider>(context, listen: false)
                        .updateTheme();
                  });
                });

                sendData('Hello\n');
              },
              child: Text('Send Data'),
            ),
            ElevatedButton(
              onPressed: () {
                // Example: Listening to data from the connected device
                setState(() {
                  Provider.of<ScreenDataProvider>(context, listen: false)
                      .updateConnection();
                });

                receiveData().listen((data) {
                  print('Received data: ${String.fromCharCodes(data)}');
                });
              },
              child: Text('Receive Data'),
            ),
            ElevatedButton(
              onPressed: () {
                _connecetion.cancel();
                setState(() {
                  isConnected = false;
                });
              },
              child: Text('unpair'),
            ),
            ElevatedButton(
              onPressed: () {
                connectionChecker();
              },
              child: Text('Reconnect'),
            ),
          ],
        ),
      ),
    );
  }
}
