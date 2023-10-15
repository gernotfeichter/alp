import 'package:alp/widgets/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'background_service/background_service.dart' as background_service;
import 'notifications/notifications.dart';

void main() {
  runApp(const ProviderScope(child: Home()));
  initNotificationPerm();
  background_service.init();
}
