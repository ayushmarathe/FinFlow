import 'package:bloc/bloc.dart';
import 'package:finflow/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:finflow/simple_bloc_observer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/budget_notification_service.dart';

void testNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'Welcome_channel',
    'Welcome Notification',
    channelDescription: 'Good Day User!',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await FlutterLocalNotificationsPlugin().show(
    0,
    'Welcome',
    'Have Financially FruitFul Day 😊',
    notificationDetails,
  );
  print('Test notification triggered.');
}

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    final result = await Permission.notification.request();
    if (result.isGranted) {
      print('Notification permission granted.');
    } else {
      print('Notification permission denied.');
    }
  } else {
    print('Notification permission already granted.');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await requestNotificationPermission();
  await BudgetNotificationService.init();
  testNotification();
  await BudgetNotificationService.checkBudgetAndNotify();
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}
