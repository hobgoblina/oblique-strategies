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

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool tinyScreen = screenWidth < 700 || screenHeight < 500;

    return card.cardWrapper((paddingInterp) => Container(
      alignment: Alignment.center,
      color: Colors.white,
      padding: EdgeInsetsTween(
        begin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), 
        end: const EdgeInsets.symmetric(horizontal: 90, vertical: 15)
      ).lerp(paddingInterp),
      child: FocusTraversalGroup(
        descendantsAreFocusable: appState.cardFace == 'about',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'OBLIQUE STRATEGIES',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)
            ),
            const Spacer(),
            Text(
              'These cards evolved from our separate observations of the principles underlying what we were doing. Sometimes they were recognized in retrospect (intellect catching up with intuition), sometimes they were identified as they were happening, sometimes they were formulated.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: tinyScreen ? 18 : 17)
            ),
            Visibility(
              visible: !tinyScreen,
              child: const Text(
                'They can be used as a pack (a set of possibilities being continuously reviewed in the mind) or by drawing a single card from the shuffled pack when a dilemma occurs in a working situation. In this case the card is trusted even if its appropriateness is quite unclear. They are not final, as new ideas will present themselves, and others will become self-evident.',
                textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 17)
              ),
            ),
            const Spacer(),
            const Text(
              'First published 1975',
              textWidthBasis: TextWidthBasis.longestLine,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17)
            ),
            const Spacer(),
          ]
        )
      )
    ));
  }
}

class AboutCard2 extends StatelessWidget {
  const AboutCard2({
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
        end: const EdgeInsets.symmetric(horizontal: 90, vertical: 15)
      ).lerp(paddingInterp),
      child: FocusTraversalGroup(
        descendantsAreFocusable: appState.cardFace == 'about',
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'OBLIQUE STRATEGIES',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)
            ),
            Spacer(),
            Text(
              'They can be used as a pack (a set of possibilities being continuously reviewed in the mind) or by drawing a single card from the shuffled pack when a dilemma occurs in a working situation. In this case the card is trusted even if its appropriateness is quite unclear. They are not final, as new ideas will present themselves, and others will become self-evident.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 17)
            ),
            Spacer(),
            Spacer(),
          ]
        )
      )
    ));
  }
}
