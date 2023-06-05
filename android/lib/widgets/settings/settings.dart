import 'package:android/secure_storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';

final settingsProviderRestApiPort = FutureProvider<int>((ref) async {
  return await getRestApiPort();
});

final wifiIpProviderV4 = FutureProvider<String?>((ref) async {
  final info = NetworkInfo();
  return info.getWifiIP();
});

class Settings extends ConsumerWidget {
  const Settings({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<int> restApiPort = ref.watch(settingsProviderRestApiPort);
    AsyncValue<String?> ipv4 = ref.watch(wifiIpProviderV4);

    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text('Authentication/Authorization'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.password),
              title: const Text('Key'),
              description: const Text('This key must match your linux '
                  'device key in /etc/alp/alp.yaml'),
              value: const TextField(
                autocorrect: false,
                obscureText: true,
              ),
              trailing: InkWell(
                  onTap: () => {},
                  child: const Icon(Icons.remove_red_eye_outlined)),
            ),
            SettingsTile.switchTile(
              leading: const Icon(Icons.policy),
              title: const Text('Treat timeout as success'),
              description: const Text('enabling this setting is dangerous!'),
              initialValue: false,
              trailing: Switch(value: false, onChanged: (value) {}),
              onToggle: (bool value) {},
            ),
          ],
        ),
        SettingsSection(
          title: const Text('Rest API Server'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.numbers),
              title: const Text('Port'),
              value: TextFormField(
                  initialValue: restApiPort.toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered
              ),
            ),
            ipv4.when(
              data: (ip) => SettingsTile.navigation(
                leading: const Icon(Icons.numbers),
                title: const Text('IP (v4)'),
                description: const Text('readonly'),
                value: Text(ip ?? "")),
              error: (err, stack) => SettingsTile.navigation(
                leading: const Icon(Icons.numbers),
                title: const Text('IP (v4)'),
                description: const Text('readonly'),
                value: Text(err.toString()),
                trailing: const Icon(Icons.error)),
              loading: () => SettingsTile.navigation(
                leading: const Icon(Icons.numbers),
                title: const Text('IP (v4)'),
                description: const Text('readonly'),
                value: const Text(""),
                trailing: const Icon(Icons.sync))
              ),
          ],
        ),
      ],
    );
  }
}
