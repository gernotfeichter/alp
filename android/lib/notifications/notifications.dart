import 'dart:async';
import 'dart:isolate';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/material.dart';
import '../logging/background_service/logging.dart';
import '../secure_storage/secure_storage.dart';
import 'event_handler.dart';

const authRequestsNotificationChannelKey = 'alp_auth_requests';
const authRequestsNotificationStartId = 2;

// for each of the last five notifications, contains a map(notification_id(int): approval state(bool))
// That means that one device can theoretically handle up to five concurrent auth requests
final authRequestNotificationStateHistory = CircularBuffer<Map<int,bool>>(5)..add({authRequestsNotificationStartId: false});

void initForUi() {
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
}

Future initForBackgroundService() async{
  AwesomeNotifications().initialize(
      'resource://drawable/ic_bg_service_small',
      [
        NotificationChannel(
            channelKey: authRequestsNotificationChannelKey,
            channelName: 'Alp auth requests',
            channelDescription: 'Authentication requests channel for alp (android-linux-pam project) - Authentication Requests from Linux',
            importance: NotificationImportance.Max,
            defaultPrivacy: NotificationPrivacy.Secret,
        )
      ]
  );
  AwesomeNotifications().setListeners(
      onActionReceivedMethod:         NotificationEventHandler.onActionReceivedMethod,
      onNotificationCreatedMethod:    NotificationEventHandler.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:  NotificationEventHandler.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:  NotificationEventHandler.onDismissActionReceivedMethod
  );
}


int createNotificationAuthRequest({timeoutSeconds = 60, title}) {
  log.info("createNotification called: $title");
  var id = authRequestNotificationStateHistory.last.keys.first + 1; // should yield last notification id + 1
  createNotificationAuthRequestAsyncPart(id: id, timeoutSeconds: timeoutSeconds, title: title);
  return id;
}

void createNotificationAuthRequestAsyncPart({id, timeoutSeconds = 60, title}) async {
  const maxProgress = 100;

  var startTime = DateTime.now();
  var endTime = startTime.add(Duration(seconds: timeoutSeconds));

  var currentProgress = 0;
  while (currentProgress < maxProgress){
    currentProgress = _getCurrentProgress(startTime, endTime);
    _reconcileNotification(id: id, progress: currentProgress, title: title);
    // according to https://pub.dev/packages/awesome_notifications#-full-screen-notifications-only-for-android
    // the update interval of the notification should not exceed one second
    await Future.delayed(const Duration(seconds: 5));
  }
}

/* normal case: returns an int value between 0 and 100 reflecting the progress
*  in percent.
*  exceeded case: note that it can actually return a value higher than 100 and
*  it is the callers responsibility to handle that as well.
* */
int _getCurrentProgress(DateTime startTime, DateTime endTime) {
  int maxDurationSeconds = endTime.difference(startTime).inSeconds;
  int secondsTillStartTime = DateTime.now().difference(startTime).inSeconds;
  var ratio = secondsTillStartTime / maxDurationSeconds;
  double ratioInPercent = ratio * 100;
  return ratioInPercent.toInt();
}

void _reconcileNotification({int id = 0, int progress = 0, title}) async {
  var notificationAlreadyExpired = authRequestNotificationStateHistory.any(
          (map) => map.containsKey(id));
  log.finer("authRequestNotificationStateHistory=$authRequestNotificationStateHistory ${Isolate.current.debugName}");
  if (notificationAlreadyExpired) { 
    log.finer("notificationAlreadyExpired: ($id): $notificationAlreadyExpired");
    return;
  }
  if (progress < 100) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          title: title + " ($id)",
          channelKey: authRequestsNotificationChannelKey,
          notificationLayout: NotificationLayout.ProgressBar,
          progress: progress.toDouble(),
          category: NotificationCategory.Alarm,
          criticalAlert: true,
          wakeUpScreen: true,
          fullScreenIntent: true,
          displayOnBackground: true,
          displayOnForeground: true,
          autoDismissible: false,
          locked: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'DENY',
            label: 'Deny',
            color: Colors.red,
            showInCompactView: false,
            actionType: ActionType.SilentAction
          ),
          NotificationActionButton(
            key: 'APPROVE',
            label: 'Approve',
            color: Colors.lightGreenAccent,
            showInCompactView: false,
            actionType: ActionType.SilentAction
          )
        ]
    );
  } else {
    var auth = await getLazyAuthMode();
    authRequestNotificationStateHistory.add({id: auth});
    AwesomeNotifications().cancel(id);
    var message = "notification timed out, applying default action: auth=$auth";
    if (auth) {
      log.info(message);
    } else {
      log.severe(message);
    }
  }
}