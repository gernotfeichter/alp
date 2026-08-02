import 'dart:io';
import 'dart:async';
import 'dart:convert';

Future<void> main() async {
  final projectRoot = '/home/nix/git/alp';
  final linuxDir = '$projectRoot/linux';
  final androidDir = '$projectRoot/android';
  final sharedE2eDir = '$projectRoot/shared/e2eTest';

  print('--- Starting E2E Test ---');

  // 1. Compile Linux app
  print('\n[1/7] Compiling Linux app...');
  final goBuild = await Process.run('go', ['build', '-o', 'alp', 'main.go'], workingDirectory: linuxDir);
  if (goBuild.exitCode != 0) {
    print('Error compiling Linux app: ${goBuild.stderr}');
    exit(1);
  }
  print('Linux app compiled successfully.');

  // 2. Compile Android app (release)
  print('\n[2/7] Compiling Android app (release apk)...');
  // Note: Building APK instead of just running so we can install it cleanly
  final flutterBuild = await Process.run('flutter', ['build', 'apk', '--release'], workingDirectory: androidDir);
  if (flutterBuild.exitCode != 0) {
    print('Error compiling Android app: ${flutterBuild.stderr}');
    exit(1);
  }
  print('Android app compiled successfully.');

  // 3. Install and Configure Android app
  print('\n[3/7] Installing and configuring Android app via integration test...');

  // Pre-grant notification permission to avoid popup
  await Process.run('adb', ['shell', 'pm', 'grant', 'io.github.gernotfeichter.alp', 'android.permission.POST_NOTIFICATIONS']);

  // This will install the app and run the setup_test.dart
  final flutterTest = await Process.run(
    'flutter',
    ['test', 'integration_test/setup_test.dart', '-d', 'emulator-5554'],
    workingDirectory: androidDir
  );
  if (flutterTest.exitCode != 0) {
    print('Error during Android app configuration: ${flutterTest.stdout}\n${flutterTest.stderr}');
    exit(1);
  }
  print('Android app configured successfully.');

  // 4. Setup Port Forwarding
  print('\n[4/7] Setting up port forwarding and starting app...');
  final adbForward = await Process.run('adb', ['forward', 'tcp:7654', 'tcp:7654']);
  if (adbForward.exitCode != 0) {
    print('Error setting up adb forward: ${adbForward.stderr}');
    exit(1);
  }
  print('Port forwarding established (7654 -> 7654).');

  // Start the app manually since integration test might have closed it
  print('Launching alp app...');
  await Process.run('adb', ['shell', 'monkey', '-p', 'io.github.gernotfeichter.alp', '-c', 'android.intent.category.LAUNCHER', '1']);
  await Future.delayed(Duration(seconds: 5)); // Wait for app to initialize and start server

  // 5. Run Linux Auth (Async)
  print('\n[5/7] Starting Linux auth process...');
  final linuxAuthProcess = await Process.start(
    './alp',
    ['auth', '--config', '$sharedE2eDir/alp_test.yaml'],
    workingDirectory: linuxDir
  );

  // Monitor stdout of linux auth
  bool authRequestSent = false;
  linuxAuthProcess.stdout.transform(utf8.decoder).listen((data) {
    print('[Linux Auth] $data');
    if (data.contains('sending auth request to connected device')) {
      authRequestSent = true;
    }
  });

  linuxAuthProcess.stderr.transform(utf8.decoder).listen((data) {
    print('[Linux Auth ERROR] $data');
  });

  // 6. Wait for notification and Approve via ADB
  print('\n[6/7] Waiting for notification and approving via ADB...');

  // Wait for the request to be sent
  int retry = 0;
  while (!authRequestSent && retry < 10) {
    await Future.delayed(Duration(seconds: 1));
    retry++;
  }

  if (!authRequestSent) {
    print('Timeout waiting for auth request to be sent.');
    linuxAuthProcess.kill();
    exit(1);
  }

  // Wait a bit for notification to appear on Android
  await Future.delayed(Duration(seconds: 3));

  // Automate approval.
  // Based on awesome_notifications, the button might be identified by text.
  // We can try to find the coordinates of the "APPROVE" button.
  print('Attempting to click APPROVE button via ADB...');

  // Dump UI to find button coordinates
  final uiDump = await Process.run('adb', ['shell', 'uiautomator', 'dump', '/sdcard/view.xml']);
  final pullXml = await Process.run('adb', ['pull', '/sdcard/view.xml', '/tmp/view.xml']);

  if (pullXml.exitCode == 0) {
    final content = await File('/tmp/view.xml').readAsString();
    // Look for node with text="APPROVE" or content-desc="APPROVE"
    // <node ... text="APPROVE" ... bounds="[x1,y1][x2,y2]" />
    final match = RegExp(r'text="APPROVE"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"').firstMatch(content);
    if (match != null) {
      final x1 = int.parse(match.group(1)!);
      final y1 = int.parse(match.group(2)!);
      final x2 = int.parse(match.group(3)!);
      final y2 = int.parse(match.group(4)!);
      final centerX = (x1 + x2) ~/ 2;
      final centerY = (y1 + y2) ~/ 2;
      print('Found APPROVE button at ($centerX, $centerY). Tapping...');
      await Process.run('adb', ['shell', 'input', 'tap', '$centerX', '$centerY']);
    } else {
      print('Could not find APPROVE button in UI dump. Trying fallback tap or broadcast.');
      // Fallback: Sometimes it might be capitalized or just "Approve"
      final matchLower = RegExp(r'text="Approve"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"').firstMatch(content);
      if (matchLower != null) {
         final x1 = int.parse(matchLower.group(1)!);
         final y1 = int.parse(matchLower.group(2)!);
         final x2 = int.parse(matchLower.group(3)!);
         final y2 = int.parse(matchLower.group(4)!);
         final centerX = (x1 + x2) ~/ 2;
         final centerY = (y1 + y2) ~/ 2;
         print('Found Approve button at ($centerX, $centerY). Tapping...');
         await Process.run('adb', ['shell', 'input', 'tap', '$centerX', '$centerY']);
      } else {
        print('Button not found. UI Dump content:');
        print(content.substring(0, content.length > 500 ? 500 : content.length));
      }
    }
  }

  // 7. Verify Success
  print('\n[7/7] Verifying authentication success...');
  final exitCode = await linuxAuthProcess.exitCode;
  if (exitCode == 0) {
    print('\nSUCCESS: Authentication successful!');
  } else {
    print('\nFAILURE: Authentication failed with exit code $exitCode');
    exit(1);
  }
}
