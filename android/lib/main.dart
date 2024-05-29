import 'package:alp/widgets/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'init/init.dart' as init;

void main() async {
  runApp(const ProviderScope(child: Home()));

  // init
  // normally I add everything into separate in lib, but the author explicitly
  // said it is highly recommended to put this into main
  // https://pub.dev/packages/flutter_background_service
  // It's highly recommended to call this method in main() method to ensure the
  // callback handler updated.
  final service = FlutterBackgroundService();
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
  await service.startService();
}

@pragma('vm:entry-point')
Future<void> backgroundService(ServiceInstance service) async {
  await init.init();
}
