import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Constants/loading_screen_constants.dart';
import 'ble_ui.dart';

Widget UpdateLoadingScreen(BuildContext context) {
  Future.delayed(const Duration(milliseconds: 10000), () {
    // Pop the screen after 5 seconds
    if (g_ScreenReady == false) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 40,
            title: const Text(
              'Connection Timeout',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            content: const Text(
              'Your internet connection is bad.\nPlease try again later!',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            actions: [
              Center(
                child: SizedBox(
                  width: 120,
                  height: 40,
                  child: TextButton(
                    style: const ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                      ),
                      elevation: WidgetStatePropertyAll(10),
                      backgroundColor: WidgetStatePropertyAll(Colors.white12),
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop(), // Dismiss the dialog
                    child: const Text(
                      'Ok',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  });

  return Container(
    margin: const EdgeInsets.only(top: 50),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: LoadingAnimationWidget.bouncingBall(
            color: const Color(0xff0a0ea1),
            size: 120,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        const SizedBox(
          height: 10,
        ),
        AnimatedTextKit(
          animatedTexts: [
            ColorizeAnimatedText(
              'Getting Ready',
              textStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 40.0,
                fontFamily: 'Horizon',
              ),
              speed: const Duration(milliseconds: 1000),
              colors: Loading_Screen_colorizeColors,
            ),
          ],
          isRepeatingAnimation: true,
        ),
        SizedBox(
          height: 30,
        ),
        AnimatedTextKit(
          animatedTexts: [
            ColorizeAnimatedText(
              'Please wait..',
              textStyle: const TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 20.0,
                fontFamily: 'Horizon',
              ),
              speed: const Duration(milliseconds: 1000),
              colors: Loading_Screen_colorizeColors,
            ),
          ],
          isRepeatingAnimation: true,
        ),
      ],
    ),
  );
}
