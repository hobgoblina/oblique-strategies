import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../cards.dart';
import 'package:easy_localization/easy_localization.dart';

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
            Text(
              context.tr('title.toUpperCase()'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)
            ),
            const Spacer(),
            Text(
              context.tr('aboutCard1'),
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: tinyScreen ? 18 : 17)
            ),
            Visibility(
              visible: !tinyScreen,
              child: Text(
                context.tr('aboutCard2'),
                textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 17)
              ),
            ),
            const Spacer(),
            Text(
              context.tr('firstPublished'),
              textWidthBasis: TextWidthBasis.longestLine,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17)
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              context.tr('title.toUpperCase()'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)
            ),
            const Spacer(),
            Text(
              context.tr('aboutCard2'),
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 17)
            ),
            const Spacer(),
            const Spacer(),
          ]
        )
      )
    ));
  }
}
