import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import '../main.dart';
import '../cards.dart';
import 'settings_item.dart';

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
            descendantsAreFocusable: appState.cardFace == 'deck',
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
      const Spacer(),
      settingsItem(
        tooltip: 'Allows favorited cards to be redrawn anytime. It usually takes a while before a card can be redrawn.',
        text: 'Keep favorites in the deck',
        child: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: storage.read('canAlwaysRedrawFavorites') ?? true,
            semanticLabel: 'Allows favorited cards to be redrawn anytime. It usually takes a while before a card can be redrawn.',
            onChanged: (val) {
              if (val is bool) {
                storage.write('canAlwaysRedrawFavorites', val);
                appState.rebuildApp();
              }
            }
          ),
        )
      ),
      Visibility(visible: favorites.length > 1, child: const Spacer()),
      Visibility(
        visible: favorites.length > 1,
        child: settingsItem(
          text: 'Only draw favorites',
          child: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: storage.read('onlyDrawFavorites') ?? false,
              semanticLabel: 'Only draw favorites',
              onChanged: (val) {
                if (val is bool) {
                  storage.write('onlyDrawFavorites', val);
                  appState.rebuildApp();
                }
              }
            ),
          )
        ),
      ),
      const Spacer(),
      const Spacer(),
      const Spacer(),
    ]);
  }
}
