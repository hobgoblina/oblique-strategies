import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';
import 'cards.dart';

class StrategyCard extends StatelessWidget {
  const StrategyCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final CardSwiperController controller = CardSwiperController();
    final storage = GetStorage();

    // Might need this for a stateful app
    // @override
    // void dispose() {
    //   controller.dispose();
    //   super.dispose();
    // }

    KeyEventResult handleKeyPress(FocusNode node, RawKeyEvent event) {
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.space) {
          switch (Random().nextInt(4)) {
            case 0:
              controller.swipeLeft();
            case 1:
              controller.swipeTop();
            case 2:
              controller.swipeRight();
            case 3:
              controller.swipeBottom();
          }

          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          controller.swipeLeft();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          controller.swipeTop();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          controller.swipeRight();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          controller.swipeBottom();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
          controller.undo();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(const Size(750, 500)),
          child: Focus(
            autofocus: true,
            canRequestFocus: true,
            onKey: handleKeyPress,
            child: CardSwiper(
              controller: controller,
              initialIndex: storage.read('currentIndex') ?? 0,
              cardsCount: 999999999,
              backCardOffset: const Offset(0, 0),
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) => Cards().nextCard(index),
              onEnd: () => storage.write('strategyData', []),
            ),
          )
        ),
      ),
    );
  }
}