import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import '../main.dart';
import '../cards.dart';
import 'settings_item.dart';

class LookAndFeelSettingsCard extends StatelessWidget {
  const LookAndFeelSettingsCard({ super.key });

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
      const Visibility(visible: !kIsWeb, child: Spacer()),
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
      settingsItem(
        tooltip: kIsWeb
          ? 'If disabled, controls will disappear after a few seconds of mouse inactivity.'
          : 'If disabled, controls will disappear after a few seconds. Tap anywhere to reveal them again.',
        text: 'Always show controls',
        child: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: storage.read('alwaysShowControls') ?? true,
            semanticLabel: 'Always show controls',
            onChanged: (val) {
              if (val is bool) {
                storage.write('alwaysShowControls', val);
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
