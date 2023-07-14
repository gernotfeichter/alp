
  // this will be used as notification channel id
import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import '../init/init.dart' as init_lib;

Future init() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: backgroundService,


      // auto start service
      autoStart: true,
      autoStartOnBoot: true,
      isForegroundMode: false,
    ),
    iosConfiguration: IosConfiguration()
  );
  await service.startService();
}

@pragma('vm:entry-point')
Future<void> backgroundService(ServiceInstance service) async {
  init_lib.init();
}
