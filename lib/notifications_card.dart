import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'main.dart';
import 'cards.dart';
import 'settings_card.dart';

class NotificationsCard extends StatelessWidget {
  const NotificationsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Cards card = Cards();
    AppState appState = context.watch<AppState>();
    final storage = GetStorage();

    final bool is24HoursFormat = MediaQuery.of(context).alwaysUse24HourFormat;
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

    void onQuietHoursPressed(bool isStartTime) async {
      TimeOfDay? newTime = await showTimePicker(
        useRootNavigator: false,
        confirmText: 'Confirm',
        minuteLabelText: '',
        hourLabelText: '',
        helpText: '',
        initialTime: isStartTime ? quietHoursStart : quietHoursEnd,
        context: context,
      );

      if (newTime is TimeOfDay) {
        final timeString = '${newTime.hour}:${newTime.minute}';
        storage.write(isStartTime ? 'quietHoursStart' : 'quietHoursEnd', timeString);
        appState.rebuildApp();

        // TODO: reset scheduled notifications, if needed
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 25, left: 20, right: 20),
      child: card.cardWrapper((paddingInterp) => Container(
        alignment: Alignment.center,
        color: Colors.white,
        padding: EdgeInsetsTween(
          begin: const EdgeInsets.symmetric(horizontal: 15), 
          end: const EdgeInsets.symmetric(horizontal: 75)
        ).lerp(paddingInterp),
        child: FocusTraversalGroup(
          descendantsAreFocusable: appState.settingsOpen && appState.currentCardFront == 'notifications',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const SettingsCard().settingsItem(
                tooltip: 'Notifications will not occur between these times.',
                text: 'Quiet hours',
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => onQuietHoursPressed(true),
                      child: Text(
                        is24HoursFormat
                          ? '${quietHoursStart.hour.toString().padLeft(2, '0')}:${quietHoursStart.minute.toString().padLeft(2, '0')}'
                          : '${quietHoursStart.hourOfPeriod}:${quietHoursStart.minute.toString().padLeft(2, '0')} ${quietHoursStart.period.name.toUpperCase()}',
                        style: const TextStyle(decoration: TextDecoration.underline)
                      ),
                    ),
                    const Text('–', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => onQuietHoursPressed(false),
                      child: Text(
                        is24HoursFormat
                          ? '${quietHoursStart.hour.toString().padLeft(2, '0')}:${quietHoursStart.minute.toString().padLeft(2, '0')}'
                          : '${quietHoursStart.hourOfPeriod}:${quietHoursStart.minute.toString().padLeft(2, '0')} ${quietHoursStart.period.name.toUpperCase()}',
                        style: const TextStyle(decoration: TextDecoration.underline)
                      ),
                    ),
                  ],
                )
              ),
              const Spacer()
            ]
          )
        )
      ))
    );
  }
}