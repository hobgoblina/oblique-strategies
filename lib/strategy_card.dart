import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';
import 'cards.dart';
import 'main.dart';

class StrategyCard extends StatelessWidget {
  const StrategyCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    AppState state = context.watch<AppState>();

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
        if (
          event.logicalKey == LogicalKeyboardKey.space || 
          event.logicalKey == LogicalKeyboardKey.enter
        ) {
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

    bool refreshFavorite(int? newIndex) {
      if (newIndex is int) {
        List<dynamic> strategyData = storage.read('strategyData');
        final int strategyIndex = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == newIndex);
        print(strategyData[strategyIndex]);
        print(strategyData[strategyIndex]['favorite']);
        state.setCurrentFavorite(strategyData[strategyIndex]['favorite']);
      }

      return true;
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(const Size(750, 500)),
          child: Focus(
            autofocus: true,
            canRequestFocus: true,
            skipTraversal: false,
            onKey: handleKeyPress,
            child: CardSwiper(
              controller: controller,
              initialIndex: storage.read('currentIndex') ?? 0,
              cardsCount: 999999999,
              maxAngle: 15,
              backCardOffset: const Offset(0, 0),
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) => Cards().nextCard(index),
              onSwipe: (previousIndex, currentIndex, direction) => refreshFavorite(currentIndex),
              onUndo: (previousIndex, currentIndex, direction) => refreshFavorite(currentIndex),
              onEnd: () => storage.write('strategyData', []),
            ),
          )
        ),
      ),
    );
  }
}