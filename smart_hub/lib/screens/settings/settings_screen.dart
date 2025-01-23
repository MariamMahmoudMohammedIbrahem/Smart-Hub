import '../../commons.dart';

part 'settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  static String id = 'settings_screen';
  const SettingsScreen({super.key});

  @override
  createState() => _SettingsScreen();
}

class _SettingsScreen extends SettingsController {
  @override
  Widget build(BuildContext context) {
    final screenDataProvider = Provider.of<ScreenDataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15), // Bottom left corner rounded
            bottomRight: Radius.circular(15), // Bottom right corner rounded
          ),
          child: Container(
            color:
                screenDataProvider.isThemeDark ? Colors.black26 : Colors.indigo,
          ),
        ),
      ),
      backgroundColor:
          screenDataProvider.isThemeDark ? Colors.grey[900] : Colors.white,
      body: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.color_lens_outlined,
              color: screenDataProvider.isThemeDark
                  ? Colors.white
                  : Colors.black87,
            ),
            title: Text(
              'Theme Settings',
              style: TextStyle(
                fontSize: 20,
                color: screenDataProvider.isThemeDark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w700,
              ),
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
              color:
                  screenDataProvider.isThemeDark ? Colors.white : Colors.black,
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
                          _myPreferences.saveToLocalStorage(false);
                        } else {
                          screenDataProvider.updateTheme(true);
                          _myPreferences.saveToLocalStorage(true);
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
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, 'priorities_screen');
            },
            leading: Icon(
              Icons.bolt_rounded,
              color:
                  screenDataProvider.isThemeDark ? Colors.white : Colors.black,
            ),
            title: Text(
              'Power Priorities',
              style: TextStyle(
                fontSize: 20,
                color: screenDataProvider.isThemeDark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              ///TODO: send command
            },
            leading: Icon(
              Icons.power_settings_new_rounded,
              color:
                  screenDataProvider.isThemeDark ? Colors.white : Colors.black,
            ),
            title: Text('Auto shut down',
              style: TextStyle(
                fontSize: 20,
                color: screenDataProvider.isThemeDark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w700,
              ),),
          ),
          ListTile(
            onTap: () {},
            leading: Icon(
              Icons.language_rounded,
              color:
                  screenDataProvider.isThemeDark ? Colors.white : Colors.black,
            ),
            title: Text('Language',
              style: TextStyle(
                fontSize: 20,
                color: screenDataProvider.isThemeDark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w700,
              ),),
          ),
          ListTile(
            onTap: () {
              ///TODO: send command
            },
            leading: Icon(
              Icons.settings_backup_restore_rounded,
              color:
                  screenDataProvider.isThemeDark ? Colors.white : Colors.black,
            ),
            title: Text('Factory Reset',
              style: TextStyle(
                fontSize: 20,
                color: screenDataProvider.isThemeDark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w700,
              ),),
          ),
          ListTile(
            onTap: () {},
            leading: Icon(
              Icons.description_outlined,
              color:
                  screenDataProvider.isThemeDark ? Colors.white : Colors.black,
            ),
            title: Text('About',
              style: TextStyle(
                fontSize: 20,
                color: screenDataProvider.isThemeDark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w700,
              ),),
          ),
        ],
      ),
    );
  }
}
