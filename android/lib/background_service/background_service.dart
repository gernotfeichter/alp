
  // this will be used as notification channel id
import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import '../notifications/notifications.dart';

Future init() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: createNotificationBackgroundService,

      // auto start service
      autoStart: true,
      autoStartOnBoot: true,
      isForegroundMode: true,
      foregroundServiceNotificationId: foregroundServiceNotificationId,
      notificationChannelId: foregroundServiceNotificationChannelKey, // this channel must be created before calling this, see notifications.dart:init
      initialNotificationTitle: foregroundServiceNotificationMessage,
      initialNotificationContent: "You can disable this notification via android settings, but be sure to not disable all alp notifications but only this channel. Note that it is a requirement from android side, so I have to show this notification at first for this kind of permanently running service.",
    ),
    iosConfiguration: IosConfiguration()
  );
  await service.startService();
}

Future<void> createNotificationBackgroundService(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // bring to foreground
  Timer.periodic(const Duration(milliseconds: 500), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        createNotificationForegroundService();
      }
    }
  });
}
