import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'main.dart';
import 'cards.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({ super.key });

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();
    final Cards card = Cards();
    final storage = GetStorage();

    const Duration? tooltipDuration = kIsWeb ? null : Duration(milliseconds: 5000);

    final String quietStart = storage.read('quietHoursStart') ?? '23:00';
    final String quietEnd = storage.read('quietHoursEnd') ?? '11:00';
    final TimeOfDay quietHoursStart = TimeOfDay(
      hour: int.parse(quietStart.split(':')[0]),
      minute: int.parse(quietStart.split(':')[1]),
    );
    final TimeOfDay quietHoursEnd = TimeOfDay(
      hour: int.parse(quietEnd.split(':')[0]),
      minute: int.parse(quietEnd.split(':')[1]),
    );

    void onQuietHoursPressed(String startOrEnd) async {
      TimeOfDay? newTime = await showTimePicker(
        useRootNavigator: false,
        hourLabelText: '',
        minuteLabelText: '',
        confirmText: 'Confirm',
        helpText: '',
        initialTime: startOrEnd == 'start' ? quietHoursStart : quietHoursEnd,
        context: context,
      );

      if (newTime is TimeOfDay) {
        final timeString = '${newTime.hour}:${newTime.minute}';
        storage.write(startOrEnd == 'start' ? 'quietHoursStart' : 'quietHoursEnd', timeString);
        appState.rebuildApp();
      }
    }

    Widget settingsItem({
      String? tooltip,
      required String text,
      EdgeInsets padding = const EdgeInsets.only(bottom: 40),
      required Widget child
    }) {
      return Padding(
        padding: padding,
        child: Row(
          children: [
            tooltip is String ? Expanded(
              child: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                showDuration: tooltipDuration,
                message: tooltip,
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Ionicons.information_circle_outline,
                        color: Colors.black,
                        size: 25
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: GoogleFonts.inter(),
                        textScaleFactor: 1.5
                      ),
                    ),
                  ],
                ),
              ),
            ) : Expanded(
              child: Text(
                text,
                textWidthBasis: TextWidthBasis.longestLine,
                style: GoogleFonts.inter(),
                textScaleFactor: 1.5
              ),
            ),
            child
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 25, left: 20, right: 20),
      child: card.cardWrapper((paddingInterp) => Container(
        alignment: Alignment.center,
        color: Colors.white,
        padding: EdgeInsetsTween(
          begin: const EdgeInsets.all(15), 
          end: const EdgeInsets.all(75)
        ).lerp(paddingInterp),
        child: FocusTraversalGroup(
          descendantsAreFocusable: appState.settingsOpen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              settingsItem(
                tooltip: 'A reload may be required for certain animation changes to take effect.',
                text: 'Reduce animations',
                child: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    autofocus: true,
                    value: storage.read('reduceAnimations') ?? false,
                    semanticLabel: 'Reduce animations',
                    onChanged: (val) {
                      if (val is bool) {
                        storage.write('reduceAnimations', val);
                        appState.rebuildApp();
                      }
                    }
                  ),
                )
              ),
              settingsItem(
                tooltip: 'Allows favorited cards to be redrawn anytime. It usually takes a while before a card can be redrawn.',
                text: 'Keep favorites in the deck',
                child: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: storage.read('canAlwaysRedrawFavorites') ?? true,
                    semanticLabel: 'Allows favorited cards to be redrawn anytime. It usually takes a while before a card can be redrawn.',
                    onChanged: (val) {
                      if (val is bool) {
                        storage.write('canAlwaysRedrawFavorites', val);
                        appState.rebuildApp();
                      }
                    }
                  ),
                )
              ),
              settingsItem(
                tooltip: 'Notifications will not occur between these times.',
                text: 'Quiet hours',
                padding: EdgeInsets.zero, 
                child: TextButton(
                  onPressed: () => onQuietHoursPressed('start'),
                  child: const Text('Time input'),
                )
              ),
            ],
          ),
        ),
      )),
    );
  }
}