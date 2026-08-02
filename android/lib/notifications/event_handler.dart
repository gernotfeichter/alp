import 'dart:isolate';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../logging/background_service/logging.dart';
import 'notifications.dart';

@pragma("vm:entry-point")
Future<void> _onActionReceivedImplementation(ReceivedAction receivedAction) async {
  log.info("onActionReceivedMethod called: $receivedAction ${Isolate.current.debugName}");
  print("ALP_DEBUG: onActionReceivedMethod implementation called for ID ${receivedAction.id}");

  if (receivedAction.id != null && (receivedAction.buttonKeyPressed == 'APPROVE' || receivedAction.buttonKeyPressed == 'DENY')) {
    final id = receivedAction.id!;
    final approved = receivedAction.buttonKeyPressed == 'APPROVE';
    log.info("Action received: id=$id, approved=$approved");

    // Notify the background service isolate
    try {
      FlutterBackgroundService().invoke("notificationAction", {id.toString(): approved});
      print("ALP_DEBUG: invoked notificationAction for ID $id with $approved");
    } catch (e) {
      print("ALP_DEBUG: Error invoking background service: $e");
    }

    // Also update locally just in case
    authRequestNotificationStateHistory.add({id: approved});
  }
}

@pragma("vm:entry-point")
Future<void> _onNotificationCreatedImplementation(ReceivedNotification receivedNotification) async {
  log.finer("onNotificationCreatedMethod called: $receivedNotification");
}

@pragma("vm:entry-point")
Future<void> _onNotificationDisplayedImplementation(ReceivedNotification receivedNotification) async {
  log.finer("onNotificationDisplayedMethod called: $receivedNotification");
}

@pragma("vm:entry-point")
Future<void> _onDismissActionReceivedImplementation(ReceivedAction receivedAction) async {
  log.finer("onDismissActionReceivedMethod called: $receivedAction");
}

@pragma("vm:entry-point")
class NotificationEventHandler {
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) => _onActionReceivedImplementation(receivedAction);
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) => _onNotificationCreatedImplementation(receivedNotification);
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) => _onNotificationDisplayedImplementation(receivedNotification);
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) => _onDismissActionReceivedImplementation(receivedAction);
}
