import 'dart:async';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'strategy_card.dart';
import 'package:flutter/material.dart';
import 'dart:math';

@pragma('vm:entry-point')
void notificationDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await GetStorage.init();
    final storage = GetStorage();

    if ((storage.read('notificationsEnabled') ?? false)) {
      final DateTime startTime = DateTime.now();
      final next = storage.read('nextNotificationTime') ? DateTime.parse(storage.read('nextNotificationTime')) : null;

      if (next != null && startTime.add(const Duration(minutes: 15)).isBefore(next)) {
        return Future.value(true);
      }

      int? secondsToWait;
      final String freqUnit = storage.read('notificationFreqUnit') ?? 'Hours';
      final int secondsPerUnit = freqUnit == 'Hours' ? 3600 : 60;
      final double minFreq = storage.read('minNotificationPeriod') ?? 1.5;
      final double maxFreq = storage.read('maxNotificationPeriod') ?? 3;
      final double freqDiff = maxFreq - minFreq;

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
      final TimeOfDay nowTime = TimeOfDay(hour: startTime.hour, minute: startTime.minute);
      
      isDuringQuietHours(TimeOfDay time) {
        if (
          quietHoursStart.hour == quietHoursEnd.hour && 
          quietHoursStart.minute == quietHoursEnd.minute
        ) {
          return false;
        }

        return quietHoursStart.hour < quietHoursEnd.hour || (quietHoursStart.hour == quietHoursEnd.hour && quietHoursStart.minute < quietHoursEnd.minute) ? (
          (
            time.hour > quietHoursStart.hour ||
            (time.hour == quietHoursStart.hour && time.minute > quietHoursStart.minute)
          ) && (
            time.hour < quietHoursEnd.hour ||
            (time.hour == quietHoursEnd.hour && time.minute < quietHoursEnd.minute)
          )
        ) : !(
          (
            time.hour < quietHoursStart.hour ||
            (time.hour == quietHoursStart.hour && time.minute < quietHoursStart.minute)
          ) && (
            time.hour > quietHoursEnd.hour ||
            (time.hour == quietHoursEnd.hour && time.minute > quietHoursEnd.minute)
          )
        );
      }

      // Set first timer after quiet hours
      if (
        next != null &&
        next.isBefore(startTime) &&
        isDuringQuietHours(nowTime) &&
        !isDuringQuietHours(nowTime.replacing(minute: nowTime.minute + 15))
      ) {
        final quietEndDate = DateTime(
          startTime.year,
          startTime.month,
          startTime.hour > quietHoursEnd.hour ? startTime.day + 1 : startTime.day,
          quietHoursEnd.hour,
          quietHoursEnd.minute
        );
        final int secTilNextAlarm = quietEndDate.difference(startTime).inSeconds + (Random().nextDouble() * freqDiff * secondsPerUnit ~/ 2);
        storage.write('nextNotificationTime', startTime.add(Duration(seconds: secTilNextAlarm)).toString());

        if (startTime.add(Duration(seconds: secTilNextAlarm)).isBefore(startTime.add(const Duration(minutes: 15)))) {
          secondsToWait = secTilNextAlarm;
        }
      }

      // Set timer if next notification should occur before next dispatcher call
      if (
        !isDuringQuietHours(nowTime) &&
        next != null &&
        next.isAfter(startTime) &&
        next.subtract(const Duration(minutes: 15)).isBefore(startTime) &&
        !isDuringQuietHours(TimeOfDay(hour: next.hour, minute: next.minute))
      ) {
        secondsToWait = next.difference(startTime).inSeconds;
      }

      // Set time for first notification or recently missed notification
      if (
        secondsToWait == null &&
        (next == null || startTime.isAfter(next)) &&
        !isDuringQuietHours(nowTime.replacing(minute: nowTime.minute + 1))
      ) {
        storage.write('nextNotificationTime', startTime.add(const Duration(minutes: 1)).toString());
      }

      // Recursive func for creating upcoming notifications
      Future<void> createNotification() async {
        final int nextIndex = storage.read('currentIndex') + 1;
        final String nextCard = const StrategyCard().nextCard(nextIndex, {})['text'];

        // Init notifications service & find next card
        final notificationsService = LocalNotificationService();
        await notificationsService.init();
        notificationsService.showNotification(nextCard);

        // Calculate next notification time
        final nextNotificationTime = startTime.add(Duration(seconds: ((minFreq + freqDiff * Random().nextDouble()) * secondsPerUnit).toInt()));
        storage.write('currentIndex', nextIndex);
        storage.write('nextNotificationTime', nextNotificationTime.toString());

        // If next notification should occur before the next dispatcher call,
        // create timer to create the next notification
        if (startTime.add(const Duration(minutes: 15)).isAfter(nextNotificationTime)) {
          Timer(
            Duration(seconds: nextNotificationTime.difference(DateTime.now()).inSeconds),
            createNotification
          );
        }
      }

      if (secondsToWait != null) {
        Timer(Duration(seconds: secondsToWait), createNotification);
      }
    }

    return Future.value(true);
  });
}

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings initSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<bool> getIosPermissions() async {
    final bool? result = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

    return result ?? false;
  }

  void showNotification(String body) async {
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'Oblique Strategies',
      'Oblique Strategies',
      channelDescription: 'Oblique Strategies',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Oblique Strategies'
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails
    );

    await flutterLocalNotificationsPlugin.show(1, 'Oblique Strategies', body, notificationDetails);
  }
}
