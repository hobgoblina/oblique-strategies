import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class SettingsIcon extends StatelessWidget {
  const SettingsIcon({ super.key });

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final storage = GetStorage();

    void onPressed() {
      appState.flipController.toggleCard();
      appState.setIconsVisible();
    }

    return AnimatedOpacity(
      opacity: appState.iconsVisible || appState.settingsOpen ? 1.0 : 0.0,
      duration: storage.read('reduceAnimations') ?? false ? Duration.zero : const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(11),
        alignment: Alignment.topLeft,
        child: IconButton(
          hoverColor: const Color.fromRGBO(25, 25, 25, 1),
          focusColor: const Color.fromRGBO(25, 25, 25, 1),
          onPressed: onPressed,
          tooltip: '${appState.settingsOpen ? 'Close' : 'Open'} settings',
          icon: Icon(
            appState.settingsOpen ? Ionicons.close_outline : Ionicons.options_outline,
            semanticLabel: '${appState.settingsOpen ? 'Close' : 'Open'} settings',
            color: Colors.white,
            size: 35
          ),
        ),
      ),
    );
  }
}