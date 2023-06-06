import 'package:android/secure_storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';

final keyProvider = FutureProvider<String>((ref) async {
  return getKey();
});

final lazyAuthProvider = FutureProvider<bool>((ref) async {
  return getLazyAuthMode();
});

final restApiPortProvider = FutureProvider<int>((ref) async {
  return getRestApiPort();
});

final wifiIpV4Provider = FutureProvider<String?>((ref) async {
  final info = NetworkInfo();
  return info.getWifiIP();
});

final wifiIpV6Provider = FutureProvider<String?>((ref) async {
  final info = NetworkInfo();
  return info.getWifiIPv6();
});

var obscureText = true;
final obscureTextProvider = StateProvider<bool>((ref) => obscureText);

void toggleObscureText(WidgetRef ref) {
  ref.read(obscureTextProvider.notifier).state =
      !ref.read(obscureTextProvider.notifier).state;
}

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<String> decryptionKey = ref.watch(keyProvider);
    bool obscureTextWatched = ref.watch(obscureTextProvider);
    AsyncValue<bool> lazyAuth = ref.watch(lazyAuthProvider);
    AsyncValue<int> restApiPort = ref.watch(restApiPortProvider);
    AsyncValue<String?> ipv4 = ref.watch(wifiIpV4Provider);
    AsyncValue<String?> ipv6 = ref.watch(wifiIpV6Provider);

    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text('Authentication/Authorization'),
          tiles: <SettingsTile>[
            decryptionKey.when(
                data: (k) => SettingsTile.navigation(
                    leading: const Icon(Icons.password),
                    title: const Text('Key'),
                    description: const Text('This key must match your linux '
                        'device key in /etc/alp/alp.yaml. Hint: may Lose Google Lens to scan it.'),
                    value: Container(
                      color: k == '' ? Colors.red : null,
                      child: TextFormField(
                        initialValue: k,
                        autocorrect: false,
                        obscureText: obscureTextWatched,
                        onChanged: (value) {
                          setKey(value);
                          ref.invalidate(keyProvider);
                        },
                      ),
                    ),
                    trailing: InkWell(
                      onTap: () {
                          toggleObscureText(ref);
                        },
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: obscureTextWatched
                            ? const Icon(Icons.remove_red_eye, size: 30)
                            : const Icon(Icons.remove_red_eye_outlined,
                                size: 30),
                      ),
                    )),
                error: (err, stack) => SettingsTile.navigation(
                    leading: const Icon(Icons.password),
                    title: const Text('Key'),
                    description: const Text('This key must match your linux '
                        'device key in /etc/alp/alp.yaml'),
                    value: Text(err.toString()),
                    trailing: const Icon(Icons.error)),
                loading: () => SettingsTile.navigation(
                    leading: const Icon(Icons.password),
                    title: const Text('Key'),
                    description: const Text('This key must match your linux '
                        'device key in /etc/alp/alp.yaml'),
                    trailing: const CircularProgressIndicator())),
            lazyAuth.when(
              data: (lazyAuth) => SettingsTile.switchTile(
                  leading: const Icon(Icons.policy),
                  title: const Text('Lazy auth mode'),
                  description: const Text(
                      'Treat timeout as success, dangerous!'),
                  initialValue: lazyAuth,
                  trailing: Switch(
                      value: lazyAuth,
                      onChanged: (value) {
                        setLazyAuthMode(value);
                        ref.invalidate(lazyAuthProvider);
                      }
                  ),
                  onToggle: (bool value) {},
              ),
              error: (err, stack) => SettingsTile.switchTile(
                leading: const Icon(Icons.policy),
                title: Text(err.toString()),
                description: const Text(
                    'Treat timeout as success, dangerous!'),
                initialValue: false,
                trailing: const Icon(Icons.error),
                onToggle: (bool value) {  },
              ),
              loading: () =>  SettingsTile.switchTile(
                leading: const Icon(Icons.policy),
                title: const Text(''),
                description: const Text(
                'Treat timeout as success, dangerous!'),
                initialValue: false,
                trailing: const CircularProgressIndicator(),
                onToggle: (bool value) {  },
              )
            ),
          ],
        ),
        SettingsSection(
          title: const Text('Rest API Server'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.numbers),
              title: const Text('Port'),
              value: restApiPort.when(
                  data: (value) => TextFormField(
                        initialValue: value.toString(),
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: false, decimal: false),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) => setRestApiPort(int.parse(value)),
                      ),
                  error: (err, stack) => Text(err.toString()),
                  loading: () => const CircularProgressIndicator()),
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
                    trailing: const CircularProgressIndicator())),
            ipv6.when(
                data: (ip) => SettingsTile.navigation(
                    leading: const Icon(Icons.numbers),
                    title: const Text('IP (v6)'),
                    description: const Text('readonly'),
                    value: Text(ip ?? "")),
                error: (err, stack) => SettingsTile.navigation(
                    leading: const Icon(Icons.numbers),
                    title: const Text('IP (v6)'),
                    description: const Text('readonly'),
                    value: Text(err.toString()),
                    trailing: const Icon(Icons.error)),
                loading: () => SettingsTile.navigation(
                    leading: const Icon(Icons.numbers),
                    title: const Text('IP (v6)'),
                    description: const Text('readonly'),
                    value: const Text(""),
                    trailing: const CircularProgressIndicator())),
          ],
        ),
      ],
    );
  }
}
