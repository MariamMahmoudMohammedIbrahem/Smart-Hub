import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import '../Constants/AnimatedColors.dart';
import '../Constants/version.dart';
import 'alerts.dart';

class drawerList extends StatefulWidget {
  final bool isConnected;
  const drawerList({
    super.key,
    required this.isConnected,
  });

  @override
  _drawerListState createState() => _drawerListState();
}

class _drawerListState extends State<drawerList> {
  bool isExpanded = false; // Controls the expand/collapse

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(150), bottomRight: Radius.circular(30)),
      ),
      backgroundColor: Colors.black87,
      child: SafeArea(
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
                  ))
                ],
              ),
            ),
            // Collapsible/Expandable Section for Team Info
            ListTile(
              title: const Text(
                'Team Info',
                style: TextStyle(
                  fontSize: 20,
                ),
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
              height: isExpanded ? 120 : 0, // Adjust height based on state
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '• Team Member 1: Developer',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Team Member 2: Designer',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Team Member 3: Product Manager',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
