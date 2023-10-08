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
          descendantsAreFocusable: appState.settingsOpen && appState.currentCardFront == 'about',
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'OBLIQUE STRATEGIES',
                  textWidthBasis: TextWidthBasis.longestLine,
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.6,
                  style: TextStyle(fontWeight: FontWeight.bold)
                ),
              ),
              Text(
                'Over one hundred worthwhile dilemmas',
                textWidthBasis: TextWidthBasis.longestLine,
                textAlign: TextAlign.center,
                textScaleFactor: 1.5
              ),
              Spacer(),
              Text(
                'BRIAN ENO and PETER SCHMIDT',
                textWidthBasis: TextWidthBasis.longestLine,
                textAlign: TextAlign.center,
                textScaleFactor: 1.5
              ),
              Spacer(),
              Text(
                'Fifth, again slightly revised edition, 2001',
                textWidthBasis: TextWidthBasis.longestLine,
                textAlign: TextAlign.center,
                textScaleFactor: 1.1
              ),
              Text(
                'Plus a selection from earlier editions',
                textWidthBasis: TextWidthBasis.longestLine,
                textAlign: TextAlign.center,
                textScaleFactor: 1.1
              ),
              Text(
                'Digitized by Lina, 2023',
                textWidthBasis: TextWidthBasis.longestLine,
                textAlign: TextAlign.center,
                textScaleFactor: 1.1
              ),
              Spacer(),
              Spacer(),
            ]
          )
        )
      ))
    );
  }
}