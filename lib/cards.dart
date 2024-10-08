import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Cards {
  Container cardWrapper(Function cardBuilder) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color.fromRGBO(15, 15, 15, 1)
        )
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: LayoutBuilder(builder: (context, constraints) {
          double paddingInterp;
    
          if (constraints.maxWidth >= 750) {
            paddingInterp = 1;
          } else if (constraints.maxWidth <= 400) {
            paddingInterp = 0;
          } else {
            paddingInterp = (constraints.maxWidth - 400) / 350;
          }
          
          return cardBuilder(paddingInterp);
        }),
      ),
    );
  }

  Map<String, dynamic> basic(String cardText) {
    return {
      'text': cardText,
      'card': cardWrapper((paddingInterp) => Container(
        alignment: Alignment.center,
        color: Colors.white,
        padding: EdgeInsetsTween(
          begin: const EdgeInsets.all(20), 
          end: const EdgeInsets.all(75)
        ).lerp(paddingInterp),
        child: Text(
          cardText,
          textWidthBasis: TextWidthBasis.longestLine,
          style: const TextStyle(fontSize: 23)
        ),
      )),
    };
  }

  Map<String, dynamic> attribution(String cardText, String contributorText) {
    return {
      'text': cardText,
      'card': cardWrapper((paddingInterp) => Container(
        color: Colors.white,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsetsTween(
                begin: const EdgeInsets.all(20), 
                end: const EdgeInsets.all(75)
              ).lerp(paddingInterp),
              child: Text(
                cardText,
                textWidthBasis: TextWidthBasis.longestLine,
                style: const TextStyle(fontSize: 23)
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.only(bottom: 20, right: 27),
              child: Text(contributorText),
            ),
          ],
        ),
      )),
    };
  }

  Map<String, dynamic> multiple(String cardText, List<String> options, double optionPadding) {
    String text = cardText;
    for (int i = 0; i < options.length; ++i) {
      text += '\n • ${options[i]}';
    }
    
    return {
      'text': text,
      'card': cardWrapper((paddingInterp) => Container(
        alignment: Alignment.center,
        padding: EdgeInsetsTween(
          begin: const EdgeInsets.all(20), 
          end: const EdgeInsets.all(75)
        ).lerp(paddingInterp),
        color: Colors.white,
        child: Wrap(
          direction: Axis.horizontal,
          children: [
            Text(
              cardText,
              style: const TextStyle(fontSize: 23),
              textWidthBasis: TextWidthBasis.longestLine,
            ),
            Padding(
              padding: EdgeInsets.only(left: optionPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options.map((option) => Text(
                  option,
                  style: const TextStyle(fontSize: 23),
                  textWidthBasis: TextWidthBasis.longestLine,
                )).toList(),
              ),
            )
          ],
        ),
      )),
    };
  }

  Map<String, dynamic> options(String cardText, List<String> options, double optionPadding) {
    String text = cardText;
    for (int i = 0; i < options.length; ++i) {
      text += '\n • ${options[i]}';
    }

    return {
      'text': text,
      'card': cardWrapper((paddingInterp) => Container(
        alignment: Alignment.center,
        padding: EdgeInsetsTween(
          begin: const EdgeInsets.all(20), 
          end: const EdgeInsets.all(75)
        ).lerp(paddingInterp),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cardText,
              style: const TextStyle(fontSize: 23),
              textWidthBasis: TextWidthBasis.longestLine,
            ),
            Padding(
              padding: EdgeInsetsTween(
                begin: const EdgeInsets.only(left: 20), 
                end: EdgeInsets.only(left: optionPadding)
              ).lerp(paddingInterp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options.map((option) => Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text(
                        '•',
                        style: TextStyle(fontSize: 23),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 23),
                        textWidthBasis: TextWidthBasis.longestLine,
                      ),
                    ),
                  ],
                )).toList(),
              ),
            )
          ],
        ),
      ))
    };
  }
}
