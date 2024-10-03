import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../cards.dart';
import 'package:easy_localization/easy_localization.dart';

class TitleCard extends StatelessWidget {
  const TitleCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Cards card = Cards();
    AppState appState = context.watch<AppState>();

    final authors = context.tr('authors');
    final eno = context.tr('brianEno');
    final schmidt = context.tr('peterSchmidt');
  
    List<String> authorsArr = authors.split(eno);
    authorsArr.insert(1, eno.toUpperCase());
    
    final schmidtIndex = authorsArr.indexWhere((str) => str.contains(schmidt));
    final authorsArr2 = authorsArr[schmidtIndex].split(schmidt);
    authorsArr2.insert(1, schmidt.toUpperCase());
    authorsArr.replaceRange(schmidtIndex, schmidtIndex + 1, authorsArr2);

    authorsArr = authorsArr.map((str) => str.trim()).where((str) => str != "").toList();
    
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                context.tr('title.toUpperCase()'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)
              ),
            ),
            Text(
              context.tr('subtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21)
            ),
            const Spacer(),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.horizontal,
              spacing: 5,
              children: authorsArr.map((str) => Text(
                str,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21)
              )).toList()
            ),
            const Spacer(),
            Text(
              context.tr('fifthEdition'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)
            ),
            Text(
              context.tr('fifthEdition2'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)
            ),
            Text(
              context.tr('digitizedBy'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)
            ),
            const Spacer(),
          ]
        )
      )
    ));
  }
}
