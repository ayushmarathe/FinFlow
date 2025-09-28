import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class BudgetNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _tzInitialized = false;

  static Future<void> init() async {
    if (!_tzInitialized) {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      _tzInitialized = true;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(initSettings);
    print('Notification plugin initialized.');
  }

  static Future<void> requestNotificationPermission() async {
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

  static Future<void> checkBudgetAndNotify() async {
    await _maybeResetMonthlyFlags();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in.');
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists || !userDoc.data()!.containsKey('budget')) {
      print('User document not found or budget missing.');
      return;
    }

    final double monthlyBudget = (userDoc['budget'] as num).toDouble();
    final double expectedDailyExpense = monthlyBudget / 30;

    final expenseCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses');

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final monthlySnapshot = await expenseCollection
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .get();

    final double totalSpentThisMonth = monthlySnapshot.docs.fold(
      0.0,
      (sum, doc) => sum + (doc['amount'] as num).toDouble(),
    );

    final todaySnapshot = await expenseCollection
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .get();

    final double totalSpentToday = todaySnapshot.docs.fold(
      0.0,
      (sum, doc) => sum + (doc['amount'] as num).toDouble(),
    );

    await _triggerNotifications(
      monthlyBudget,
      expectedDailyExpense,
      totalSpentThisMonth,
      totalSpentToday,
    );
  }

  static Future<void> _triggerNotifications(
    double monthlyBudget,
    double expectedDailyExpense,
    double totalSpentThisMonth,
    double totalSpentToday,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final double percentSpent = (totalSpentThisMonth / monthlyBudget) * 100;

    final List<int> thresholds = [25, 50, 75, 90, 100];
    for (final threshold in thresholds) {
      final key = 'notified_$threshold';
      final alreadyNotified = prefs.getBool(key) ?? false;

      if (percentSpent >= threshold && !alreadyNotified) {
        await _showNotification(
          "You've spent more than $threshold% of your monthly budget!",
          id: threshold,
        );
        await prefs.setBool(key, true);
        print("Notification shown: $threshold% threshold.");
      }
    }

    // DAILY SPENDING NOTIFICATION (only once per day)
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final lastNotifiedDay = prefs.getString('last_daily_notification_date');

    if (totalSpentToday > expectedDailyExpense && lastNotifiedDay != todayKey) {
      await _showNotification(
        "Today's spend: ₹${totalSpentToday.toStringAsFixed(2)}.\n"
        "You've exceeded your daily limit of ₹${expectedDailyExpense.toStringAsFixed(2)}.",
        id: 999,
      );
      await prefs.setString('last_daily_notification_date', todayKey);
      print("Notification shown: Daily limit exceeded.");
    }
  }

  static Future<void> _showNotification(String message, {int id = 0}) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_channel',
      'Budget Alerts',
      channelDescription: 'Notifications about budget spending',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      'FinFlow Alert',
      message,
      notificationDetails,
    );
    print('Notification shown: $message');
  }

  static Future<void> _maybeResetMonthlyFlags() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final currentMonthKey = '${now.year}-${now.month}';
    final lastReset = prefs.getString('last_reset_month');

    if (lastReset != currentMonthKey) {
      print('New month detected, resetting flags...');
      await prefs.setString('last_reset_month', currentMonthKey);
      await resetThresholdFlags();
    }
  }

  static Future<void> resetThresholdFlags() async {
    final prefs = await SharedPreferences.getInstance();
    for (final t in [25, 50, 75, 90, 100]) {
      await prefs.remove('notified_$t');
    }
    await prefs.remove('last_daily_notification_date');
    print('All notification flags reset.');
  }

  // 🔔 Daily Reminders (12PM, 3PM, 6PM, 9PM)
  static Future<void> scheduleReminderNotifications() async {
    final times = [12, 15, 18, 21]; // hours
    for (final hour in times) {
      await _scheduleDailyReminder(hour);
    }
  }

  static Future<void> _scheduleDailyReminder(int hour) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists || !userDoc.data()!.containsKey('budget')) return;

    final double monthlyBudget = (userDoc['budget'] as num).toDouble();
    final double expectedDailyExpense = monthlyBudget / 30;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final expenseCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses');

    final monthlySnapshot = await expenseCollection
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .get();

    final double totalSpentThisMonth = monthlySnapshot.docs.fold(
      0.0,
      (sum, doc) => sum + (doc['amount'] as num).toDouble(),
    );

    final todaySnapshot = await expenseCollection
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .get();

    final double totalSpentToday = todaySnapshot.docs.fold(
      0.0,
      (sum, doc) => sum + (doc['amount'] as num).toDouble(),
    );

    final double remaining = monthlyBudget - totalSpentThisMonth;

    final scheduledTime =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Budget Reminders',
        channelDescription: 'Reminders about your spending habits',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      hour,
      'FinFlow Reminder',
      '🧾 Spent this month: ₹${totalSpentThisMonth.toStringAsFixed(2)}\n'
          '💰 Remaining: ₹${remaining.toStringAsFixed(2)}\n'
          '📅 Today: ₹${totalSpentToday.toStringAsFixed(2)}',
      scheduledTime.isBefore(tz.TZDateTime.now(tz.local))
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelReminderNotifications() async {
    for (final id in [12, 15, 18, 21]) {
      await _notificationsPlugin.cancel(id);
    }
  }
}
