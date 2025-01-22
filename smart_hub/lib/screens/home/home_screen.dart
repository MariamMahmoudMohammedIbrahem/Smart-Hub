import 'package:smart_hub/screens/settings/settings_screen.dart';

import '../../commons.dart';

part 'home_controller.dart';

class HomeScreen extends StatefulWidget implements PreferredSizeWidget{
  static String id = 'home_screen';

  final StreamSubscription<ConnectionStateUpdate> connectionNUM;
  final DiscoveredDevice connectedDevice;
  final QualifiedCharacteristic characteristic;

  const HomeScreen({
    super.key,
    required this.connectionNUM,
    required this.connectedDevice,
    required this.characteristic,
  });

  @override
  createState() => _HomeScreen();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}

class _HomeScreen extends HomeController {
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
      powerColor = const Color(0xffab9424);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                        context, BleScreen.id);
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
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),  // Bottom left corner rounded
            bottomRight: Radius.circular(15), // Bottom right corner rounded
          ),
          child: Container(
            color: screenDataProvider.isThemeDark ? Colors.black26 : Colors.indigo,
          ),
        ),
      ),
      key: _scaffoldKey,
      // drawer: DrawerList(
      //   isConnected: isConnected,
      //   connectedDevice: _connectedDevice,
      // ),
      drawer: const SettingsScreen(),
      backgroundColor:
      screenDataProvider.isThemeDark ? Colors.grey[900] : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ///temp+battery+power
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
                  ? const Color(0x15656566)
                  : const Color(0x221727a3),
              colorTwo: screenDataProvider.isThemeDark
                  ? const Color(0x0AFFFFFF)
                  : const Color(0xaa1727a3),
            ),
            const SizedBox(
              height: 20,
            ),
            ///wireless
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
                  ? const Color(0x15656566)
                  : const Color(0x441727a3),
              colorTwo: screenDataProvider.isThemeDark
                  ? const Color(0x0AFFFFFF)
                  : const Color(0x551727a3),
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
            ///port c
            !screenReady
                ? Container(
              width: double.infinity, // Width of the circle
              height: 120, // Height of the circle
              decoration: BoxDecoration(
                color: screenDataProvider.isThemeDark
                    ? const Color(0x0AFFFFFF)
                    : const Color(
                    0x11000000), // Background color of the circle
                borderRadius: BorderRadius.all(
                  Radius.circular(containerRadius),
                ), // Making the container circular
              ),
              child: portsContainer(
                  main_Container_Name: portCName,
                  screenDataProvider: screenDataProvider,
                  Container_One_Name: port1Name,
                  port_ChannelOne_isConnected:
                  portA_ChannelOne_isConnected,
                  port_ChannelOne_Power: portC1Power,
                  Container_Two_Name: port2Name,
                  port_ChannelTwo_isConnected:
                  portC_ChannelTwo_isConnected,
                  port_ChannelTwo_Power: portC2Power),
            )
                : LoadingCards(
              cardBoarderRadius: containerRadius,
              cardHeight: 120,
              cardWidth: double.infinity,
              colorOne: const Color(0x22656566),
              colorTwo: screenDataProvider.isThemeDark
                  ? const Color(0x0AFFFFFF)
                  : Colors.black12,
            ),
            const SizedBox(
              height: 10,
            ),
            ///port a
            !screenReady
                ? Container(
              width: double.infinity, // Width of the circle
              height: 120, // Height of the circle
              decoration: BoxDecoration(
                color: screenDataProvider.isThemeDark
                    ? const Color(0x0AFFFFFF)
                    : const Color(
                    0x11000000), // Background color of the circle
                borderRadius: BorderRadius.all(
                  Radius.circular(containerRadius),
                ), // Making the container circular
              ),
              child: portsContainer(
                  main_Container_Name: portAName,
                  screenDataProvider: screenDataProvider,
                  Container_One_Name: port1Name,
                  port_ChannelOne_isConnected:
                  portA_ChannelOne_isConnected,
                  port_ChannelOne_Power: portA1Power,
                  Container_Two_Name: port2Name,
                  port_ChannelTwo_isConnected:
                  portA_ChannelTwo_isConnected,
                  port_ChannelTwo_Power: portA2Power),
            )
                : LoadingCards(
              cardBoarderRadius: containerRadius,
              cardHeight: 120,
              cardWidth: double.infinity,
              colorOne: const Color(0x22656566),
              colorTwo: screenDataProvider.isThemeDark
                  ? const Color(0x0AFFFFFF)
                  : Colors.black12,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                ///sdcard
                Expanded(
                  child: !screenReady
                      ? Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: screenDataProvider.isThemeDark
                          ? const Color(0x0AFFFFFF)
                          : const Color(0x11000000),
                      borderRadius: BorderRadius.all(
                        Radius.circular(containerRadius),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'SDCard',
                                          style: TextStyle(
                                            color: Color(0xddffffff),
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.sd_card,
                                          color: Color(0x66ffffff),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 15,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        const BorderRadius.all(
                                          Radius.circular(
                                            40,
                                          ),
                                        ),
                                        color: sdCardIsConnected
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          sdCardIsConnected
                              ? const Row(
                            children: [],
                          )
                              : const Text(
                            'No Information',
                            style: TextStyle(
                              color: Color(0x88FFFFFF),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                      : LoadingCards(
                    cardBoarderRadius: containerRadius,
                    cardHeight: 120,
                    cardWidth: double.infinity,
                    colorOne: const Color(0x22656566),
                    colorTwo: screenDataProvider.isThemeDark
                        ? const Color(0x0AFFFFFF)
                        : Colors.black12,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                ///hdmi
                Expanded(
                  child: !screenReady
                      ? Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: screenDataProvider.isThemeDark
                          ? const Color(0x0AFFFFFF)
                          : const Color(0x11000000),
                      borderRadius: BorderRadius.all(
                        Radius.circular(containerRadius),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'HDMI',
                                          style: TextStyle(
                                            color: Color(0xddffffff),
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.settings_input_hdmi,
                                          color: Color(0x66ffffff),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 15,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        const BorderRadius.all(
                                          Radius.circular(
                                            40,
                                          ),
                                        ),
                                        color: hdmiIsConnected
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          hdmiIsConnected
                              ? const Row(
                            children: [],
                          )
                              : const Text(
                            'No Information',
                            style: TextStyle(
                              color: Color(0x88FFFFFF),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                      : LoadingCards(
                    cardBoarderRadius: containerRadius,
                    cardHeight: 120,
                    cardWidth: double.infinity,
                    colorOne: const Color(0x22656566),
                    colorTwo: screenDataProvider.isThemeDark
                        ? const Color(0x0AFFFFFF)
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