import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';
import 'main.dart';
import 'strategies.dart';
import 'title_card.dart';
import 'instructions_card.dart';
import 'notifications.dart';

class StrategyCard extends StatelessWidget {
  const StrategyCard({ super.key });

  Map<String, dynamic> nextCard(int index, Map<int, int> sessionDrawnCards) {
    final storage = GetStorage();
    final double minRedrawPercentage = storage.read('minRedrawPercentage') ?? 0.5;
    final double needsRedrawPercentage = storage.read('needsRedrawPercentage') ?? 1.5;
    int maxAllowedLastDraw = (index - (strategies.length * minRedrawPercentage)).ceil();
    int minAllowedLastDraw = (index - (strategies.length * needsRedrawPercentage)).ceil();
    List<dynamic> strategyData = storage.read('strategyData') ?? [];
    final favorites = strategyData.where((card) => card['favorite'] == true).toList();
    Map<String, dynamic>? next;
    bool nextIsFavorite = false;
    final bool onlyFavorites = storage.read('onlyDrawFavorites') ?? false;

    if (index == 0) {
      next = { 'card': const InstructionsCard() };
    } else if (index == 1) {
      next = { 'card': const TitleCard() };
    } else {
      final existingCardInSession = sessionDrawnCards.containsKey(index);

      if (existingCardInSession) {
        next = strategies[sessionDrawnCards[index] ?? 0];
        nextIsFavorite = strategyData.where((card) => card['strategyNumber'] == sessionDrawnCards[index]).toList().first['favorite'];
      } else {
        final existingCard = strategyData.where((card) => card['lastDrawnAtIndex'] == index).toList();
        if (existingCard.isNotEmpty) {
          next = strategies[existingCard.first['strategyNumber']];
          nextIsFavorite = existingCard.first['favorite'];
        }
      }

      if (onlyFavorites) {
        strategyData.sort((s1, s2) => s2['lastDrawnAtIndex'] - s1['lastDrawnAtIndex']);
        if (
          next is Widget &&
          !nextIsFavorite &&
          storage.read('currentIndex') != index &&
          strategyData.first['lastDrawnAtIndex'] <= index
        ) {
          next = null;
        }
        maxAllowedLastDraw = (index - (favorites.length * minRedrawPercentage)).ceil();
        minAllowedLastDraw = (index - (favorites.length * needsRedrawPercentage)).ceil();
      }

      final tooOld = (onlyFavorites ? favorites : strategyData).where((card) => card['lastDrawnAtIndex'] < minAllowedLastDraw);
      if (next == null && tooOld.isNotEmpty) {
        next = strategies[tooOld.first['strategyNumber']];

        final int dataToUpdate = strategyData.indexWhere((card) => card['strategyNumber'] == tooOld.first['strategyNumber']);
        strategyData[dataToUpdate]['lastDrawnAtIndex'] = index;
      }

      while (next == null) {
        if (onlyFavorites) {
          final int favoriteNumber = Random().nextInt(favorites.length);

          if (
            favorites[favoriteNumber]['lastDrawnAtIndex'] == index - 1 ||
            (
              index - maxAllowedLastDraw > 1 &&
              favorites[favoriteNumber]['lastDrawnAtIndex'] > maxAllowedLastDraw
            )
          ) {
            continue;
          }

          final int dataToUpdate = strategyData.indexWhere((card) => card['strategyNumber'] == favorites[favoriteNumber]['strategyNumber']);
          strategyData[dataToUpdate]['lastDrawnAtIndex'] = index;

          next = strategies[favorites[favoriteNumber]['strategyNumber']];
          sessionDrawnCards[index] = favorites[favoriteNumber]['strategyNumber'];
        } else {
          final int strategyNumber = Random().nextInt(strategies.length);
          final matches = strategyData.where((card) => card['strategyNumber'] == strategyNumber).toList();
          
          if (matches.isNotEmpty) {
            if (
              matches.first['lastDrawnAtIndex'] == index - 1 ||
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

          next = strategies[strategyNumber];
          sessionDrawnCards[index] = strategyNumber;
        }
      }

      storage.write('strategyData', strategyData);
    }

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
        }
      }
      return KeyEventResult.ignored;
    }

    bool onSwipe(int? newIndex) {
      storage.write('currentIndex', newIndex);
      LocalNotificationService().notificationsPlugin.cancelAll();
      storage.write('nextNotificationTime', null);
      createNotifications(null, null);

      if (newIndex is int && newIndex > 1) {
        appState.titleCardsSeen = true;
        List<dynamic> strategyData = storage.read('strategyData');
        int strategyIndex = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == newIndex || card['strategyNumber'] == appState.drawnCards[newIndex]);

        if (strategyIndex != -1) {
          appState.setCurrentFavorite(strategyData[strategyIndex]['favorite']);
        }
      } else {
        appState.setTitleCardsSeen(false);
      }

      return true;
    }

    return Focus(
      autofocus: true,
      canRequestFocus: appState.cardFace == 'strategies',
      skipTraversal: false,
      onKey: handleKeyPress,
      child: Semantics(
        label: 'The current strategy card. Press enter, space, or the arrow keys to go to the next strategy. Press backspace to return to the previous strategy.',
        child: CardSwiper(
          controller: appState.swipeController,
          initialIndex: storage.read('currentIndex') ?? 0,
          cardsCount: 999999999,
          maxAngle: 13,
          duration: storage.read('reduceAnimations') ?? false ? Duration.zero : const Duration(milliseconds: 300),
          backCardOffset: const Offset(0, 0),
          scale: 1,
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) => GestureDetector(
            onTapUp: (tapUpDetails) => appState.setIconsVisible(),
            child: nextCard(index, appState.drawnCards)['card']
          ),
          onSwipe: (previousIndex, currentIndex, direction) => onSwipe(currentIndex),
          onUndo: (previousIndex, currentIndex, direction) => onSwipe(currentIndex),
          onEnd: () => storage.write('strategyData', []),
        ),
      ),
    );
  }
}
