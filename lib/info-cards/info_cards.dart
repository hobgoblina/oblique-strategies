import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';
import '../main.dart';
import 'title_card.dart';
import 'about_card.dart';
import 'instructions_card.dart';

class InfoCards extends StatelessWidget {
  const InfoCards({ super.key });

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final storage = GetStorage();

    final cards = [
      const TitleCard(),
      const AboutCard(),
      const InstructionsCard()
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    if (screenWidth < 700 || screenHeight < 500) {
      cards.insert(2, const AboutCard2());
    }

    KeyEventResult handleKeyPress(FocusNode node, KeyEvent event) {
      if (event is KeyDownEvent) {
        if (
          event.logicalKey == LogicalKeyboardKey.space || 
          event.logicalKey == LogicalKeyboardKey.enter
        ) {
          switch (Random().nextInt(4)) {
            case 0:
              appState.swipeController.swipe(CardSwiperDirection.left);
            case 1:
              appState.swipeController.swipe(CardSwiperDirection.top);
            case 2:
              appState.swipeController.swipe(CardSwiperDirection.right);
            case 3:
              appState.swipeController.swipe(CardSwiperDirection.bottom);
          }

          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    }

    return Focus(
      autofocus: true,
      canRequestFocus: appState.cardFace == 'about',
      skipTraversal: false,
      onKeyEvent: handleKeyPress,
      child: CardSwiper(
        controller: appState.swipeController,
        initialIndex: 0,
        cardsCount: cards.length,
        maxAngle: 13,
        duration: storage.read('reduceAnimations') ?? false ? Duration.zero : const Duration(milliseconds: 300),
        backCardOffset: const Offset(0, 0),
        scale: 1,
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) => cards[index],
      ),
    );
  }
}
