import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({ super.key });

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final storage = GetStorage();

    void onPressed() {
      if (appState.cardFace == 'settings') {
        appState.setCardFrontAndFlip('strategies');
      } else {
        appState.flipController.toggleCard();
      }
      
      appState.setIconsVisible();
    }

    IoniconsData icon = appState.cardFace == 'settings' ? Ionicons.close_outline : Ionicons.options_outline;
    String iconLabel = appState.cardFace == 'settings'
      ? context.tr('closeSettings')
      : context.tr('openSettings');

    if (appState.cardFace != 'settings' && appState.cardFace != 'strategies') {
      icon = Ionicons.arrow_back_outline;
      iconLabel = context.tr('returnToSettings');
    }

    return AnimatedOpacity(
      opacity: appState.iconsVisible
        || (storage.read('alwaysShowControls') ?? true)
        || appState.cardFace != 'strategies' ? 1.0 : 0.0,
      duration: storage.read('reduceAnimations') ?? false ? Duration.zero : const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(11),
        alignment: Alignment.topLeft,
        child: IconButton(
          hoverColor: const Color.fromRGBO(25, 25, 25, 1),
          focusColor: const Color.fromRGBO(25, 25, 25, 1),
          onPressed: onPressed,
          tooltip: iconLabel,
          icon: Icon(
            icon,
            semanticLabel: iconLabel,
            color: Colors.white,
            size: 35
          ),
        ),
      ),
    );
  }
}
