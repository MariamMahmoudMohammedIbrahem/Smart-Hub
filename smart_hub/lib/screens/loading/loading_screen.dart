import '../../commons.dart';

part 'loading_controller.dart';

class LoadingScreen extends StatefulWidget {
  static String id = 'welcome_loading_screen';
  const LoadingScreen({super.key});

  @override
  createState() => _LoadingScreen();
}

class _LoadingScreen extends LoadingScreenController{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[900], // Background color
        body: Center(
          child: Column(
            children: [
              Expanded(
                flex: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    !isGlobalVariableTrue
                        ? Column(
                      children: [
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Always Be',
                                style: TextStyle(
                                    fontSize: 40.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              DefaultTextStyle(
                                style: const TextStyle(
                                  fontSize: 25.0,
                                  fontFamily: 'Horizon',
                                ),
                                child: AnimatedTextKit(
                                  /* Don't repeat the animation */
                                  repeatForever: false,
                                  totalRepeatCount: 1,
                                  isRepeatingAnimation: false,
                                  animatedTexts: [
                                    RotateAnimatedText(
                                      'CHARGED',
                                      duration: const Duration(
                                          milliseconds:
                                          800), // Duration per word
                                    ),
                                    RotateAnimatedText(
                                      'POWERED',
                                      duration: const Duration(
                                          milliseconds:
                                          800), // Duration per word
                                    ),
                                    RotateAnimatedText(
                                      'READY',
                                      duration: const Duration(
                                          milliseconds:
                                          800), // Duration per word
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: AnimatedTextKit(
                            animatedTexts: [
                              ColorizeAnimatedText(
                                'SMART HUB',
                                textStyle: colorizeTextStyle,
                                speed: const Duration(milliseconds: 1000),
                                colors: colorizeColors,
                              ),
                            ],
                            isRepeatingAnimation: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 3,
                      height: 200,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 120, // Increase height for a vertical battery
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Stack(
                            children: [
                              // Empty battery background
                              Positioned.fill(
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),

                              // Filling part (battery charging) - Now Vertical
                              Positioned.fill(
                                child: FractionallySizedBox(
                                  heightFactor:
                                  batteryLevel, // Change to heightFactor for vertical filling
                                  alignment: Alignment
                                      .bottomCenter, // Fill from bottom to top
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: getBatteryColor(
                                          batteryLevel), // Dynamic color based on battery level
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Battery percentage display
                        Text(
                          '${(batteryLevel * 100).toInt()}%',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Column(
                    children: [
                      Text(
                        'SmartHUB App powered by EOIP\n $version',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white60, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}