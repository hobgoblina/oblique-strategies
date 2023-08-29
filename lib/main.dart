import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
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
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {

}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(const Size(750, 500)),
          child: CardSwiper(
            cardsCount: cards.length,
            backCardOffset: const Offset(0, 0),
            cardBuilder: (context, index, percentThresholdX, percentThresholdY) => cards[index],
          )
        ),
      ),
    );
  }
}
