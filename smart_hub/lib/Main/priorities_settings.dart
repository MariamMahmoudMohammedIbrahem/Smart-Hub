import '../commons.dart';

class PrioritiesSettings extends StatefulWidget {
  static String id = 'Priorities_Screen';
  const PrioritiesSettings({super.key});

  @override
  State<PrioritiesSettings> createState() => _PrioritiesSettingsState();
}

class _PrioritiesSettingsState extends State<PrioritiesSettings> {

  late List<MapEntry<Key, Widget>> entries;

  @override
  void initState() {
    super.initState();
    entries = generateMap().entries.toList();
  }

  Map<Key, Widget> generateMap() {
    Map<Key, Widget> widgetMap = {};

    if (portA_ChannelOne_isConnected) {
      widgetMap[const ValueKey('PA1')] = ListTile(
        leading: const Icon(Icons.charging_station_rounded), // Add your preferred icon
        title: const Text(
          'Port A Channel 1',
          style: TextStyle(
            fontSize: 18,  // Customize font size
            fontWeight: FontWeight.bold, // Customize font weight
            fontFamily: 'Arial', // Customize font family
          ),
        ),
        subtitle: const Text(
          'LG H818',
          style: TextStyle(
            fontSize: 14,  // Customize font size
            fontStyle: FontStyle.italic, // Customize font style
            color: Colors.grey, // Customize text color
          ),
        ),
        tileColor: const Color(0x44000000),  // Background color with transparency
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners with a radius of 20
        ),
      );
    }
    if (portA_ChannelTwo_isConnected) {
      widgetMap[const ValueKey('PA2')] = ListTile(
        leading: const Icon(Icons.charging_station_rounded), // Add your preferred icon
        title: const Text(
          'Port A Channel 2',
          style: TextStyle(
            fontSize: 18,  // Customize font size
            fontWeight: FontWeight.bold, // Customize font weight
            fontFamily: 'Arial', // Customize font family
          ),
        ),
        subtitle: const Text(
          'HUAWEI HRY-LX1MEB',
          style: TextStyle(
            fontSize: 14,  // Customize font size
            fontStyle: FontStyle.italic, // Customize font style
            color: Colors.grey, // Customize text color
          ),
        ),
        tileColor: const Color(0x44000000),  // Background color with transparency
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners with a radius of 20
        ),
      );
    }
    if (portC_ChannelOne_isConnected) {
      widgetMap[const ValueKey('PC1')] = ListTile(
        leading: const Icon(Icons.charging_station_rounded), // Add your preferred icon
        title: const Text(
          'Port C Channel 1',
          style: TextStyle(
            fontSize: 18,  // Customize font size
            fontWeight: FontWeight.bold, // Customize font weight
            fontFamily: 'Arial', // Customize font family
          ),
        ),
        subtitle: const Text(
          'iphone XR',
          style: TextStyle(
            fontSize: 14,  // Customize font size
            fontStyle: FontStyle.italic, // Customize font style
            color: Colors.grey, // Customize text color
          ),
        ),
        tileColor: const Color(0x44000000),  // Background color with transparency
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners with a radius of 20
        ),
      );
    }
    if (portC_ChannelTwo_isConnected) {
      widgetMap[const ValueKey('PC2')] = ListTile(
        leading: const Icon(Icons.charging_station_rounded), // Add your preferred icon
        title: const Text(
          'Port C Channel 2',
          style: TextStyle(
            fontSize: 18,  // Customize font size
            fontWeight: FontWeight.bold, // Customize font weight
            fontFamily: 'Arial', // Customize font family
          ),
        ),
        subtitle: const Text(
          'iphone 11',
          style: TextStyle(
            fontSize: 14,  // Customize font size
            fontStyle: FontStyle.italic, // Customize font style
            color: Colors.grey, // Customize text color
          ),
        ),
        tileColor: const Color(0x44000000),  // Background color with transparency
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners with a radius of 20
        ),
      );
    }
    if (wirelessPower != 0) {
      widgetMap[const ValueKey('Wireless')] = const ListTile(title:Text('Wireless Charging'),subtitle: Text('iphone 14 plus'),);
      widgetMap[const ValueKey('Wireless')] = ListTile(
        leading: const Icon(Icons.charging_station_rounded), // Add your preferred icon
        title: const Text(
          'Wireless Charging',
          style: TextStyle(
            fontSize: 18,  // Customize font size
            fontWeight: FontWeight.bold, // Customize font weight
            fontFamily: 'Arial', // Customize font family
          ),
        ),
        subtitle: const Text(
          'iphone 14 plus',
          style: TextStyle(
            fontSize: 14,  // Customize font size
            fontStyle: FontStyle.italic, // Customize font style
            color: Colors.grey, // Customize text color
          ),
        ),
        tileColor: const Color(0x44000000),  // Background color with transparency
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners with a radius of 20
        ),
      );
    }

    return widgetMap;
  }

  @override
  Widget build(BuildContext context) {
    final screenDataProvider = Provider.of<ScreenDataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold,),),
        centerTitle: true,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),  // Bottom left corner rounded
            bottomRight: Radius.circular(30), // Bottom right corner rounded
          ),
          child: Container(
            color: screenDataProvider.isThemeDark ? Colors.black26 : Colors.indigo,
          ),
        ),
      ),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1; // Adjust for index shift caused by the reorder.
            }
            final entry = entries.removeAt(oldIndex);
            entries.insert(newIndex, entry);
            print(entries);
          });
        },
        children: entries.map((entry) {
          return ListTile(
            key: entry.key,
            title: entry.value,
          );
        }).toList(),
      ),
    );
  }
}
