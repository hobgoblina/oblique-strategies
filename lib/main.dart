import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'strategy_card.dart';

void main() async {
  await GetStorage.init();
  runApp(const StrategiesApp());
}

class StrategiesApp extends StatelessWidget {
  const StrategiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StrategiesAppState(),
      child: MaterialApp(
        title: 'Oblique Strategies',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            background: const Color.fromRGBO(25, 25, 25, 1)
          ),
          textTheme: GoogleFonts.interTextTheme()
        ),
        home: MainPage(),
      ),
    );
  }
}

class StrategiesAppState extends ChangeNotifier {

}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {   
    return const Stack(
      children: [
        StrategyCard(),
      ]
    );
  }
}
