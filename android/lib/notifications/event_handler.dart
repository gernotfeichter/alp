import 'package:awesome_notifications/awesome_notifications.dart';

import '../logging/logging.dart';
import 'notifications.dart';

class NotificationEventHandler {

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    log.fine("onNotificationCreatedMethod called: ${receivedNotification.payload}");
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    log.fine("onNotificationDisplayedMethod called: ${receivedNotification.payload}");
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    log.fine("onDismissActionReceivedMethod called: ${receivedAction.payload}");
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
    log.info("onActionReceivedMethod called: ${receivedAction.payload}");
    if (receivedAction.id != null) {
      final id = receivedAction.id!;
      log.info("id=$id, receivedAction.buttonKeyPressed=$receivedAction.buttonKeyPressed");
      authRequestNotificationStateHistory.add({id: receivedAction.buttonKeyPressed == 'APPROVE'});
    }
    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
    //         (route) => (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
  }
}