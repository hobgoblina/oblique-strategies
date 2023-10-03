import 'dart:async';
import 'package:flutter/foundation.dart';
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
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Colors.white,
            onPrimary: Colors.black,
            secondary: Colors.black12,
            onSecondary: Colors.black,
            error: Color.fromRGBO(200, 32, 20, 1),
            onError: Colors.white,
            background: backgroundColor,
            onBackground: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
            outline: Colors.black
          ),
          timePickerTheme: TimePickerThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            dialBackgroundColor: const Color.fromRGBO(235, 235, 235, 1),
            dialHandColor: Colors.black,
            dialTextColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.white : Colors.black),
            dialTextStyle: GoogleFonts.inter(fontSize: 20),
            entryModeIconColor: Colors.black,
            hourMinuteColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? const Color.fromRGBO(235, 235, 235, 1) : Colors.white),
            hourMinuteShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.black, width: 1.5)
            ),
            dayPeriodBorderSide: const BorderSide(color: Colors.black, width: 1.5),
            dayPeriodColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.black : Colors.white),
            dayPeriodTextColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.white : Colors.black),
            confirmButtonStyle: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.black),
              textStyle: MaterialStateProperty.resolveWith((states) => GoogleFonts.inter(color: Colors.black)),
              overlayColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.hovered) || states.contains(MaterialState.focused)) {
                  return Colors.black12;
                } else if (states.contains(MaterialState.pressed)) {
                  return Colors.black26;
                }

                return Colors.transparent;
              })
            )
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
          tooltipTheme: TooltipThemeData(
            textStyle: GoogleFonts.inter(color: Colors.white),
            decoration: const BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              textStyle: MaterialStateProperty.resolveWith((states) => GoogleFonts.inter(fontSize: 20)),
              foregroundColor: MaterialStateProperty.resolveWith((states) => Colors.black),
              backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
              overlayColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.hovered) || states.contains(MaterialState.focused)) {
                  return Colors.black12;
                } else if (states.contains(MaterialState.pressed)) {
                  return Colors.black26;
                }

                return Colors.transparent;
              })
            )
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
      child: MouseRegion(
        onHover: (pointerHoverEventListener) => kIsWeb ? appState.setIconsVisible() : null,
        child: GestureDetector(
          onTapUp: (tapUpDetails) => appState.setIconsVisible(),
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
