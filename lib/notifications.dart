import 'dart:async';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'strategy_card.dart';

@pragma('vm:entry-point')
void notificationDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await GetStorage.init();

    if ((GetStorage().read('notificationsEnabled') ?? false)) {
      final int nextIndex = GetStorage().read('currentIndex') + 1;
      final String nextCard = const StrategyCard().nextCard(nextIndex, {})['text'];

      final notificationsService = LocalNotificationService();
      await notificationsService.init();
      notificationsService.showNotification(nextCard);

      GetStorage().write('currentIndex', nextIndex);
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