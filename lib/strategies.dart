import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import "cards.dart";

Cards card = Cards();

class Strategies {
  int get length {
    // single hardcoded value for now since 5e+ is the only deck atm
    return 122;
  }

  Map<String, dynamic> buildCard(int index, BuildContext? context) {
    bool hasContext = context is BuildContext;
    String cardText = hasContext ? context.tr('card$index') : 'card$index'.tr();

    if (index < 4) {
      List<String> options = [];
      int numOptions = optionsStrategyData5e[index]['numOptions'] as int;
      double optionPadding = optionsStrategyData5e[index]['optionPadding'] as double;

      for (int i = 0; i < numOptions; ++i) {
        final optionText = hasContext ? context.tr('card${index}Option$i') : 'card${index}Option$i'.tr();

        options.add(optionText);
      }

      if (index < 3) {
        return card.options(cardText, options, optionPadding);
      }
      
      return card.multiple(cardText, options, optionPadding);
    }

    if (index < 8) {
      String contributorName = hasContext ? context.tr('card${index}Contributor') : 'card${index}Contributor'.tr();
      String contributorText = hasContext ? context.tr('contributedBy', args: [ contributorName ]) : 'contributedBy'.tr(args: [ contributorName ]);
      return card.attribution(cardText, contributorText);
    }
    
    return card.basic(cardText);
  }

  final optionsStrategyData5e = [
    { "numOptions": 2, "optionPadding": 95 },
    { "numOptions": 2, "optionPadding": 95 },
    { "numOptions": 3, "optionPadding": 125 },
    { "numOptions": 2, "optionPadding": 30 },
  ];
}
