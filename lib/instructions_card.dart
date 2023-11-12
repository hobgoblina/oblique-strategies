import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'main.dart';
import 'cards.dart';

class InstructionsCard extends StatelessWidget {
  const InstructionsCard({
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
              'Using This App',
              textAlign: TextAlign.center,
              textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            Spacer(),
            Text(
              'Swipe this card to reveal a new card',
              textAlign: TextAlign.center,
              textScaleFactor: 1.5
            ),
            Text(
              '\nYou can also swipe with the arrow keys',
              textAlign: TextAlign.center,
              textScaleFactor: 1.5
            ),
            Text(
              '\nUndo swipes with the ${!kIsWeb ? 'back button or ' : ''}backspace key',
              textAlign: TextAlign.center,
              textScaleFactor: 1.5
            ),
            Visibility(
              visible: !kIsWeb,
              child: Text(
                '\nTap anywhere to see the favorite and settings buttons',
                textAlign: TextAlign.center,
                textScaleFactor: 1.5
              ),
            ),
            Spacer(),
            Spacer(),
          ]
        )
      )
    ));
  }
}
