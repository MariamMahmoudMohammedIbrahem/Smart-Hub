import '../../commons.dart';

part 'ble_controller.dart';

class BleScreen extends StatefulWidget {
  static String id = 'BLE_screen';
  const BleScreen({super.key});

  @override
  createState() => _BleScreen();
}

class _BleScreen extends BleController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Background color
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Header
            const Text(
              'Identifying Charger',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Find the closest SmartHUB charger \nvia bluetooth',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 40),
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
            const SizedBox(height: 40),
            // Stop Button
            if (isScanning)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Found your device ? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(
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
            const SizedBox(
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black38,
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
                              const SizedBox(width: 15),
                              // Device Name and Service Name
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 140,
                                    child: Text(
                                      device.name.isNotEmpty
                                          ? device.name
                                          : "Unknown device",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ("ID: ${device.id}\nRSSI: ${device.rssi} dBm"),
                                    style: const TextStyle(
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
                                if (isPairing == false) {
                                  setState(() {
                                    isPairing = true;
                                  });
                                  _connectToDevice(device);
                                }
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
            Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
                right: 40,
                left: 40,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white30,
                    child: const Text(''),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Need help ?',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, SupportScreen.id);
                        },
                        child: const Text(
                          'Support',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}