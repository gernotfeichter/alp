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
  // AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //         id: 10,
  //         channelKey: 'basic_channel',
  //         title: 'Simple Notification',
  //         body: 'Simple body',
  //         actionType: ActionType.Default,
  //     )
  // );
  var notificationId = lastNotificationId + 1;
  var i = 0;
  while (i < 15){
    _reconcileNotification(id: notificationId, progress: i);
    i++;
    // according to https://pub.dev/packages/awesome_notifications#-full-screen-notifications-only-for-android
    // the update interval of the notification should not exceed one second
    sleep(const Duration(milliseconds: 500));
  }
}

void _reconcileNotification({int id = 0, int progress = 0}) {
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
