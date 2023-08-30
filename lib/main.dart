import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'dart:math';
import './cards.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Oblique Strategies',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.grey,
            background: const Color.fromRGBO(25, 25, 25, 1)
          ),
          textTheme: GoogleFonts.interTextTheme()
        ),
        home: HomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {

}

class HomePage extends StatelessWidget {
  final CardSwiperController controller = CardSwiperController();

  // Might need this for a stateful app
  // @override
  // void dispose() {
  //   controller.dispose();
  //   super.dispose();
  // }

  KeyEventResult handleKeyPress(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        var rand = Random().nextInt(4);

        if (rand == 0) {
          controller.swipeLeft();
        } else if (rand == 1) {
          controller.swipeTop();
        } else if (rand == 2) {
          controller.swipeRight();
        } else if (rand == 3) {
          controller.swipeBottom();
        }

        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        controller.swipeLeft();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        controller.swipeTop();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        controller.swipeRight();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        controller.swipeBottom();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        controller.undo();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {   
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(const Size(750, 500)),
          child: Focus(
            autofocus: true,
            canRequestFocus: true,
            onKey: handleKeyPress,
            child: CardSwiper(
              controller: controller,
              cardsCount: cards.length,
              backCardOffset: const Offset(0, 0),
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) => cards[index],
            ),
          )
        ),
      ),
    );
  }
}
