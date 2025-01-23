

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
        initialRoute: LoadingScreen.id,
        routes: {
          LoadingScreen.id: (context) =>
              const LoadingScreen(),
          BleScreen.id: (context) => const BleScreen(),
          HomeScreen.id: (context) => HomeScreen(
                connectionNUM: connectionNUM,
                connectedDevice: connectedDevice,
                characteristic: characteristic,
              ),
          SupportScreen.id: (context) => const SupportScreen(),
          PrioritiesScreen.id: (context) => const PrioritiesScreen(),
          SettingsScreen.id: (context) => const SettingsScreen(),
        });
  }
}
