import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
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
    const Color backgroundColor = Color.fromRGBO(16, 16, 16, 1);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: backgroundColor,
      systemNavigationBarColor: backgroundColor
    ));

    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Oblique Strategies',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: backgroundColor,
            background: backgroundColor
          ),
          checkboxTheme: CheckboxThemeData(
            splashRadius: 17,
            shape: const RoundedRectangleBorder(),
            checkColor: MaterialStateProperty.all(Colors.black),
            overlayColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.focused)) {
                return Colors.black12;
              }
              return Colors.transparent;
            }),
            side: MaterialStateBorderSide.resolveWith(
              (states) => const BorderSide(strokeAlign: -.1, width: 1.75, color: Colors.black),
            ),
            fillColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey;
              }
              return Colors.white;
            }),
          ),
          tooltipTheme: const TooltipThemeData(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.all(Radius.circular(10))
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
  
  final FlipCardController flipController = FlipCardController();
  final CardSwiperController swipeController = CardSwiperController();

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

    bool onWillPop() {
      if (!appState.settingsOpen) {
        appState.swipeController.undo();
      } else {
        appState.flipController.toggleCard();
      }

      return false;
    }

    return WillPopScope(
      onWillPop: () async => onWillPop(),
      child: Listener(
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
                      controller: appState.flipController,
                      front: const StrategyCard(),
                      back: const SettingsCard()
                    ),
                  ),
                ),
              ),
              const FavoriteIcon(),
              const SettingsIcon(),
            ]
          ),
        ),
      ),
    );
  }
}
