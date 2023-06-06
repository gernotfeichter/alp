import 'package:android/widgets/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'init/init.dart' as init;

void main() {
  runApp(const ProviderScope(child: Home()));
  init.init();
}
