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
    final inputFormatter = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp("^([0-9]+)?\\.?([0-9]+)?"))
    ];
    RegExp zerosRegex = RegExp(r'([.]*0)(?!.*\d)');

    if (minController.text.isEmpty && !minFocusNode.hasFocus) {
      minController.text = (storage.read('minNotificationPeriod') ?? 1.5).toString().replaceAll(zerosRegex, '');
    }

    if (maxController.text.isEmpty && !maxFocusNode.hasFocus) {
      maxController.text = (storage.read('maxNotificationPeriod') ?? 3).toString().replaceAll(zerosRegex, '');
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

      LocalNotificationService().notificationsPlugin.cancelAll();
      storage.write('nextNotificationTime', null);
      
      final lastTime = storage.read('lastScheduledNotification');
      if (lastTime != null && DateTime.parse(lastTime).isAfter(DateTime.now())) {
        storage.write('lastScheduledNotification', null);
        storage.write('lastScheduledIndex', null);
      }
    }

    void frequencyChanged({ bool shouldMoveFocus = false, bool isMin = false }) {
      if (minController.text.isEmpty || maxController.text.isEmpty) {
        return;
      }

      final vals = <double>[ double.parse(minController.text), double.parse(maxController.text) ];
      final minVal = vals.reduce(min);
      final maxVal = vals.reduce(max);
      
      storage.write('minNotificationPeriod', minVal);
      storage.write('maxNotificationPeriod', maxVal);
      LocalNotificationService().notificationsPlugin.cancelAll();
      storage.write('nextNotificationTime', null);

      final lastTime = storage.read('lastScheduledNotification');
      if (lastTime != null && DateTime.parse(lastTime).isAfter(DateTime.now())) {
        storage.write('lastScheduledNotification', null);
        storage.write('lastScheduledIndex', null);
      }

      if (!minFocusNode.hasFocus && !maxFocusNode.hasFocus) {
        minController.text = '$minVal'.replaceAll(zerosRegex, '');
        maxController.text = '$maxVal'.replaceAll(zerosRegex, '');
      }

      if (shouldMoveFocus) {
        if (isMin) {
          minFocusNode.nextFocus();
        } else {
          maxFocusNode.nextFocus();
        }
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
                        if (val) {
                          bool permissionsGranted;

                          if (Platform.isIOS) {
                            permissionsGranted = await LocalNotificationService().getIosPermissions();
                          } else {
                            permissionsGranted = await LocalNotificationService().getAndroidPermissions();
                          }

                          if (!permissionsGranted) {
                            return;
                          }
                        } else {
                          LocalNotificationService().notificationsPlugin.cancelAll();
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
                tooltip: 'Notifications will randomly repeat within the provided time span. If the numbers match, notifications will regularly repeat at that interval.',
                text: 'Notify every',
                wrapControls: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 40),
                        child: IntrinsicWidth(
                          child: TextFormField(
                            focusNode: minFocusNode,
                            controller: minController,
                            onEditingComplete: () => frequencyChanged(shouldMoveFocus: true, isMin: true),
                            onTapOutside: (onTapOutside) => minFocusNode.unfocus(),
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
                              contentPadding: EdgeInsets.symmetric(vertical: -1),
                              isCollapsed: true,
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
                            onEditingComplete: () => frequencyChanged(shouldMoveFocus: true),
                            onTapOutside: (onTapOutside) => maxFocusNode.unfocus(),
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
                              contentPadding: EdgeInsets.symmetric(vertical: -1),
                              isCollapsed: true,
                              isDense: true
                            )
                          ),
                        ),
                      ),
                    ),
                    IntrinsicWidth(
                      child: DropdownButtonFormField<String>(
                        value: storage.read('notificationFreqUnit') ?? 'Hours',
                        elevation: 20,
                        iconSize: 0,
                        style: const TextStyle(fontSize: 21, fontFamily: 'Univers', color: Colors.black),
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1.1),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1.1),
                          ),
                          focusColor: Colors.black12,
                          contentPadding: EdgeInsets.symmetric(vertical: 3),
                          isCollapsed: true
                        ),
                        onChanged: (String? value) {
                          storage.write('notificationFreqUnit', value);
                          LocalNotificationService().notificationsPlugin.cancelAll();
                          storage.write('nextNotificationTime', null);
                          final lastTime = storage.read('lastScheduledNotification');
                          if (
                            lastTime != null &&
                            DateTime.parse(lastTime).isAfter(DateTime.now())
                          ) {
                            storage.write('lastScheduledNotification', null);
                            storage.write('lastScheduledIndex', null);
                          }
                          appState.rebuildApp();
                        },
                        items: ['Minutes', 'Hours'].map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            value: value, 
                            child: Text(value)
                          )
                        ).toList(),
                      ),
                    )
                  ],
                )
              ),
              const Spacer(),
              const SettingsCard().settingsItem(
                tooltip: 'Notifications will not occur between these times.',
                text: 'Quiet hours',
                wrapControls: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
