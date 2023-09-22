import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Oblique Strategies',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            background: const Color.fromRGBO(25, 25, 25, 1)
          ),
          checkboxTheme: CheckboxThemeData(
            splashRadius: 0,
            shape: const RoundedRectangleBorder(),
            checkColor: MaterialStateProperty.all(Colors.black),
            side: MaterialStateBorderSide.resolveWith(
              (states) => const BorderSide(strokeAlign: -.1, width: 1.75, color: Colors.black),
            ),
            fillColor: MaterialStateColor.resolveWith(
              (states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey;
                }
                return Colors.white;
              },
            ),
          ),
          textTheme: GoogleFonts.interTextTheme()
        ),
        home: MainPage(),
      )
    );
  }
}

class AppState extends ChangeNotifier {
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

  void rebuildApp() {
    notifyListeners();
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    AppState appState = context.watch<AppState>();
    FlipCardController flipController = FlipCardController();

    return Listener(
      onPointerHover: (pointerHoverEvent) => appState.setIconsVisible(),
      child: GestureDetector(
        onTap: () => appState.setIconsVisible(),
        child: Stack(
          children: [
            Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints.loose(const Size(750, 500)),
                  child: FlipCard(
                    speed: storage.read('reduceAnimations') ?? false ? 0 : 1000,
                    onFlipDone: (isFront) => appState.setSettingsOpen(isFront),
                    flipOnTouch: false,
                    direction: FlipDirection.VERTICAL,
                    controller: flipController,
                    front: const StrategyCard(),
                    back: const SettingsCard()
                  ),
                ),
              ),
            ),
            const FavoriteIcon(),
            SettingsIcon(flipController: flipController),
          ]
        ),
      ),
    );
  }
}
