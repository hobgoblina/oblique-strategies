import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'cards.dart';

class HotkeysCard extends StatelessWidget {
  const HotkeysCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Cards card = Cards();
    AppState appState = context.watch<AppState>();

    return card.cardWrapper((paddingInterp) => Container(
      alignment: Alignment.center,
      color: Colors.white,
      padding: EdgeInsetsTween(
        begin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), 
        end: const EdgeInsets.symmetric(horizontal: 75, vertical: 15)
      ).lerp(paddingInterp),
      child: FocusTraversalGroup(
        descendantsAreFocusable: appState.cardFace == 'about',
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'Hotkeys',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Next card',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 21)
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    '•',
                    style: TextStyle(fontSize: 21)
                  ),
                ),
                Expanded(
                  child: Text(
                    'Arrow keys',
                    style: TextStyle(fontSize: 21)
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Previous card',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 21)
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    '•',
                    style: TextStyle(fontSize: 21)
                  ),
                ),
                Expanded(
                  child: Text(
                    'Backspace',
                    style: TextStyle(fontSize: 21)
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Favorite',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 21)
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    '•',
                    style: TextStyle(fontSize: 21)
                  ),
                ),
                Expanded(
                  child: Text(
                    'F',
                    style: TextStyle(fontSize: 21)
                  ),
                ),
              ],
            ),
            Spacer(),
            Spacer(),
          ]
        )
      )
    ));
  }
}
