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
              textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 75),
                    child: Text(
                      'Next card',
                      textScaleFactor: 1.5
                    ),
                  ),
                ),
                Text(
                  'Arrow keys',
                  textScaleFactor: 1.5
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 75),
                    child: Text(
                      'Next card (when card has focus)',
                      textScaleFactor: 1.5
                    ),
                  ),
                ),
                Text(
                  'Enter, Space',
                  textScaleFactor: 1.5
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 75),
                    child: Text(
                      'Previous card',
                      textScaleFactor: 1.5
                    ),
                  ),
                ),
                Text(
                  'Backspace',
                  textScaleFactor: 1.5
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 75),
                    child: Text(
                      'Add to favorites',
                      textScaleFactor: 1.5
                    ),
                  ),
                ),
                Text(
                  'F',
                  textScaleFactor: 1.5
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