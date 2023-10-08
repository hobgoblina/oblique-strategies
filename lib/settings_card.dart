import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'main.dart';
import 'cards.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({ super.key });

  Widget settingsItem({
    String? tooltip,
    required String text,
    required Widget child
  }) {
    return Row(
      children: [
        tooltip is String ? Expanded(
          child: Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            showDuration: kIsWeb ? null : const Duration(milliseconds: 5000),
            message: tooltip,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Ionicons.information_circle_outline,
                    color: Colors.black,
                    size: 25
                  ),
                ),
                Expanded(
                  child: Text(
                    text,
                    textWidthBasis: TextWidthBasis.longestLine,
                    textScaleFactor: 1.5
                  ),
                ),
              ],
            ),
          ),
        ) : Expanded(
          child: Text(
            text,
            textWidthBasis: TextWidthBasis.longestLine,
            textScaleFactor: 1.5
          ),
        ),
        child
      ],
    );
  }

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
            descendantsAreFocusable: appState.settingsOpen,
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
            textScaleFactor: 1.1,
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
            autofocus: true,
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
      const Spacer(),
      Visibility(
        visible: kIsWeb,
        child: Center(
          child: TextButton(
            onPressed: () => appState.setCardFrontAndFlip('notifications'),
            child: const Text(
              'Notifications',
              textScaleFactor: 1.1,
              style: TextStyle(decoration: TextDecoration.underline)
            ),
          ),
        ),
      ),
      const Spacer(),
    ]);
  }
}