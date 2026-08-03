import 'package:alp/init/ui/init.dart';
import 'package:alp/widgets/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'logging/background_service/logging.dart' as logging;
import 'init/background_service/init.dart' as init;
import 'logging/ui/logging.dart';

final service = FlutterBackgroundService();

void main() async {
  runApp(const ProviderScope(child: Home()));

  // init
  // normally I add everything into separate in lib, but the author explicitly
  // said it is highly recommended to put this into main
  // https://pub.dev/packages/flutter_background_service
  // It's highly recommended to call this method in main() method to ensure the
  // callback handler updated.
  await initUi(service);
  service.invoke("stop"); // cleanup potentially old one still running
  await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: backgroundService,
        // auto start service
        autoStart: true,
        autoStartOnBoot: true,
        isForegroundMode: true,
        foregroundServiceNotificationId: 7654,
        initialNotificationTitle: "Alp Foreground Service running",
        initialNotificationContent: "Android requires to show this for permanently running services, but you may dismiss it!",
      ),
      iosConfiguration: IosConfiguration()
  );
  logging.sendLogsToUi = service.on('sendLogsToUi');
  await service.startService();
}

@pragma('vm:entry-point')
Future<void> backgroundService(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService(); // Call it immediately
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on("stop").listen((event) async {
    // Give other listeners (like REST server cleanup) a chance to run
    await Future.delayed(const Duration(milliseconds: 200));
    service.stopSelf();
  });
  await init.init(service);
}

Future<void> restartService() async {
  log.info("restarting service");
  service.invoke("stop");
  // Give it a moment to stop
  await Future.delayed(const Duration(milliseconds: 500));
  if (await service.isRunning()) {
    log.severe("after stopping the service, it is still running");
  }
  await service.startService();
  log.info("restarted service");
}
