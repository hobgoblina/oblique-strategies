import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import '../main.dart';
import '../cards.dart';
import 'settings_item.dart';
import 'package:easy_localization/easy_localization.dart';

class CardsSettingsCard extends StatelessWidget {
  const CardsSettingsCard({ super.key });

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final Cards card = Cards();
    final storage = GetStorage();
    List<dynamic> strategyData = storage.read('strategyData') ?? [];
    final favorites = strategyData.where((card) => card['favorite'] == true).toList();

    Widget cardWrapper (List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.only(top: 25, bottom: 25, left: 20, right: 20),
        child: card.cardWrapper((paddingInterp) => Container(
          alignment: Alignment.center,
          color: Colors.white,
          padding: EdgeInsetsTween(
            begin: const EdgeInsets.symmetric(horizontal: 15), 
            end: const EdgeInsets.symmetric(horizontal: 75)
          ).lerp(paddingInterp),
          child: FocusTraversalGroup(
            descendantsAreFocusable: appState.cardFace == 'cards-settings',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children
            )
          )
        ))
      );
    }

    return cardWrapper([
      const Spacer(),
      const Spacer(),
      settingsItem(
        tooltip: context.tr('keepFavoritesInDeckTooltip'),
        text: context.tr('keepFavoritesInDeck'),
        child: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: storage.read('canAlwaysRedrawFavorites') ?? true,
            semanticLabel: context.tr('keepFavoritesInDeck'),
            onChanged: (val) {
              if (val is bool) {
                storage.write('canAlwaysRedrawFavorites', val);
                appState.rebuildApp();
              }
            }
          ),
        )
      ),
      const Spacer(),
      settingsItem(
        disabled: favorites.length <= 1,
        text: context.tr('onlyDrawFavorites'),
        tooltip: context.tr('onlyDrawFavoritesTooltip'),
        child: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: storage.read('onlyDrawFavorites') ?? false,
            semanticLabel: context.tr('onlyDrawFavorites'),
            side: BorderSide(
              strokeAlign: -.1,
              width: 1.75,
              color: favorites.length <= 1 ? Colors.blueGrey : Colors.black
            ),
            onChanged: favorites.length <= 1 ? null : (val) {
              if (val is bool) {
                storage.write('onlyDrawFavorites', val);
                appState.rebuildApp();
              }
            }
          ),
        )
      ),
      const Spacer(),
      const Spacer(),
    ]);
  }
}
