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
    bool wrapControls = false,
    required String text,
    required Widget child,
  }) {
    final settingItemContent = tooltip is String ? Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      showDuration: kIsWeb ? null : const Duration(milliseconds: 5000),
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8, bottom: 3),
            child: Icon(
              Ionicons.information_circle_outline,
              color: Colors.black,
              size: 25
            ),
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 21)
            ),
          ),
        ],
      ),
    ) : Text(
      text,
      textWidthBasis: TextWidthBasis.longestLine,
      style: const TextStyle(fontSize: 21)
    );

    return wrapControls ? Row(
      children: [
        Expanded(
          child: Wrap (
            direction: Axis.horizontal,
            alignment: WrapAlignment.spaceBetween,
            children: [
              settingItemContent,
              child
            ],
          ),
        ),
      ],
    ) : Row(
      children: [
        Expanded(child: settingItemContent),
        child
      ],
    );
  }

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
      const Visibility(visible: !kIsWeb, child: Spacer()),
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
      Visibility(
        visible: !kIsWeb && (storage.read('currentIndex') ?? 0) > 1,
        child: Center(
          child: TextButton(
            onPressed: () => appState.setCardFrontAndFlip('notifications'),
            child: const Text(
              'Notifications',
              semanticsLabel: 'Open notifications settings',
              style: TextStyle(decoration: TextDecoration.underline)
            ),
          ),
        ),
      ),
      const Spacer(),
    ]);
  }
}
