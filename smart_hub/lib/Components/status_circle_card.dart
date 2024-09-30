import 'package:flutter/material.dart';

class StatusCircleCard extends StatelessWidget {
  final double circleRadius;
  final Icon circleIcon;
  final String circleText;
  final bool isDark;

  const StatusCircleCard({
    super.key,
    required this.circleRadius,
    required this.circleIcon,
    required this.circleText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleRadius,
      height: circleRadius,
      decoration: BoxDecoration(
        color: isDark ? Colors.white54 : Colors.black38,
        shape: BoxShape.circle,
      ),
      child: Column(
        children: [
          circleIcon,
          SizedBox(
            height: 5,
          ),
          Text(
            circleText,
          ),
        ],
      ),
    );
  }
}
