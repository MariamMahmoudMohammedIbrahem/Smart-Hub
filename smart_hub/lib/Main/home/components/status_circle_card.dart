
import '../../../commons.dart';

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
      decoration: const BoxDecoration(
        color: Colors.white12,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          circleIcon,
          const SizedBox(
            height: 5,
          ),
          Text(
            circleText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
