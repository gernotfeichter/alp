import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Android 17 (API 37) enforces `ACCESS_LOCAL_NETWORK` for traffic to and from
/// the local network. Older Android releases and other platforms still grant
/// local network access implicitly through the `INTERNET` permission.
bool get requiresLocalNetworkPermission =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Returns whether alp may currently receive connections from the local
/// network.
Future<bool> hasLocalNetworkPermission() async {
  if (!requiresLocalNetworkPermission) return true;
  return Permission.accessLocalNetwork.status.isGranted;
}

/// Requests broad local network access.
///
/// alp runs the server and the Linux client initiates the connection to this
/// device, so a system device picker cannot replace the runtime permission.
Future<bool> requestLocalNetworkPermission() async {
  if (!requiresLocalNetworkPermission) return true;
  final status = await Permission.accessLocalNetwork.request();
  return status.isGranted || await hasLocalNetworkPermission();
}

/// Opens the system app settings so a denied permission can be granted again.
Future<bool> openLocalNetworkSettings() => openAppSettings();
