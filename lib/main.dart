import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:workmanager/workmanager.dart';

import 'strategy_card.dart';
import 'favorite_icon.dart';
import 'settings_icon.dart';
import 'settings_card.dart';
import 'info_cards.dart';
import 'notifications_card.dart';
import 'notifications.dart';

void main() async {
  await GetStorage.init();

  if (!kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    Workmanager().initialize(notificationDispatcher);
    Workmanager().registerPeriodicTask('scheduleNotifications', 'scheduleNotifications');

    final notificationAppLaunchDetails = await LocalNotificationService().notificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      GetStorage().write('currentIndex', notificationAppLaunchDetails?.notificationResponse?.id);
    }
  }

  runApp(const StrategiesApp());
}

class StrategiesApp extends StatelessWidget {
  const StrategiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color.fromRGBO(15, 15, 15, 1);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: backgroundColor,
      systemNavigationBarColor: backgroundColor
    ));

    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Oblique Strategies',
        theme: ThemeData(
          fontFamily: 'Univers',
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
            entryModeIconColor: Colors.black,
            hourMinuteColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? const Color.fromRGBO(235, 235, 235, 1) : Colors.white),
            hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.black, width: 1.5)),
            dayPeriodBorderSide: const BorderSide(color: Colors.black, width: 1.5),
            dayPeriodColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.black : Colors.white),
            dayPeriodTextColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.white : Colors.black),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              errorStyle: TextStyle(height: 0),
              contentPadding: EdgeInsets.zero,
              outlineBorder: BorderSide(color: Colors.black, width: 1.5),
              activeIndicatorBorder: BorderSide(color: Colors.black, width: 1.5),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.black, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.black, width: 1.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.black, width: 1.5),
              )
            ),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            selectionHandleColor: Colors.transparent,
            selectionColor: Colors.black12,
            cursorColor: Colors.black
          ),
          checkboxTheme: CheckboxThemeData(
            splashRadius: 17,
            shape: const RoundedRectangleBorder(),
            checkColor: MaterialStateProperty.all(Colors.black),
            overlayColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.focused) ? Colors.black12 : Colors.transparent),
            side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(strokeAlign: -.1, width: 1.75, color: Colors.black)),
            fillColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.disabled) ? Colors.grey : Colors.white),
          ),
          tooltipTheme: const TooltipThemeData(
            textStyle: TextStyle(color: Colors.white),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              textStyle: MaterialStateProperty.resolveWith((states) => const TextStyle(fontSize: 20, fontFamily: 'Univers')),
              foregroundColor: MaterialStateProperty.resolveWith((states) => Colors.black),
              backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
              overlayColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.hovered) || states.contains(MaterialState.focused)) {
                  return Colors.black12;
                }

                return Colors.transparent;
              })
            )
          ),
        ),
        home: MainPage(),
      )
    );
  }
}

class AppState extends ChangeNotifier {
  bool? currentIsFavorite;
  String cardFace = 'strategies';
  bool iconsVisible = false;
  bool titleCardsSeen = false;
  Timer? iconFadeoutTimer;

  // Keeping track of all drawn cards in this session
  // When favorites-only setting is applied there's more potential for
  // Cards to be redrawn in the same session, impacting ability to undo swipes
  Map<int, int> drawnCards = {};
  
  final FlipCardController flipController = FlipCardController();
  final CardSwiperController swipeController = CardSwiperController();

  void setCurrentFavorite(bool favorite) {
    currentIsFavorite = favorite;
    notifyListeners();
  }

  void setTitleCardsSeen(bool seen) {
    titleCardsSeen = seen;
    notifyListeners();
  }

  void setCardFrontAndFlip(String cardType) {
    cardFace = cardType;
    notifyListeners();
    flipController.toggleCard();
  }

  void setIconsVisible() {
    if (!iconsVisible) {
      iconsVisible = true;
      notifyListeners();
    }

    iconFadeoutTimer?.cancel();
    iconFadeoutTimer = Timer(const Duration(milliseconds: 3500), () {
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
    Widget frontCard = const StrategyCard();

    if (storage.read('immersiveMode') ?? false) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom
      ]);
    }

    if (appState.cardFace == 'about') {
      frontCard = const InfoCards();
    } else if (appState.cardFace == 'notifications') {
      frontCard = const NotificationsCard();
    } else if (appState.cardFace == 'settings') {
      frontCard = Container();
    }

    bool canPop() {
      if (kIsWeb) {
        return true;
      } else if (appState.cardFace == 'strategies') {
        appState.swipeController.undo();
      } else {
        if (appState.cardFace == 'settings') {
          appState.setCardFrontAndFlip('strategies');
        } else {
          appState.flipController.toggleCard();
        }
      }

      return false;
    }

    void onFlipDone(isFlipped) {
      if (isFlipped) {
        appState.cardFace = 'settings';
        appState.rebuildApp();
      }
    }

    KeyEventResult handleKeyPress(FocusNode node, KeyEvent event) {
      if (appState.cardFace != 'strategies' && appState.cardFace != 'about') {
        return KeyEventResult.ignored;
      }

      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          appState.swipeController.swipeLeft();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          appState.swipeController.swipeTop();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          appState.swipeController.swipeRight();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          appState.swipeController.swipeBottom();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
          appState.swipeController.undo();
          return KeyEventResult.handled;
        }
      }

      return KeyEventResult.ignored;
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool needsIconSpace = screenWidth < 850 && screenHeight < 640;

    return Focus(
      autofocus: false,
      canRequestFocus: false,
      skipTraversal: false,
      onKeyEvent: handleKeyPress,
      child: WillPopScope(
        onWillPop: () async => canPop(),
        child: MouseRegion(
          onHover: (pointerHoverEventListener) => kIsWeb ? appState.setIconsVisible() : null,
          child: GestureDetector(
            onTapUp: (tapUpDetails) => appState.setIconsVisible(),
            child: Stack(
              children: [
                Scaffold(
                  appBar: needsIconSpace ? PreferredSize(
                    preferredSize: Size.lerp(
                      Size(screenWidth, screenHeight < 590 ? 40 : (1 - (screenHeight - 590) / 50) * 40),
                      Size(screenWidth, 0),
                      screenWidth < 770 ? 0 : (screenWidth - 770) / 80,
                    ) ?? Size.zero,
                    child: Container(),
                  ) : null,
                  body: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints.loose(const Size(770, 550)),
                      child: FlipCard(
                        speed: storage.read('reduceAnimations') ?? false ? 0 : 1000,
                        onFlipDone: onFlipDone,
                        flipOnTouch: false,
                        direction: FlipDirection.VERTICAL,
                        controller: appState.flipController,
                        front: frontCard,
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
      ),
    );
  }
}
