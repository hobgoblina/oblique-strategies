import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class SettingsIcon extends StatelessWidget {
  const SettingsIcon({
    super.key,
    required this.iconState,
  });

  final IconState iconState;

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
            onPressed: iconState.toggleSettingsOpen,
            tooltip: '${iconState.settingsOpen ? 'Close' : 'Open'} settings',
            icon: Icon(
              Ionicons.options_outline,
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