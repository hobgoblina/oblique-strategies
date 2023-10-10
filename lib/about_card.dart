import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'cards.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({
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
        begin: const EdgeInsets.symmetric(horizontal: 15), 
        end: const EdgeInsets.symmetric(horizontal: 75)
      ).lerp(paddingInterp),
      child: FocusTraversalGroup(
        descendantsAreFocusable: appState.settingsOpen && appState.currentCardFront == 'about',
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'OBLIQUE STRATEGIES',
              textAlign: TextAlign.center,
              textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              'Over one hundred worthwhile dilemmas',
              textAlign: TextAlign.center,
              textScaleFactor: 1.4,
            ),
            Spacer(),
            Text(
              'These cards evolved from our separate observations of the principals underlying what we were doing. Sometimes they were recognized in retrospect (intellect catching up with intuition), sometimes they were identified as they were happening, sometimes they were formulated.',
              textAlign: TextAlign.justify,
              textScaleFactor: 1.2
            ),
            Text(
              'They can be used as a pack (a set of possibilities being continuously reviewed in the mind) or by drawing a single card from the shuffled pack when a dilemma occurs in a working situation. In this case the card is trusted even if its appropriateness is quite unclear. They are not final, as new ideas will present themselves, and others will become self-evident.',
              textAlign: TextAlign.justify,
              textScaleFactor: 1.2
            ),
            Spacer(),
            Text(
              'First published 1975',
              textWidthBasis: TextWidthBasis.longestLine,
              textAlign: TextAlign.center,
              textScaleFactor: 1.4
            ),
            Spacer(),
          ]
        )
      )
    ));
  }
}