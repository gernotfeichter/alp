import 'dart:isolate';

import 'package:awesome_notifications/awesome_notifications.dart';

import '../logging/logging.dart';
import 'notifications.dart';

class NotificationEventHandler {

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    log.finer("onNotificationCreatedMethod called: $receivedNotification");
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    log.finer("onNotificationDisplayedMethod called: $receivedNotification");
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    log.finer("onDismissActionReceivedMethod called: $receivedAction");
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
    log.finer("onActionReceivedMethod called: $receivedAction ${Isolate.current.debugName}");
    if (receivedAction.id != null && receivedAction.buttonKeyPressed != "") {
      final id = receivedAction.id!;
      log.finer("id=$id, receivedAction.buttonKeyPressed=${receivedAction.buttonKeyPressed} ${Isolate.current.debugName}");
      authRequestNotificationStateHistory.add({id: receivedAction.buttonKeyPressed == 'APPROVE'});
    }
  }
}