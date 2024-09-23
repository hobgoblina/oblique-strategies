import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
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
          child: const Text(
            'About',
            semanticsLabel: 'Show information about this app',
            style: TextStyle(fontSize: 23, decoration: TextDecoration.underline)
          ),
        ),
      ),
      const Spacer(),
      Center(
        child: TextButton(
          onPressed: () => appState.setCardFrontAndFlip('cards-settings'),
          child: const Text(
            'Cards',
            semanticsLabel: 'Open card settings',
            style: TextStyle(fontSize: 23, decoration: TextDecoration.underline)
          ),
        ),
      ),
      const Spacer(),
      Center(
        child: TextButton(
          onPressed: () => appState.setCardFrontAndFlip('look-and-feel-settings'),
          child: const Text(
            'Look and feel',
            semanticsLabel: 'Open look and feel settings',
            style: TextStyle(fontSize: 23, decoration: TextDecoration.underline)
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
            child: const Text(
              'Notifications',
              semanticsLabel: 'Open notifications settings',
              style: TextStyle(fontSize: 23, decoration: TextDecoration.underline)
            ),
          ),
        ),
      ),
      const Spacer(),
      const Spacer(),
    ]);
  }
}
