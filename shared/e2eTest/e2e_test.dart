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
  final flutterBuild = await Process.run('flutter', ['build', 'apk', '--release'], workingDirectory: androidDir);
  if (flutterBuild.exitCode != 0) {
    print('Error compiling Android app: ${flutterBuild.stderr}');
    exit(1);
  }
  print('Android app compiled successfully.');

  // 3. Install and Configure Android app
  print('\n[3/7] Installing and configuring Android app via integration test...');

  await dismissSystemDialogs();

  // Pre-grant notification permission
  await Process.run('adb', ['shell', 'pm', 'grant', 'io.github.gernotfeichter.alp', 'android.permission.POST_NOTIFICATIONS']);

  // Start the integration test in the background
  final flutterTestProcess = await Process.start(
    'flutter',
    ['test', 'integration_test/setup_test.dart', '-d', 'emulator-5554'],
    workingDirectory: androidDir
  );

  final setupCompleter = Completer<void>();
  bool setupSuccessful = false;

  flutterTestProcess.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
    if (line.isNotEmpty) print('[Android Setup] $line');
    if (line.contains('SETUP_DONE')) {
      setupSuccessful = true;
      if (!setupCompleter.isCompleted) setupCompleter.complete();
    }
  });

  flutterTestProcess.stderr.transform(utf8.decoder).listen((data) {
    if (data.isNotEmpty) print('[Android Setup ERROR] $data');
  });

  // Periodically check for system dialogs during setup
  final dialogTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
    dismissSystemDialogs();
    if (setupSuccessful) timer.cancel();
  });

  try {
    await setupCompleter.future.timeout(const Duration(minutes: 5));
    dialogTimer.cancel();
  } catch (e) {
    print('Timeout waiting for Android setup to complete.');
    dialogTimer.cancel();
    flutterTestProcess.kill();
    exit(1);
  }

  print('Android app configured successfully.');

  // 4. Setup Port Forwarding
  print('\n[4/7] Setting up port forwarding and verifying server...');
  await Process.run('adb', ['forward', '--remove', 'tcp:7654']);
  final adbForward = await Process.run('adb', ['forward', 'tcp:7654', 'tcp:7654']);
  if (adbForward.exitCode != 0) {
    print('Error setting up adb forward: ${adbForward.stderr}');
    flutterTestProcess.kill();
    exit(1);
  }
  print('Port forwarding established (7654 -> 7654).');

  print('Waiting for REST server to start on port 7654...');
  bool serverStarted = false;
  for (int i = 0; i < 30; i++) {
    final netstat = await Process.run('adb', ['shell', 'netstat -ant | grep 7654']);
    if (netstat.stdout.toString().contains('LISTEN')) {
      print('REST server is listening on port 7654.');
      serverStarted = true;
      break;
    }
    await Future.delayed(const Duration(seconds: 1));
  }

  if (!serverStarted) {
    print('Error: REST server failed to start within 30 seconds.');
    flutterTestProcess.kill();
    exit(1);
  }

  // 5. Run Linux Auth (Async)
  print('\n[5/7] Starting Linux auth process...');
  final linuxAuthProcess = await Process.start(
    './alp',
    ['auth', '--config', '$sharedE2eDir/alp_test.yaml'],
    workingDirectory: linuxDir
  );

  bool authRequestSent = false;
  linuxAuthProcess.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((data) {
    if (data.isNotEmpty) print('[Linux Auth] $data');
    if (data.contains('sending auth request to connected device')) {
      authRequestSent = true;
    }
  });

  linuxAuthProcess.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((data) {
    if (data.isNotEmpty) print('[Linux Auth ERROR] $data');
    if (data.contains('sending auth request to connected device')) {
      authRequestSent = true;
    }
  });

  // 6. Wait for notification and Approve via ADB
  print('\n[6/7] Waiting for notification and approving via ADB...');

  int retry = 0;
  while (!authRequestSent && retry < 15) {
    await Future.delayed(Duration(seconds: 1));
    retry++;
  }

  if (!authRequestSent) {
    print('Timeout waiting for auth request to be sent.');
    linuxAuthProcess.kill();
    flutterTestProcess.kill();
    exit(1);
  }

  await Future.delayed(Duration(seconds: 5));
  await openNotificationShade();

  bool approved = false;
  for (int attempt = 0; attempt < 5; attempt++) {
    print('Searching for APPROVE button (attempt ${attempt + 1})...');
    final uiDump = await Process.run('adb', ['shell', 'uiautomator', 'dump', '/sdcard/view.xml']);
    await Process.run('adb', ['pull', '/sdcard/view.xml', '/tmp/view.xml']);
    final content = await File('/tmp/view.xml').readAsString();

    final match = RegExp(r'text="APPROVE"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', caseSensitive: false).firstMatch(content);
    if (match != null) {
      final x1 = int.parse(match.group(1)!);
      final y1 = int.parse(match.group(2)!);
      final x2 = int.parse(match.group(3)!);
      final y2 = int.parse(match.group(4)!);
      final centerX = (x1 + x2) ~/ 2;
      final centerY = (y1 + y2) ~/ 2;
      print('Found APPROVE button at ($centerX, $centerY). Tapping...');
      await Process.run('adb', ['shell', 'input', 'tap', '$centerX', '$centerY']);
      approved = true;
      break;
    } else {
       if (content.contains('alp')) {
         print('Notification from "alp" found but no APPROVE button. Attempting to expand...');
         // Try to find an expand button
         final expandMatch = RegExp(r'content-desc="Expand"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"').firstMatch(content);
         if (expandMatch != null) {
            final ex1 = int.parse(expandMatch.group(1)!);
            final ey1 = int.parse(expandMatch.group(2)!);
            final ex2 = int.parse(expandMatch.group(3)!);
            final ey2 = int.parse(expandMatch.group(4)!);
            await Process.run('adb', ['shell', 'input', 'tap', '${(ex1+ex2)~/2}', '${(ey1+ey2)~/2}']);
         } else {
            await Process.run('adb', ['shell', 'input', 'keyevent', '20']); // DPAD_DOWN
         }
         await Future.delayed(Duration(milliseconds: 1000));
       } else {
         print('No "alp" notification found in UI dump.');
       }
       await Future.delayed(Duration(seconds: 2));
    }
  }

  if (!approved) {
    print('Failed to find or click APPROVE button.');
    await Process.run('adb', ['shell', 'cmd', 'statusbar', 'collapse']);
  }

  // 7. Verify Success
  print('\n[7/7] Verifying authentication success...');
  final authExitCode = await linuxAuthProcess.exitCode;

  // Cleanup
  flutterTestProcess.kill(ProcessSignal.sigkill);
  linuxAuthProcess.kill(ProcessSignal.sigkill);

  if (authExitCode == 0) {
    print('\nSUCCESS: Authentication successful!');
    exit(0);
  } else {
    print('\nFAILURE: Authentication failed with exit code $authExitCode');
    exit(1);
  }
}

Future<void> dismissSystemDialogs() async {
  try {
    await Process.run('adb', ['shell', 'uiautomator', 'dump', '/sdcard/view_dismiss.xml']);
    await Process.run('adb', ['pull', '/sdcard/view_dismiss.xml', '/tmp/view_dismiss.xml']);
    final content = await File('/tmp/view_dismiss.xml').readAsString();

    if (content.contains('com.android.systemui:id/internet_connectivity_dialog') ||
        content.contains('android:id/alertTitle') ||
        content.contains('Wait') || content.contains('Close app')) {
      print('System dialog detected. Pressing Back...');
      await Process.run('adb', ['shell', 'input', 'keyevent', '4']);
    }
  } catch (e) {
    // Ignore dump errors
  }
}

Future<void> openNotificationShade() async {
  print('Opening notification shade...');
  await Process.run('adb', ['shell', 'cmd', 'statusbar', 'expand-notifications']);
  await Future.delayed(Duration(seconds: 1));
}
