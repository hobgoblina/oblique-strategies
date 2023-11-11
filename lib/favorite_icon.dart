import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class FavoriteIcon extends StatelessWidget {
  const FavoriteIcon({ super.key });
    
    void addToFavorites(AppState appState) {
      final storage = GetStorage();
      int? index = storage.read('currentIndex');

      if (index is int) {
        final List<dynamic> strategyData = storage.read('strategyData');
        final int dataToUpdate = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == index || card['strategyNumber'] == appState.drawnCards[index]);
        final bool favorite = !strategyData[dataToUpdate]['favorite'];
        strategyData[dataToUpdate]['favorite'] = favorite;
        storage.write('strategyData', strategyData);

        if (!favorite) {
          final favorites = strategyData.where((card) => card['favorite'] == true).toList();
          
          if (favorites.length < 2) {
            storage.write('onlyDrawFavorites', false);
          }
        }

        appState.setCurrentFavorite(favorite);
        appState.setIconsVisible();
      }
    }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final storage = GetStorage();

    int? index = storage.read('currentIndex');
    final bool indexIsPastOne = index is int && index > 1;

    if (appState.currentIsFavorite == null) {
      if (indexIsPastOne) {
        List<dynamic> strategyData = storage.read('strategyData');
        final int currentIndex = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == index);
        appState.currentIsFavorite = strategyData[currentIndex]['favorite'];
        appState.titleCardsSeen = true;
      } else {
        appState.currentIsFavorite = false;
      }
    }

    return Visibility(
      visible: appState.cardFace == 'strategies' && appState.titleCardsSeen,
      child: AnimatedOpacity(
        opacity: appState.iconsVisible ? 1.0 : 0.0,
        duration: storage.read('reduceAnimations') ?? false ? Duration.zero : const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.topRight,
          child: IconButton(
            hoverColor: const Color.fromRGBO(25, 25, 25, 1),
            focusColor: const Color.fromRGBO(25, 25, 25, 1),
            onPressed: () => addToFavorites(appState),
            tooltip: '${appState.currentIsFavorite ?? false ? 'Remove from' : 'Add to'} favorites',
            icon: Icon(
              Ionicons.heart_outline,
              semanticLabel: '${appState.currentIsFavorite ?? false ? 'Remove from' : 'Add to'} favorites',
              color: (appState.currentIsFavorite ?? false) ? Colors.red : Colors.white,
              size: 40
            ),
          ),
        ),
      ),
    );
  }
}
