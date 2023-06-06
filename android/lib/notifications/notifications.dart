import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/material.dart';
import '../logging/logging.dart';
import 'event_handler.dart';

const foregroundServiceNotificationChannelKey = 'alp_foreground_service';
const foregroundServiceNotificationMessage = 'Alp is running in background!';
const foregroundServiceNotificationId = 1;
const authRequestsNotificationChannelKey = 'alp_auth_requests';
const authRequestsNotificationStartId = 2;

// for each of the last five notifications, contains a map(notification_id(int): approval state(bool))
// That means that one device can theoretically handle up to five concurrent auth requests
final authRequestNotificationStateHistory = CircularBuffer<Map<int,bool>>(5)..add({authRequestsNotificationStartId: false});

Future init() async{
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      'resource://drawable/res_app_icon', // TODO: Gernot
      [
        NotificationChannel(
            channelKey: foregroundServiceNotificationChannelKey,
            channelName: 'Alp service notifications (dismissing advised)',
            channelDescription: 'Service notification channel for alp (android-linux-pam project) - Authentication Requests from Linux'),
        NotificationChannel(
            channelKey: authRequestsNotificationChannelKey,
            channelName: 'Alp auth requests',
            channelDescription: 'Authentication requests channel for alp (android-linux-pam project) - Authentication Requests from Linux',
            defaultColor: Colors.black,
            ledColor: Colors.amber)
      ],
      debug: true
  );
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  AwesomeNotifications().setListeners(
      onActionReceivedMethod:         NotificationEventHandler.onActionReceivedMethod,
      onNotificationCreatedMethod:    NotificationEventHandler.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:  NotificationEventHandler.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:  NotificationEventHandler.onDismissActionReceivedMethod
  );
}

void createNotificationForegroundService() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: foregroundServiceNotificationId,
      channelKey: authRequestsNotificationChannelKey,
      summary: foregroundServiceNotificationMessage,
      notificationLayout: NotificationLayout.ProgressBar,
    ),
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
    sleep(const Duration(milliseconds: 5000));
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

void _reconcileNotification({int id = 0, int progress = 0, title}) {
  var notificationAlreadyExpired = authRequestNotificationStateHistory.any(
          (map) => map.containsKey(id));
  log.info(authRequestNotificationStateHistory);
  log.info("notificationAlreadyExpired: ($id): $notificationAlreadyExpired");
  if (notificationAlreadyExpired) { return; }
  if (progress < 100) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          title: title + " ($id)",
          channelKey: authRequestsNotificationChannelKey,
          notificationLayout: NotificationLayout.ProgressBar,
          progress: progress,
          wakeUpScreen: true,
          fullScreenIntent: true,
          displayOnBackground: true,
          displayOnForeground: true,
          locked: true,
          autoDismissible: false,
          showWhen: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'DENY',
            label: 'Deny',
            color: Colors.red,
            showInCompactView: true,
          ),
          NotificationActionButton(
            key: 'APPROVE',
            label: 'Approve',
            color: Colors.lightGreenAccent,
            showInCompactView: true,
          )
        ]
    );
  } else {
    authRequestNotificationStateHistory.add({id: false});
    AwesomeNotifications().cancel(id);
  }
}