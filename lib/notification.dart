import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'data/store.dart';
import 'models/batch.dart';

class Notification {
  static void cancelNotification(Batch batch, NotificationType type) {
    int? id = batch.notifications[type]?.toInt();
    if (id != null) {
      AwesomeNotifications().cancel(id);
      batch.notifications.remove(type);
    }
  }

  static void replaceNotification(Batch batch, NotificationType type, int? oldId, DateTime? date) {
    if (oldId != null) AwesomeNotifications().cancel(oldId);
    if (date != null) scheduleNotification(batch, type, date);
  }

  static void scheduleNotification(Batch batch, NotificationType type, DateTime? date) {
    DateTime scheduleDate;
    int days;
    switch (type) {
      case NotificationType.fermentationPossiblyDone: days = 14; break;
      case NotificationType.fermentationDone: days = 21; break;
      case NotificationType.lageringDone: days = 7; break;
      case NotificationType.bottlingDone: days = 14; break;
      case NotificationType.done: days = 21; break;
      default: days = 0; break;
    }
    scheduleDate = (date ?? DateTime.now()).add(Duration(days: days));
    scheduleDate = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day, 9);

    Random random = Random();
    int id = random.nextInt(1000);
    while (Store.notificationIds.contains(id)) {
      id = random.nextInt(1000);
    }

    if (scheduleDate.isAfter(DateTime.now())) {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id,
            channelKey: "basic_channel",
            title: getTitle(type),
            body: getBody(type),
            payload: {
              "batch": batch.id
            }
          ),
          schedule: NotificationCalendar(year: scheduleDate.year,
              month: scheduleDate.month,
              day: scheduleDate.day,
              hour: scheduleDate.hour,
              minute: scheduleDate.minute));

      batch.addNotification(id, type);
    }
  }
  
  static String getTitle(NotificationType type) {
    switch (type) {
      case NotificationType.fermentationPossiblyDone: return "Mogelijk klaar met fermenteren";
      case NotificationType.fermentationDone: return "Klaar met vergisting";
      case NotificationType.lageringDone: return "Klaar met lageren";
      case NotificationType.bottlingDone: return "Bijna klaar met nagisting";
      case NotificationType.done: return "Klaar!";
      default: return type.name;
    }
  }

  static String getBody(NotificationType type) {
    switch (type) {
      case NotificationType.fermentationPossiblyDone: return "Meet de SG-waarde. Als deze twee dagen stabiel is, kun je gaan lageren.";
      case NotificationType.fermentationDone: return "Je kunt gaan lageren.";
      case NotificationType.lageringDone: return "Je kunt gaan bottelen.";
      case NotificationType.bottlingDone: return "Je kunt gaan proeven.";
      case NotificationType.done: return "Je bier is klaar! Je kunt hem gaan drinken.";
      default: return type.name;
    }
  }
}