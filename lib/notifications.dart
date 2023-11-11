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
      final DateTime now = DateTime.now();
      final next = storage.read('nextNotificationTime') ? DateTime.parse(storage.read('nextNotificationTime')) : null;
      int? secondsToWait;

      final int minFreq = storage.read('minNotificationPeriod') ?? 90;
      final int maxFreq = storage.read('maxNotificationPeriod') ?? 180;
      final int freqDiff = maxFreq - minFreq;

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
      final TimeOfDay nowTime = TimeOfDay(hour: now.hour, minute: now.minute);
      
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

      if (
        isDuringQuietHours(nowTime) &&
        !isDuringQuietHours(nowTime.replacing(minute: nowTime.minute + 15))
      ) {
        final quietEndDate = DateTime(now.year, now.month, now.day, quietHoursEnd.hour, quietHoursEnd.minute);
        secondsToWait = quietEndDate.difference(now).inSeconds + (Random().nextInt(freqDiff * 60).toInt() ~/ 2);
        storage.write('nextNotificationTime', now.add(Duration(seconds: secondsToWait)).toString());
      }

      if (
        !isDuringQuietHours(nowTime) &&
        next != null &&
        next.isAfter(now) &&
        next.subtract(const Duration(minutes: 15)).isBefore(now) &&
        !isDuringQuietHours(TimeOfDay(hour: next.hour, minute: next.minute))
      ) {
        secondsToWait = next.difference(now).inSeconds;
      }

      if (
        (next == null || now.isAfter(next)) &&
        !isDuringQuietHours(nowTime.replacing(minute: nowTime.minute + 1))
      ) {
        secondsToWait = 60;
        storage.write('nextNotificationTime', now.add(Duration(seconds: secondsToWait)).toString());
      }

      if (secondsToWait != null) {
        Timer(Duration(seconds: secondsToWait), () async {
          final int nextIndex = storage.read('currentIndex') + 1;
          final String nextCard = const StrategyCard().nextCard(nextIndex, {})['text'];

          final notificationsService = LocalNotificationService();
          await notificationsService.init();
          notificationsService.showNotification(nextCard);

          storage.write('currentIndex', nextIndex);
          storage.write('nextNotificationTime', now.add(Duration(seconds: Random().nextInt(freqDiff * 60))).toString());
        });
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
