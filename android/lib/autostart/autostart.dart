import 'dart:async';
import 'package:flutter/services.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';
import '../logging/logging.dart';

Future<void> init() async {
  try {
    //check auto-start availability.
    var autoStartPermissionAvailable = await (isAutoStartAvailable as FutureOr<bool>);
    //if available then navigate to auto-start setting page.
    if (autoStartPermissionAvailable) await getAutoStartPermission();
  } on PlatformException catch (e) {
    log.severe("Could not verify autostart permission: $e");
  }
}
