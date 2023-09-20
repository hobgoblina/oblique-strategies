import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'strategy_card.dart';
import 'package:ionicons/ionicons.dart';

void main() async {
  await GetStorage.init();
  runApp(const StrategiesApp());
}

class StrategiesApp extends StatelessWidget {
  const StrategiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return MaterialApp(
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
    );
  }
}

class IconState extends ChangeNotifier {
  bool? currentIsFavorite;
  bool iconsVisible = false;
  Timer? iconFadeoutTimer;

  void setCurrentFavorite(bool favorite) {
    currentIsFavorite = favorite;
    notifyListeners();
  }

  void setIconsVisible() {
    if (!iconsVisible) {
      iconsVisible = true;
      notifyListeners();
    }

    iconFadeoutTimer?.cancel();
    iconFadeoutTimer = Timer(const Duration(seconds: 3), () {
      iconsVisible = false;
      notifyListeners();
    });
  }
}

class MainPage extends StatelessWidget {
  final storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    IconState iconState = IconState();

    void addToFavorites() {
      int? index = storage.read('currentIndex');

      if (index is int) {
        final List<dynamic> strategyData = storage.read('strategyData');
        final int dataToUpdate = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == index);
        final bool favorite = !strategyData[dataToUpdate]['favorite'];
        strategyData[dataToUpdate]['favorite'] = favorite;
        storage.write('strategyData', strategyData);
        iconState.setCurrentFavorite(favorite);
        iconState.setIconsVisible();
      }
    }

    if (iconState.currentIsFavorite == null) {
      int? index = storage.read('currentIndex');
      if (storage.read('currentIndex') is int) {
        List<dynamic> strategyData = storage.read('strategyData');
        final int currentIndex = strategyData.indexWhere((card) => card['lastDrawnAtIndex'] == index);
        iconState.currentIsFavorite = strategyData[currentIndex]['favorite'];
      } else {
        iconState.currentIsFavorite = false;
      }
    }

    return Listener(
      onPointerHover: (pointerHoverEvent) => iconState.setIconsVisible(),
      child: GestureDetector(
        onTap: () => iconState.setIconsVisible(),
        child: Stack(
          children: [
            StrategyCard(iconState: iconState),
            ListenableBuilder(
              listenable: iconState,
              builder: (context, child) => AnimatedOpacity(
                opacity: iconState.iconsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: addToFavorites,
                    tooltip: 'Add to favorites',
                    icon: Icon(
                      Ionicons.heart_outline,
                      semanticLabel: 'Add to favorites',
                      color: (iconState.currentIsFavorite ?? false) ? Colors.red : Colors.white,
                      size: 40
                    ),
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}
