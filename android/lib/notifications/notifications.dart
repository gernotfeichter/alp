import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications/android_foreground_service.dart';
import 'package:flutter/material.dart';

import '../logging/logging.dart';
import 'event-handler.dart';

var lastNotificationId = 0;

Future init() async{
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      'resource://drawable/res_app_icon', // TODO: Gernot
      [
        NotificationChannel(
            channelKey: 'alp',
            channelName: 'Alp notifications',
            channelDescription: 'Notification channel for alp (android-linux-pam project) - Authentication Requests from Linux',
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

void createNotification() {
  log.info("createNotification called");
  var id = lastNotificationId + 1;
  var timeoutSeconds = 60;
  const maxProgress = 100;
  
  var startTime = DateTime.now();
  var endTime = startTime.add(Duration(seconds: timeoutSeconds));
  
  var currentProgress = 0;
  while (currentProgress < maxProgress){
    currentProgress = _getCurrentProgress(startTime, endTime);
    _reconcileNotification(id: id, progress: currentProgress);
    // according to https://pub.dev/packages/awesome_notifications#-full-screen-notifications-only-for-android
    // the update interval of the notification should not exceed one second
    sleep(const Duration(milliseconds: 5000));
  }
}

/* normal case: returns an int value between 0 and 100 reflecting the progress
*  in percent.
*  exceeded case: note that it can actually return a value higher than 100 and
* it is the callers responsibility to handle that as well.
* */
int _getCurrentProgress(DateTime startTime, DateTime endTime) {
  int maxDurationSeconds = endTime.difference(startTime).inSeconds;
  int secondsTillStartTime = DateTime.now().difference(startTime).inSeconds;
  var ratio = secondsTillStartTime / maxDurationSeconds;
  double ratioInPercent = ratio * 100;
  return ratioInPercent.toInt();
}

void _reconcileNotification({int id = 0, int progress = 0}) {
  if (progress < 100) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          title: 'Alp auth request',
          channelKey: 'alp',
          notificationLayout: NotificationLayout.ProgressBar,
          progress: progress,
          wakeUpScreen: true,
          fullScreenIntent: true,
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
    AwesomeNotifications().cancel(id);
  }
}

// TODO: Gernot maybe won't need this ever again
/*void _reconcileNotificationForegroudService({int id = 0, int progress = 0}) {
  AndroidForegroundService.startAndroidForegroundService(
      foregroundStartMode: ForegroundStartMode.stick,
      foregroundServiceType: ForegroundServiceType.mediaPlayback,
      content: NotificationContent(
        id: id,
        body: 'Service is running!',
        title: 'Android Foreground Service',
        channelKey: 'alp',
        bigPicture: 'asset://assets/images/android-bg-worker.jpg',
        notificationLayout: NotificationLayout.ProgressBar,
        category: NotificationCategory.Service,
        fullScreenIntent: true,
        progress: progress,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'APPROVE',
          label: 'Approve',
          color: Colors.lightGreenAccent,
        ),
        NotificationActionButton(
          key: 'DENY',
          label: 'Deny',
          color: Colors.red,
        )
      ]
  );
}*/
