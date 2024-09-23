import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../main.dart';
import '../cards.dart';

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
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)
            ),
            Spacer(),
            Text(
              'Swipe this card to reveal a new card',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21)
            ),
            Spacer(),
            Visibility(
              visible: kIsWeb,
              child: Text(
                'You can also swipe with the arrow keys',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 21)
              ),
            ),
            Visibility(visible: kIsWeb, child: Spacer()),
            Text(
              'Undo swipes with the ${kIsWeb ? 'backspace key' : 'back button'}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21)
            ),
            Spacer(),
            Spacer(),
          ]
        )
      )
    ));
  }
}
