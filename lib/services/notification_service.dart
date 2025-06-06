import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('logo');
    const InitializationSettings initializationSettings =  InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showCheckoutSuccessNotification(List<String> productNames) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'checkout_channel',
      'Checkout Notifications',
      channelDescription: 'This channel is for checkout notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
    String productNameList = productNames.join(', ');
    print('Product names: $productNameList');

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Checkout Successful',
      'Your items : $productNameList have been successfully checked out.',
      notificationDetails,
    );
  }
}
