import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'strategy_card.dart';
import 'favorite_icon.dart';
import 'settings_icon.dart';
import 'settings_card.dart';

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
  bool settingsOpen = false;
  bool iconsVisible = false;
  Timer? iconFadeoutTimer;

  void setCurrentFavorite(bool favorite) {
    currentIsFavorite = favorite;
    notifyListeners();
  }

  void setSettingsOpen(bool isOpen) {
    settingsOpen = isOpen;
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
  @override
  Widget build(BuildContext context) {
    IconState iconState = IconState();

    FlipCardController flipController = FlipCardController();

    return Listener(
      onPointerHover: (pointerHoverEvent) => iconState.setIconsVisible(),
      child: GestureDetector(
        onTap: () => iconState.setIconsVisible(),
        child: Stack(
          children: [
            Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints.loose(const Size(750, 500)),
                  child: FlipCard(
                    onFlipDone: (isFront) => iconState.setSettingsOpen(isFront),
                    flipOnTouch: false,
                    direction: FlipDirection.VERTICAL,
                    controller: flipController,
                    front: StrategyCard(iconState: iconState),
                    back: settingsCard
                  ),
                ),
              ),
            ),
            FavoriteIcon(iconState: iconState),
            SettingsIcon(iconState: iconState, flipController: flipController),
          ]
        ),
      ),
    );
  }
}
