import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'main.dart';

class FavoriteIcon extends StatelessWidget {
  const FavoriteIcon({
    super.key,
    required this.iconState,
  });

  final IconState iconState;

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    
    void addToFavorites() {
      int? index = storage.read('currentIndex');

      if (index is int) {
        final List<dynamic> strategyData = storage.read('strategyData');
        final int dataToUpdate = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == index);
        final bool favorite = !strategyData[dataToUpdate]['favorite'];
        strategyData[dataToUpdate]['favorite'] = favorite;
        storage.write('strategyData', strategyData);
        iconState.setCurrentFavorite(favorite);
        iconState.setIconsVisible();
      }
    }

    if (iconState.currentIsFavorite == null) {
      int? index = storage.read('currentIndex');
      if (storage.read('currentIndex') is int) {
        List<dynamic> strategyData = storage.read('strategyData');
        final int currentIndex = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == index);
        iconState.currentIsFavorite = strategyData[currentIndex]['favorite'];
      } else {
        iconState.currentIsFavorite = false;
      }
    }

    return ListenableBuilder(
      listenable: iconState,
      builder: (context, child) => AnimatedOpacity(
        opacity: iconState.iconsVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: addToFavorites,
            tooltip: '${iconState.currentIsFavorite ?? false ? 'Remove from' : 'Add to'} favorites',
            icon: Icon(
              Ionicons.heart_outline,
              semanticLabel: '${iconState.currentIsFavorite ?? false ? 'Remove from' : 'Add to'} favorites',
              color: (iconState.currentIsFavorite ?? false) ? Colors.red : Colors.white,
              size: 40
            ),
          ),
        ),
      ),
    );
  }
}