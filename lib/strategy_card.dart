import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';
import 'main.dart';
import 'strategies.dart';
import 'info-cards/title_card.dart';
import 'info-cards/instructions_card.dart';
import 'notifications.dart';

class StrategyCard extends StatelessWidget {
  const StrategyCard({ super.key });

  Map<String, dynamic> nextCard(int index, Map<int, int> sessionDrawnCards, BuildContext? context) {
    final storage = GetStorage();
    final strategies = Strategies();
    int? nextIndex;
    bool nextIsFavorite = false;
    final bool onlyFavorites = storage.read('onlyDrawFavorites') ?? false;

    // These don't have settings yet, but can be used to change how frequently cards get redrawn
    final double minRedrawPercentage = storage.read('minRedrawPercentage') ?? 0.5;
    final double needsRedrawPercentage = storage.read('needsRedrawPercentage') ?? 1.5;

    // Determine the index of the most recently drawn card that can be redrawn
    int maxAllowedLastDraw = (index - (strategies.length * minRedrawPercentage)).ceil();

    // Determine the index of a card that must be redrawn bc it's been too long
    int minAllowedLastDraw = (index - (strategies.length * needsRedrawPercentage)).ceil();

    // Fetch strategyData from local storage
    // Contains card ID, last drawn index, favorite data, etc.
    List<dynamic> strategyData = storage.read('strategyData') ?? [];
    final favorites = strategyData.where((card) => card['favorite'] == true).toList();

    // Show title & instructions cards if no cards have been swiped
    if (index == 0) {
      return { 'card': const InstructionsCard() };
    } else if (index == 1) {
      return { 'card': const TitleCard() };
    }

    // Find the current card (from the session if possible, or from lastDrawnAtIndex)
    final existingCardInSession = sessionDrawnCards.containsKey(index);

    if (existingCardInSession) {
      nextIndex = sessionDrawnCards[index] ?? 0;
      nextIsFavorite = strategyData.where((card) => card['strategyNumber'] == sessionDrawnCards[index]).toList().first['favorite'];
    } else {
      final existingCard = strategyData.where((card) => card['lastDrawnAtIndex'] == index).toList();
      if (existingCard.isNotEmpty) {
        nextIndex = existingCard.first['strategyNumber'];
        nextIsFavorite = existingCard.first['favorite'];
      }
    }

    // Draw from favorites if `onlyFavorites == true`
    if (onlyFavorites) {
      strategyData.sort((s1, s2) => s2['lastDrawnAtIndex'] - s1['lastDrawnAtIndex']);
      if (
        nextIndex is int &&
        !nextIsFavorite &&
        storage.read('currentIndex') != index &&
        strategyData.first['lastDrawnAtIndex'] <= index
      ) {
        nextIndex = null;
      }

      // scale these to the number of favorites
      maxAllowedLastDraw = (index - (favorites.length * minRedrawPercentage)).ceil();
      minAllowedLastDraw = (index - (favorites.length * needsRedrawPercentage)).ceil();
    }

    // Check if there's any cards that must be redrawn because it's been too long
    final tooOld = (onlyFavorites ? favorites : strategyData).where((card) => card['lastDrawnAtIndex'] < minAllowedLastDraw);
    if (nextIndex == null && tooOld.isNotEmpty) {
      nextIndex = tooOld.first['strategyNumber'];

      final int dataToUpdate = strategyData.indexWhere((card) => card['strategyNumber'] == tooOld.first['strategyNumber']);
      strategyData[dataToUpdate]['lastDrawnAtIndex'] = index;
    }

    // Pick a random card and check if it's allowed to be redrawn, repeat until it's allowed
    while (nextIndex == null) {
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

        nextIndex = favorites[favoriteNumber]['strategyNumber'];
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

        nextIndex = strategyNumber;
        sessionDrawnCards[index] = strategyNumber;
      }
    }

    storage.write('strategyData', strategyData);

    return strategies.buildCard(nextIndex, context);
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final storage = GetStorage();

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

    bool onSwipe(int? newIndex) {
      storage.write('currentIndex', newIndex);

      if (!kIsWeb) {
        LocalNotificationService().notificationsPlugin.cancelAll();
        final last = storage.read('lastScheduledNotification');
        
        if (last != null) {
          final lastTime = DateTime.parse(last);

          if (lastTime.isAfter(DateTime.now())) {
            storage.write('nextNotificationTime', last.toString());
            storage.write('lastScheduledNotification', null);
            storage.write('lastScheduledIndex', null);
          }
        }

        createNotifications(null, null);
      }

      // Set `titleCardsSeen` and favorite icon statuses for upcoming card
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
      onKeyEvent: handleKeyPress,
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
          child: nextCard(index, appState.drawnCards, context)['card']
        ),
        onSwipe: (previousIndex, currentIndex, direction) => onSwipe(currentIndex),
        onUndo: (previousIndex, currentIndex, direction) => onSwipe(currentIndex),
        onEnd: () => storage.write('strategyData', []),
      ),
    );
  }
}
