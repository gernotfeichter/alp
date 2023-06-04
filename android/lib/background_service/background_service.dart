
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
      isForegroundMode: true,

      foregroundServiceNotificationId: foregroundServiceNotificationId,
      notificationChannelId: notificationChannelKey, // this channel must be created before calling this, see notifications.dart:init
      initialNotificationTitle: notificationMessage,
      initialNotificationContent: "",
    ),
    iosConfiguration: IosConfiguration()
  );
  await service.startService();
}

Future<void> createNotificationBackgroundService(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        createNotificationForegroundService();
      }
    }
  });
}

