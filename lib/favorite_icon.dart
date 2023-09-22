import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class FavoriteIcon extends StatelessWidget {
  const FavoriteIcon({ super.key });

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final storage = GetStorage();
    
    void addToFavorites() {
      int? index = storage.read('currentIndex');

      if (index is int) {
        final List<dynamic> strategyData = storage.read('strategyData');
        final int dataToUpdate = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == index);
        final bool favorite = !strategyData[dataToUpdate]['favorite'];
        strategyData[dataToUpdate]['favorite'] = favorite;
        storage.write('strategyData', strategyData);
        appState.setCurrentFavorite(favorite);
        appState.setIconsVisible();
      }
    }

    if (appState.currentIsFavorite == null) {
      int? index = storage.read('currentIndex');
      if (storage.read('currentIndex') is int) {
        List<dynamic> strategyData = storage.read('strategyData');
        final int currentIndex = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == index);
        appState.currentIsFavorite = strategyData[currentIndex]['favorite'];
      } else {
        appState.currentIsFavorite = false;
      }
    }

    return Visibility(
      visible: !appState.settingsOpen,
      child: AnimatedOpacity(
        opacity: appState.iconsVisible ? 1.0 : 0.0,
        duration: storage.read('reduceAnimations') ?? false ? Duration.zero : const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: addToFavorites,
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