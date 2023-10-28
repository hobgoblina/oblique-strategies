import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';
import 'main.dart';
import 'title_card.dart';
import 'about_card.dart';
import 'hotkeys_card.dart';
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
      const InstructionsCard(),
      const HotkeysCard()
    ];

    KeyEventResult handleKeyPress(FocusNode node, RawKeyEvent event) {
      if (event is RawKeyDownEvent) {
        if (
          event.logicalKey == LogicalKeyboardKey.space || 
          event.logicalKey == LogicalKeyboardKey.enter
        ) {
          switch (Random().nextInt(4)) {
            case 0:
              appState.swipeController.swipeLeft();
            case 1:
              appState.swipeController.swipeTop();
            case 2:
              appState.swipeController.swipeRight();
            case 3:
              appState.swipeController.swipeBottom();
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
      onKey: handleKeyPress,
      child: Semantics(
        label: 'Title and about cards. To go to the next card, you can press enter, space, or the arrow keys while the card has focus. Press backspace to return to the previous card.',
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
      ),
    );
  }
}