
  // this will be used as notification channel id
import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import '../init/init.dart' as init_lib;

import '../notifications/notifications.dart';

Future init() async {
  DartPluginRegistrant.ensureInitialized();
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: foregroundService,

      // auto start service
      autoStart: true,
      autoStartOnBoot: true,
      isForegroundMode: true,

      foregroundServiceNotificationId: foregroundServiceNotificationId,
      notificationChannelId: foregroundServiceNotificationChannelKey, // this channel must be created before calling this, see notifications.dart:init
      initialNotificationTitle: foregroundServiceNotificationMessage,
      initialNotificationContent: foregroundServiceNotificationContent,
    ),
    iosConfiguration: IosConfiguration()
  );
  await service.startService();
}

Future<void> foregroundService(ServiceInstance service) async {
  init_lib.init();
}
