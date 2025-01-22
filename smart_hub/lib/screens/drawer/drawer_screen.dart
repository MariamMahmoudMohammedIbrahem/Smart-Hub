import '../../commons.dart';

part 'drawer_controller.dart';

class DrawerList extends StatefulWidget {
  final bool isConnected;
  final DiscoveredDevice connectedDevice;

  const DrawerList(
      {super.key, required this.isConnected, required this.connectedDevice});

  @override
  createState() => _DrawerList();
}

class _DrawerList extends DrawerListController {
  @override
  Widget build(BuildContext context) {
    final screenDataProvider = Provider.of<ScreenDataProvider>(context);

    return SafeArea(
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(150),
          ),
        ),
        backgroundColor:
            screenDataProvider.isThemeDark ? Colors.black87 : Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.indigo,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        ColorizeAnimatedText(
                          'SmartHUB \nAlways be ready',
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          speed: const Duration(milliseconds: 800),
                          colors: colorizeColors,
                        ),
                      ],
                      isRepeatingAnimation: true,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'SmartHUB $version',
                          style: const TextStyle(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Align content to the left
                children: [
                  ListTile(
                    title: Text(
                      widget.isConnected ? 'Connected' : 'Not Connected',
                      style: TextStyle(
                        fontSize: 20,
                        color: widget.isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        isConnectionExpanded =
                            !isConnectionExpanded; // Toggle expansion
                      });
                    },
                    trailing: Icon(
                      isConnectionExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: screenDataProvider.isThemeDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  // Expandable section
                  if (isConnectionExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: screenDataProvider.isThemeDark
                              ? Colors.white12
                              : Colors.black26,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: widget.isConnected
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Device Name:',
                                          style: TextStyle(
                                            color:
                                                screenDataProvider.isThemeDark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          widget.connectedDevice.name != ''
                                              ? widget.connectedDevice.name
                                              : 'Unknown',
                                          style: TextStyle(
                                            color:
                                                screenDataProvider.isThemeDark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'MAC Address:',
                                          style: TextStyle(
                                            color:
                                                screenDataProvider.isThemeDark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          widget.connectedDevice.id,
                                          style: TextStyle(
                                            color:
                                                screenDataProvider.isThemeDark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'RSSI:',
                                          style: TextStyle(
                                            color:
                                                screenDataProvider.isThemeDark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${widget.connectedDevice.rssi} dBm',
                                          style: TextStyle(
                                            color:
                                                screenDataProvider.isThemeDark
                                                    ? Colors.white70
                                                    : Colors.black87,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'No Information',
                                      style: TextStyle(
                                        color: screenDataProvider.isThemeDark
                                            ? Colors.white70
                                            : Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Collapsible/Expandable Section for Team Info
            ListTile(
              title: Row(
                children: [
                  Text(
                    'Theme Settings',
                    style: TextStyle(
                      fontSize: 20,
                      color: screenDataProvider.isThemeDark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.color_lens_outlined,
                    color: screenDataProvider.isThemeDark
                        ? Colors.white
                        : Colors.black87,
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  isThemeExpanded = !isThemeExpanded; // Toggle expand/collapse
                });
              },
              trailing: Icon(
                isThemeExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: screenDataProvider.isThemeDark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isThemeExpanded ? 60 : 0,
              // Adjust height based on state
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isThemeExpanded
                  ? SizedBox(
                      height: 60,
                      child: SliderButton(
                        baseColor: screenDataProvider.isThemeDark
                            ? Colors.white30
                            : Colors.black87,
                        buttonColor: screenDataProvider.isThemeDark
                            ? Colors.white
                            : Colors.black,
                        action: () async {
                          Navigator.pop(context);
                          // Call updateTheme when slider button is slid
                          if (screenDataProvider.isThemeDark) {
                            screenDataProvider.updateTheme(false);
                            saveToLocalStorage(false);
                          } else {
                            screenDataProvider.updateTheme(true);
                            saveToLocalStorage(true);
                          }

                          // Return true after completing the action
                          return Future.value(true);
                        },
                        label: Text(
                          screenDataProvider.isThemeDark
                              ? 'Slide to switch\nto Light Theme'
                              : 'Slide to switch\nto Dark Theme',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        icon: Icon(
                          screenDataProvider.isThemeDark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: screenDataProvider.isThemeDark
                              ? Colors.orange
                              : Colors.white,
                        ),
                        vibrationFlag: true,
                        backgroundColor: screenDataProvider.isThemeDark
                            ? Colors.white24
                            : Colors.black38,
                        highlightedColor: Colors.indigo,
                      ),
                    )
                  : Container(),
            ),

            // Settings for priorities
            AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 20,
                            color: screenDataProvider.isThemeDark
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.settings_rounded,
                          color: screenDataProvider.isThemeDark
                              ? Colors.white
                              : Colors.black87,
                        )
                      ],
                    ),
                    onTap: () {
                      /*setState(() {
                        isSettingsExpanded =
                            !isSettingsExpanded; // Toggle expand/collapse
                      });*/
                      Navigator.pop(context);
                      Navigator.pushNamed(context, 'settings_screen');
                    },
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
