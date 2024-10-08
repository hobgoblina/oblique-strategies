import 'dart:async';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'strategy_card.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:easy_localization/easy_localization.dart';

Future<bool> createNotifications(task, inputData) async {
  await GetStorage.init();
  final storage = GetStorage();

  if ((storage.read('notificationsEnabled') ?? false)) {
    final DateTime startTime = DateTime.now();
    final next = storage.read('nextNotificationTime') is String
      ? DateTime.parse(storage.read('nextNotificationTime'))
      : null;
    final lastScheduled = storage.read('lastScheduledNotification') is String
      ? DateTime.parse(storage.read('lastScheduledNotification'))
      : null;

    if (next != null && startTime.add(const Duration(minutes: 30)).isBefore(next)) {
      return Future.value(true);
    }

    final notificationsService = LocalNotificationService();
    await notificationsService.init();
    tz.initializeTimeZones();

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

    bool isDuringQuietHours(TimeOfDay time) {
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

    int currentIndex = storage.read('currentIndex');
    final lastScheduledIndex = storage.read('lastScheduledIndex');
    int nextIndex = currentIndex + 1;

    if (lastScheduledIndex is int) {
      final nextScheduledIndex = await notificationsService.getNextScheduledIndex();

      if (nextScheduledIndex is int) {
        if (nextScheduledIndex - 1 > currentIndex) {
          storage.write('currentIndex', nextScheduledIndex - 1);
          currentIndex = nextScheduledIndex - 1;
        }
      } else if (lastScheduledIndex != currentIndex) {
        storage.write('currentIndex', lastScheduledIndex);
        currentIndex = lastScheduledIndex;
      }

      nextIndex = lastScheduledIndex + 1;
    }

    // Recursive func for creating upcoming notifications
    Future<void> scheduleNotifications(DateTime notificationTime) async {
      storage.write('lastScheduledNotification', notificationTime.toString());
      storage.write('lastScheduledIndex', nextIndex);

      // Find next card
      final String nextCard = const StrategyCard().nextCard(nextIndex, {}, null)['text'];

      // Schedule notification
      await notificationsService.scheduleNotification(
        body: nextCard,
        notificationTime: notificationTime,
        id: nextIndex
      );

      // Calculate next notification time
      final secondsTillNext = ((minFreq + (freqDiff * Random().nextDouble())) * secondsPerUnit).toInt();
      final nextNotificationTime = notificationTime.add(Duration(seconds: secondsTillNext));

      if (!isDuringQuietHours(TimeOfDay.fromDateTime(nextNotificationTime))) {
        storage.write('nextNotificationTime', nextNotificationTime.toString());

        // Schedule next notification if it should occur before the next dispatcher call
        if (startTime.add(const Duration(minutes: 30)).isAfter(nextNotificationTime)) {
          nextIndex = nextIndex + 1;
          await scheduleNotifications(nextNotificationTime);
        }
      } else {
        storage.write('nextNotificationTime', null);
      }
    }

    DateTime nextQuietHoursEnd = startTime.copyWith(
      hour: quietHoursEnd.hour,
      minute: quietHoursEnd.minute,
    );

    if (
      startTime.hour > quietHoursEnd.hour || (
        startTime.hour == quietHoursEnd.hour &&
        startTime.minute > quietHoursEnd.minute
      )
    ) {
      nextQuietHoursEnd = nextQuietHoursEnd.add(const Duration(days: 1));
    }

    if ( // Schedule first notification after quiet hours
      next == null &&
      nextQuietHoursEnd.isBefore(startTime.add(const Duration(minutes: 30)))
    ) {
      await scheduleNotifications(
        nextQuietHoursEnd.add(Duration(seconds: freqDiff * secondsPerUnit * Random().nextDouble() ~/ 2))
      );
    } else if ( // Schedule planned upcoming notification
      next != null &&
      next.isBefore(startTime.add(const Duration(minutes: 30))) &&
      next.isAfter(startTime)
    ) {
      await scheduleNotifications(next);
    } else if ( // Schedule new, not-already-planned notifications
      (next == null || next.isBefore(startTime)) &&
      (
        lastScheduled == null ||
        lastScheduled.isBefore(startTime.subtract(Duration(seconds: (minFreq * secondsPerUnit).toInt())))
      ) &&
      !isDuringQuietHours(TimeOfDay.fromDateTime(startTime.add(const Duration(minutes: 1))))
    ) {
      await scheduleNotifications(startTime.add(const Duration(minutes: 1)));
    }
  }

  return Future.value(true);
}

@pragma('vm:entry-point')
void notificationDispatcher() {
  Workmanager().executeTask(createNotifications);
}

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('notification_icon');
    const DarwinInitializationSettings initSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationsPlugin.initialize(initSettings);
  }

  Future<bool> getIosPermissions() async {
    final bool? result = await notificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

    return result ?? false;
  }

  Future<bool> getAndroidPermissions() async {
    final bool? notificationsResult = await notificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

    final bool? exactAlarmsResult = await notificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestExactAlarmsPermission();

    return (notificationsResult ?? false) && (exactAlarmsResult ?? false);
  }

  Future<int?> getNextScheduledIndex() async {
    List<ActiveNotification> scheduled = await notificationsPlugin.getActiveNotifications();

    if (scheduled.isEmpty) {
      return null;
    }

    List<int> ids = scheduled.map((e) => e.id ?? -1).toList();
    ids.sort();

    return ids.firstWhere((e) => e != -1);
  }

  Future<void> scheduleNotification({
    required String body,
    required int id,
    required DateTime notificationTime
  }) async {
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'oblique_strategies',
      'title'.tr(),
      channelDescription: 'title'.tr(),
      icon: 'notification_icon',
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails
    );

    await notificationsPlugin.zonedSchedule(
      id,
      'title'.tr(),
      body,
      tz.TZDateTime.from(notificationTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );
  }
}
