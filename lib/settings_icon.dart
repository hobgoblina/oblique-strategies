import 'package:flip_card/flip_card_controller.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class SettingsIcon extends StatelessWidget {
  const SettingsIcon({
    super.key,
    required this.iconState,
    required this.flipController,
  });

  final IconState iconState;
  final FlipCardController flipController;

  void onPressed() {
    flipController.toggleCard();
    iconState.setIconsVisible();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: iconState,
      builder: (context, child) => AnimatedOpacity(
        opacity: iconState.iconsVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: onPressed,
            tooltip: '${iconState.settingsOpen ? 'Close' : 'Open'} settings',
            icon: Icon(
              iconState.settingsOpen ? Ionicons.close_outline : Ionicons.options_outline,
              semanticLabel: '${iconState.settingsOpen ? 'Close' : 'Open'} settings',
              color: Colors.white,
              size: 40
            ),
          ),
        ),
      ),
    );
  }
}