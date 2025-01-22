

import '../../../commons.dart';

class home_wireless extends StatelessWidget {
  final bool isDark;
  final double wirelessPower;

  const home_wireless({
    super.key,
    required this.isDark,
    required this.wirelessPower,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: isDark ? const Color(0x15656566) : const Color(0x441727a3),
        borderRadius: BorderRadius.all(
          Radius.circular(containerRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Wireless',
                        style: TextStyle(
                          color: isDark ? const Color(0xffd4d2d2) : Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 20,
                      ),
                      child: Container(
                        width: 30,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(containerRadius),
                          ),
                          color: wirelessPower == 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          wirelessPower == 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text(
                    'Disconnected',
                    style: TextStyle(
                      color: isDark ? const Color(0x55d4d2d2) : Colors.black87,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 70,
                      width: 80,
                      child: RippleWave(
                        color: Colors.blueAccent,
                        repeat: true,
                        child: Icon(
                          Icons.charging_station,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '$wirelessPower W',
                      style: TextStyle(
                        color: isDark ? const Color(0xaad4d2d2) : Colors.black87,
                        fontSize: 15,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                )
        ],
      ),
    );
  }
}
