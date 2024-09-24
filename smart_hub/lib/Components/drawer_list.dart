import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slider_button/slider_button.dart';
import 'package:smart_hub/Components/provider.dart';

import '../Constants/AnimatedColors.dart';
import '../Constants/version.dart';

class drawerList extends StatefulWidget {
  const drawerList({
    super.key,
  });

  @override
  _drawerListState createState() => _drawerListState();
}

class _drawerListState extends State<drawerList> {
  bool isExpanded = false; // Controls the expand/collapse

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
        backgroundColor: Colors.black87,
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
                          style: TextStyle(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                screenDataProvider.isDeviceConnected
                    ? 'Connected'
                    : 'Not Connected',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.keyboard_arrow_up),
            ),
            // Collapsible/Expandable Section for Team Info
            ListTile(
              title: Row(
                children: [
                  const Text(
                    'Theme Settings',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(Icons.color_lens_outlined)
                ],
              ),
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded; // Toggle expand/collapse
                });
              },
              trailing: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isExpanded ? 60 : 0, // Adjust height based on state
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isExpanded
                  ? Container(
                      height: 60,
                      child: SliderButton(
                        action: () async {
                          Navigator.pop(context);
                          // Call updateTheme when slider button is slid
                          if (screenDataProvider.isThemeDark)
                            screenDataProvider.updateTheme(false);
                          else
                            screenDataProvider.updateTheme(true);
                          // Return true after completing the action
                          return Future.value(true);
                        },
                        label: Text(
                          screenDataProvider.isThemeDark
                              ? 'Slide to switch\nto Light Theme'
                              : 'Slide to switch\nto Dark Theme',
                          style: TextStyle(
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
                              : Colors.black,
                        ),
                        vibrationFlag: true,
                        backgroundColor: Colors.white24,
                        highlightedColor: Colors.indigo,
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
