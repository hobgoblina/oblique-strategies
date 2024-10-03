import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../main.dart';
import '../cards.dart';
import 'package:easy_localization/easy_localization.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              context.tr('instructionsTitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)
            ),
            const Spacer(),
            Text(
              context.tr('instructionsSwipe'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21)
            ),
            const Spacer(),
            Visibility(
              visible: kIsWeb,
              child: Text(
                context.tr('instructionsSwipe2'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21)
              ),
            ),
            const Visibility(visible: kIsWeb, child: Spacer()),
            Text(
              kIsWeb 
                ? context.tr('instructionsUndoWeb')
                : context.tr('instructionsUndo'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21)
            ),
            const Spacer(),
            const Spacer(),
          ]
        )
      )
    ));
  }
}
