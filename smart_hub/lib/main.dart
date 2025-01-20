

import 'package:smart_hub/Main/priorities_settings.dart';

import 'commons.dart';

late final StreamSubscription<ConnectionStateUpdate> connectionNUM;
late final DiscoveredDevice connectedDevice;
late final QualifiedCharacteristic characteristic;

void main() {
  runApp(
    /*  Phoenix Package used to restart the app https://pub.dev/packages/flutter_phoenix */
    Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ScreenDataProvider()),
        ],
        child: const SmartHUB(),
      ),
    ),
  );
}

class SmartHUB extends StatelessWidget {
  const SmartHUB({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        /* This screen is responsible for loading all packages used before the app launch */
        initialRoute: welcome_loading_screen.id,
        routes: {
          welcome_loading_screen.id: (context) =>
              const welcome_loading_screen(),
          ble_ui_screen.id: (context) => const ble_ui_screen(),
          HomeScreen.id: (context) => HomeScreen(
                connectionNUM: connectionNUM,
                connectedDevice: connectedDevice,
                characteristic: characteristic,
              ),
          support_screen.id: (context) => const support_screen(),
          PrioritiesSettings.id: (context) => const PrioritiesSettings(),
        });
  }
}
