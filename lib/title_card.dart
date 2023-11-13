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
        descendantsAreFocusable: appState.cardFace == 'about',
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'OBLIQUE STRATEGIES',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)
              ),
            ),
            Text(
              'Over one hundred worthwhile dilemmas',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21)
            ),
            Spacer(),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.horizontal,
              spacing: 5,
              children: [
                Text(
                  'BRIAN ENO',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21)
                ),
                Text(
                  'and',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21)
                ),
                Text(
                  'PETER SCHMIDT',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21)
                ),
              ],
            ),
            Spacer(),
            Text(
              'Fifth, again slightly revised edition, 2001',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16)
            ),
            Text(
              'Plus a selection from earlier editions',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16)
            ),
            Text(
              'Digitized by Lina, 2023',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16)
            ),
            Spacer(),
          ]
        )
      )
    ));
  }
}
