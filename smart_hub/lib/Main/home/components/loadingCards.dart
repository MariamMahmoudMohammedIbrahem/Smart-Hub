import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';

class LoadingCards extends StatelessWidget {
  final double cardHeight;
  final double cardWidth;
  final double cardBoarderRadius;

  final Color colorOne;
  final Color colorTwo;

  const LoadingCards({
    super.key,
    required this.cardBoarderRadius,
    required this.cardHeight,
    required this.cardWidth,
    required this.colorOne,
    required this.colorTwo,
  });

  @override
  Widget build(BuildContext context) {
    return CardLoading(
      height: cardHeight,
      width: cardWidth,
      borderRadius: BorderRadius.all(
        Radius.circular(cardBoarderRadius),
      ),
      animationDuration: const Duration(seconds: 1),
      animationDurationTwo: const Duration(seconds: 1),
      margin: const EdgeInsets.only(bottom: 10),
      cardLoadingTheme:
          CardLoadingTheme(colorOne: colorOne, colorTwo: colorTwo),
    );
  }
}
