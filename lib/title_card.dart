import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'cards.dart';

class TitleCard extends StatelessWidget {
  const TitleCard({
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
        descendantsAreFocusable: appState.settingsOpen && appState.currentCardFront == 'about',
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'OBLIQUE STRATEGIES',
                textAlign: TextAlign.center,
                textScaleFactor: 1.6,
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
            ),
            Text(
              'Over one hundred worthwhile dilemmas',
              textAlign: TextAlign.center,
              textScaleFactor: 1.5
            ),
            Spacer(),
            Text(
              'BRIAN ENO and PETER SCHMIDT',
              textAlign: TextAlign.center,
              textScaleFactor: 1.5
            ),
            Spacer(),
            Text(
              'Fifth, again slightly revised edition, 2001',
              textAlign: TextAlign.center,
              textScaleFactor: 1.1
            ),
            Text(
              'Plus a selection from earlier editions',
              textAlign: TextAlign.center,
              textScaleFactor: 1.1
            ),
            Text(
              'Digitized by Lina, 2023',
              textAlign: TextAlign.center,
              textScaleFactor: 1.1
            ),
            Spacer(),
          ]
        )
      )
    ));
  }
}