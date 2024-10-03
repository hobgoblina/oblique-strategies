import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:easy_localization/easy_localization.dart';

import '../main.dart';
import '../cards.dart';

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
      const Spacer(),
      Center(
        child: TextButton(
          onPressed: () => appState.setCardFrontAndFlip('about'),
          child: Text(
            context.tr('about'),
            semanticsLabel: context.tr('aboutLabel'),
            style: const TextStyle(fontSize: 23, decoration: TextDecoration.underline)
          ),
        ),
      ),
      const Spacer(),
      Center(
        child: TextButton(
          onPressed: () => appState.setCardFrontAndFlip('cards-settings'),
          child: Text(
            context.tr('cards'),
            semanticsLabel: context.tr('cardsLabel'),
            style: const TextStyle(fontSize: 23, decoration: TextDecoration.underline)
          ),
        ),
      ),
      const Spacer(),
      Center(
        child: TextButton(
          onPressed: () => appState.setCardFrontAndFlip('look-and-feel-settings'),
          child: Text(
            context.tr('lookAndFeel'),
            semanticsLabel: context.tr('lookAndFeelLabel'),
            style: const TextStyle(fontSize: 23, decoration: TextDecoration.underline)
          ),
        ),
      ),
      Visibility(
        visible: !kIsWeb && (storage.read('currentIndex') ?? 0) > 1,
        child: const Spacer()
      ),
      Visibility(
        visible: !kIsWeb && (storage.read('currentIndex') ?? 0) > 1,
        child: Center(
          child: TextButton(
            onPressed: () => appState.setCardFrontAndFlip('notifications-settings'),
            child: Text(
              context.tr('notifications'),
              semanticsLabel: context.tr('notificationsLabel'),
              style: const TextStyle(fontSize: 23, decoration: TextDecoration.underline)
            ),
          ),
        ),
      ),
      const Spacer(),
      const Spacer(),
    ]);
  }
}
