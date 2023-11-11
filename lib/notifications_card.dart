import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io' show Platform;
import 'main.dart';
import 'cards.dart';
import 'settings_card.dart';
import 'notifications.dart';
import 'dart:math';

class NotificationsCard extends StatefulWidget {
  const NotificationsCard({
    Key? key,
  }) : super(key: key);

  @override
  State<NotificationsCard> createState() => NotificationsCardState();
}

class NotificationsCardState extends State<NotificationsCard> {
  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();
  final FocusNode minFocusNode = FocusNode(canRequestFocus: false);
  final FocusNode maxFocusNode = FocusNode(canRequestFocus: false);

  @override
  void dispose() {
    minController.dispose();
    maxController.dispose();
    minFocusNode.dispose();
    maxFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Cards card = Cards();
    AppState appState = context.watch<AppState>();
    final storage = GetStorage();
    final inputFormatter = <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp("[0-9]"))];

    if (minController.text.isEmpty && !minFocusNode.hasFocus) {
      minController.text = (storage.read('minNotificationPeriod') ?? 90).toString();
    }

    if (maxController.text.isEmpty && !maxFocusNode.hasFocus) {
      maxController.text = (storage.read('maxNotificationPeriod') ?? 180).toString();
    }

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

    void frequencyChanged({ bool shouldUnfocus = false }) {
      if (minController.text.isEmpty || maxController.text.isEmpty) {
        return;
      }

      final vals = <int>[ int.parse(minController.text), int.parse(maxController.text) ];
      final minVal = vals.reduce(min);
      final maxVal = vals.reduce(max);
      
      storage.write('minNotificationPeriod', minVal);
      storage.write('maxNotificationPeriod', maxVal);

      if (!minFocusNode.hasFocus && !maxFocusNode.hasFocus) {
        minController.text = '$minVal';
        maxController.text = '$maxVal';
      }

      if (shouldUnfocus) {
        minFocusNode.unfocus();
        maxFocusNode.unfocus();
      }

      appState.rebuildApp();
    }

    minFocusNode.addListener(frequencyChanged);
    maxFocusNode.addListener(frequencyChanged);

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
                            focusNode: minFocusNode,
                            controller: minController,
                            onEditingComplete: frequencyChanged,
                            cursorHeight: 18,
                            style: const TextStyle(fontSize: 21, fontFamily: 'Univers'),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: inputFormatter,
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
                            ),
                          ),
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
                            focusNode: maxFocusNode,
                            controller: maxController,
                            onEditingComplete: frequencyChanged,
                            cursorHeight: 18,
                            style: const TextStyle(fontSize: 21, fontFamily: 'Univers'),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: inputFormatter,
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