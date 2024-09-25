import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';

class LoadingCards extends StatelessWidget {
  final double cardHeight;
  final double cardWidth;
  final double cardBoarderRadius;
  const LoadingCards({
    super.key,
    required this.cardBoarderRadius,
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CardLoading(
      height: cardHeight,
      width: cardWidth,
      borderRadius: BorderRadius.all(
        Radius.circular(cardBoarderRadius),
      ),
      animationDuration: Duration(seconds: 1),
      animationDurationTwo: Duration(seconds: 1),
      margin: EdgeInsets.only(bottom: 10),
      cardLoadingTheme:
          CardLoadingTheme(colorOne: Colors.white12, colorTwo: Colors.black12),
    );
  }
}
