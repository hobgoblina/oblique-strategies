import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';
import 'main.dart';
import 'strategies.dart';

class StrategyCard extends StatelessWidget {
  const StrategyCard({ super.key });

  Container nextCard(int index) {
    final storage = GetStorage();
    final lastIndex = storage.read('currentIndex');
    // minus 1 because this runs for the upcoming card
    storage.write('currentIndex', index - 1);

    final double minRedrawPercentage = storage.read('minRedrawPercentage') ?? 0.5;
    final double needsRedrawPercentage = storage.read('needsRedrawPercentage') ?? 1.5;
    final int maxAllowedLastDraw = (index - (strategies.length * minRedrawPercentage)).floor();
    final int minAllowedLastDraw = (index - (strategies.length * needsRedrawPercentage)).floor();
    List<dynamic> strategyData = storage.read('strategyData') ?? [];
    Container? next;

    final existingCard = strategyData.where((card) => card['lastDrawnAtIndex'] == index).toList();
    if (existingCard.isNotEmpty) {
      next = strategies[existingCard.first['strategyNumber']]['card'];
    }

    final tooOld = strategyData.where((card) => card['lastDrawnAtIndex'] < minAllowedLastDraw);
    if (tooOld.isNotEmpty) {
      next = strategies[tooOld.first['strategyNumber']]['card'];

      final int dataToUpdate = strategyData.indexWhere((card) => card['strategyNumber'] == tooOld.first['strategyNumber']);
      strategyData[dataToUpdate]['lastDrawnAtIndex'] = index;
    }

    while (next == null) {
      final int strategyNumber = Random().nextInt(strategies.length);
      final matches = strategyData.where((card) => card['strategyNumber'] == strategyNumber).toList();
      
      if (matches.isNotEmpty) {
        if (
          matches.first['lastDrawnAtIndex'] == lastIndex ||
          (matches.first['lastDrawnAtIndex'] > maxAllowedLastDraw &&
          !(matches.first['favorite'] && (storage.read('canAlwaysRedrawFavorites') ?? true)))
        ) {
          continue;
        }

        final int dataToUpdate = strategyData.indexWhere((card) => card['strategyNumber'] == strategyNumber);
        strategyData[dataToUpdate]['lastDrawnAtIndex'] = index;
      } else {
        strategyData.add({
          'strategyNumber': strategyNumber,
          'lastDrawnAtIndex': index,
          'favorite': false
        });
      }

      next = strategies[strategyNumber]['card'];
    }

    storage.write('strategyData', strategyData);
    return next;
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final storage = GetStorage();

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
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        appState.swipeController.swipeLeft();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        appState.swipeController.swipeTop();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        appState.swipeController.swipeRight();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        appState.swipeController.swipeBottom();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        appState.swipeController.undo();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

    bool refreshFavorite(int? newIndex) {
      if (newIndex is int) {
        List<dynamic> strategyData = storage.read('strategyData');
        final int strategyIndex = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == newIndex);
        appState.setCurrentFavorite(strategyData[strategyIndex]['favorite']);
      }

      return true;
    }

    return Focus(
      autofocus: true,
      canRequestFocus: !appState.settingsOpen,
      skipTraversal: false,
      onKey: handleKeyPress,
      child: Semantics(
        label: 'The current strategy card. Press space, enter, or the arrow keys to go to the next strategy. Press backspace to return to the previous strategy.',
        child: CardSwiper(
          controller: appState.swipeController,
          initialIndex: storage.read('currentIndex') ?? 0,
          cardsCount: 999999999,
          maxAngle: 13,
          duration: storage.read('reduceAnimations') ?? false ? Duration.zero : const Duration(milliseconds: 300),
          backCardOffset: const Offset(0, 0),
          scale: 1,
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) => GestureDetector(
            onTap: () => appState.setIconsVisible(),
            child: nextCard(index)
          ),
          onSwipe: (previousIndex, currentIndex, direction) => refreshFavorite(currentIndex),
          onUndo: (previousIndex, currentIndex, direction) => refreshFavorite(currentIndex),
          onEnd: () => storage.write('strategyData', []),
        ),
      ),
    );
  }
}