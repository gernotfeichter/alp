import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications/android_foreground_service.dart';
import 'package:flutter/material.dart';

import 'controller.dart';

var lastNotificationId = 0;

configureNotifications() {
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
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
      onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
  );

  var id = lastNotificationId + 1;
  var timeoutSeconds = 15;
  const maxProgress = 100;

  var startTime = DateTime.now();
  var endTime = startTime.add(Duration(seconds: timeoutSeconds));

  var currentProgress = 0;
  while (currentProgress < maxProgress){
    currentProgress = getCurrentProgress(startTime, endTime);
    _reconcileNotification(id: id, progress: currentProgress);
    // according to https://pub.dev/packages/awesome_notifications#-full-screen-notifications-only-for-android
    // the update interval of the notification should not exceed one second
    sleep(const Duration(milliseconds: 100));
  }
}

/* normal case: returns an int value between 0 and 100 reflecting the progress
*  in percent.
*  exceeded case: note that it can actually return a value higher than 100 and
* it is the callers responsibility to handle that as well.
* */
int getCurrentProgress(DateTime startTime, DateTime endTime) {
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
          body: 'Simple body',
          title: 'Simple Notification',
          channelKey: 'basic_channel',
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
          ),
          NotificationActionButton(
            key: 'APPROVE',
            label: 'Approve',
            color: Colors.lightGreenAccent,
          )
        ]
    );
  } else {
    AwesomeNotifications().cancel(id);
  }
}

void _reconcileNotificationForegroudService({int id = 0, int progress = 0}) {
  AndroidForegroundService.startAndroidForegroundService(
      foregroundStartMode: ForegroundStartMode.stick,
      foregroundServiceType: ForegroundServiceType.mediaPlayback,
      content: NotificationContent(
        id: id,
        body: 'Service is running!',
        title: 'Android Foreground Service',
        channelKey: 'basic_channel',
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
}
