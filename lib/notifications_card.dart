import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io' show Platform;
import 'main.dart';
import 'cards.dart';
import 'settings_card.dart';
import 'notifications.dart';

class NotificationsCard extends StatelessWidget {
  const NotificationsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Cards card = Cards();
    AppState appState = context.watch<AppState>();
    final storage = GetStorage();

    final minController = TextEditingController(text: (storage.read('minNotificationPeriod') ?? 90).toString());
    final maxController = TextEditingController(text: (storage.read('maxNotificationPeriod') ?? 180).toString());
    final minFocusNode = FocusNode();
    final maxFocusNode = FocusNode();

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
      }
    }

    void minFrequencyChanged() {
      final val = int.parse(minController.text);
      final currentMax = storage.read('maxNotificationPeriod') ?? 180;
      
      if (val < currentMax) {
        storage.write('minNotificationPeriod', val);
      } else {
        storage.write('maxNotificationPeriod', val);
        storage.write('minNotificationPeriod', currentMax);
      }

      appState.rebuildApp();
    }

    void maxFrequencyChanged() {
      final val = int.parse(maxController.text);
      final currentMin = storage.read('minNotificationPeriod') ?? 90;
      
      if (val > currentMin) {
        storage.write('maxNotificationPeriod', val);
      } else {
        storage.write('minNotificationPeriod', val);
        storage.write('maxNotificationPeriod', currentMin);
      }

      appState.rebuildApp();
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
          descendantsAreFocusable: appState.cardFace == 'notifications',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Spacer(),
              const SettingsCard().settingsItem(
                text: 'Enable notifications',
                child: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: storage.read('notificationsEnabled') ?? false,
                    semanticLabel: 'Enable notifications',
                    onChanged: (val) async {
                      if (val is bool) {
                        if (val && Platform.isIOS) {
                          final permissionsGranted = await LocalNotificationService().getIosPermissions();

                          if (!permissionsGranted) {
                            return;
                          }
                        }

                        storage.write('notificationsEnabled', val);
                        appState.rebuildApp();
                      }
                    }
                  ),
                )
              ),
              const Spacer(),
              const SettingsCard().settingsItem(
                tooltip: 'Notifications will randomly repeat within the provided time span. If the numbers match, notifications will regularly repeat at that interval, starting when your quiet hours end.',
                text: 'Notify every',
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 40),
                        child: IntrinsicWidth(
                          child: TextFormField(
                            controller: minController,
                            focusNode: minFocusNode,
                            onTapOutside: (onTapOutside) {
                              minFrequencyChanged();
                              minFocusNode.unfocus();
                            },
                            onEditingComplete: minFrequencyChanged,
                            cursorHeight: 18,
                            style: const TextStyle(fontSize: 21, fontFamily: 'Univers'),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                            ],
                            decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 1.1),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 1.1),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 1.1),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 1.1),
                              ),
                              contentPadding: EdgeInsets.all(-1),
                              isDense: true
                            ),                         ),
                        ),
                      ),
                    ),
                    const Text('–', style: TextStyle(fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 40),
                        child: IntrinsicWidth(
                          child: TextFormField(
                            controller: maxController,
                            focusNode: maxFocusNode,
                            onTapOutside: (onTapOutside) {
                              maxFrequencyChanged();
                              maxFocusNode.unfocus();
                            },
                            onEditingComplete: maxFrequencyChanged,
                            cursorHeight: 18,
                            style: const TextStyle(fontSize: 21, fontFamily: 'Univers'),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                            ],
                            decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 1.1),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 1.1),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 1.1),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 1.1),
                              ),
                              contentPadding: EdgeInsets.all(-1),
                              isDense: true
                            )
                          ),
                        ),
                      ),
                    ),
                    const Text(' Minutes', textScaleFactor: 1.5),
                  ],
                )
              ),
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
                          ? '${quietHoursEnd.hour.toString().padLeft(2, '0')}:${quietHoursEnd.minute.toString().padLeft(2, '0')}'
                          : '${quietHoursEnd.hourOfPeriod}:${quietHoursEnd.minute.toString().padLeft(2, '0')} ${quietHoursEnd.period.name.toUpperCase()}',
                        style: const TextStyle(decoration: TextDecoration.underline)
                      ),
                    ),
                  ],
                )
              ),
              const Spacer(),
              const Spacer()
            ]
          )
        )
      ))
    );
  }
}