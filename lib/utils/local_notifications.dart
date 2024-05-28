import 'dart:developer';

import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:reminder/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initNotification() {
  const locationName = 'Asia/Kolkata';
  tz.setLocalLocation(tz.getLocation(locationName));

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse:
        onDidReceiveBackgroundNotificationResponse,
  );
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int completed = prefs.getInt('completed') ?? 0;
  completed = completed + 1;
  prefs.setInt('completed', completed);
  // Handle foreground notification tapped logic here
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: ${notificationResponse.payload}');
  }
}

void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse notificationResponse) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int completed = prefs.getInt('completed') ?? 0;
  completed = completed + 1;
  prefs.setInt('completed', completed);
  if (notificationResponse.payload != null) {
    debugPrint(
        'background notification payload: ${notificationResponse.payload}');
  }
}

void scheduleReminder(String title, String description, DateTime scheduledDate,
    String priority, int index) async {
  final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'reminder_channel',
    'Reminder Notifications',
    importance: getImportance(priority),
    priority: getPriority(priority),
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

  await flutterLocalNotificationsPlugin.zonedSchedule(
    notificationId,
    title,
    description,
    tz.TZDateTime.from(scheduledDate, tz.local),
    NotificationDetails(android: androidDetails, iOS: iosDetails),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
  log('scheduled');
}

void scheduleAllReminders() {
  for (int i = 0; i < allReminderList.length; i++) {
    var reminder = allReminderList[i];
    DateTime dateTime = parseReminderDateTime(reminder.date!, reminder.time!);
    scheduleReminder(reminder.title!, reminder.description!, dateTime,
        reminder.priority!, i);
  }
}

DateTime parseReminderDateTime(String date, String time) {
  final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
  final DateFormat timeFormatter = DateFormat('hh:mm a');

  final DateTime parsedDate = dateFormatter.parse(date);
  final DateTime parsedTime = timeFormatter.parse(time);

  return DateTime(
    parsedDate.year,
    parsedDate.month,
    parsedDate.day,
    parsedTime.hour,
    parsedTime.minute,
  );
}

Importance getImportance(String priority) {
  switch (priority) {
    case 'High':
      return Importance.high;
    case 'Medium':
      return Importance.defaultImportance;
    case 'Low':
      return Importance.low;
    default:
      return Importance.defaultImportance;
  }
}

Priority getPriority(String priority) {
  switch (priority) {
    case 'High':
      return Priority.high;
    case 'Medium':
      return Priority.defaultPriority;
    case 'Low':
      return Priority.low;
    default:
      return Priority.defaultPriority;
  }
}
