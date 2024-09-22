import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import '../main.dart';
import '../cards.dart';
import 'settings_item.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({ super.key });

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final Cards card = Cards();
    final storage = GetStorage();

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
            descendantsAreFocusable: appState.cardFace == 'settings',
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
      Center(
        child: TextButton(
          onPressed: () => appState.setCardFrontAndFlip('about'),
          child: const Text(
            'About',
            semanticsLabel: 'Show information about this app',
            style: TextStyle(decoration: TextDecoration.underline)
          ),
        ),
      ),
      const Spacer(),
      settingsItem(
        tooltip: 'A reload may be required for certain animation changes to take effect.',
        text: 'Reduce animations',
        child: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: storage.read('reduceAnimations') ?? false,
            semanticLabel: 'Reduce animations',
            onChanged: (val) {
              if (val is bool) {
                storage.write('reduceAnimations', val);
                appState.rebuildApp();
              }
            }
          ),
        )
      ),
      const Spacer(),
      Visibility(
        visible: !kIsWeb,
        child: settingsItem(
          tooltip: 'Hides the navigation and status bars',
          text: 'Immersive mode',
          child: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: storage.read('immersiveMode') ?? false,
              semanticLabel: 'Immersive mode',
              onChanged: (val) {
                if (val is bool) {
                  storage.write('immersiveMode', val);
                  appState.rebuildApp();
                }
              }
            ),
          )
        ),
      ),
      const Spacer(),
      Center(
        child: TextButton(
          onPressed: () => appState.setCardFrontAndFlip('cards-settings'),
          child: const Text(
            'Cards',
            semanticsLabel: 'Open card settings',
            style: TextStyle(decoration: TextDecoration.underline)
          ),
        ),
      ),
      Column(
        children: [
          const Spacer(),
          Visibility(
            visible: !kIsWeb && (storage.read('currentIndex') ?? 0) > 1,
            child: Center(
              child: TextButton(
                onPressed: () => appState.setCardFrontAndFlip('notifications-settings'),
                child: const Text(
                  'Notifications',
                  semanticsLabel: 'Open notifications settings',
                  style: TextStyle(decoration: TextDecoration.underline)
                ),
              ),
            ),
          ),
        ],
      ),
      const Spacer(),
    ]);
  }
}
