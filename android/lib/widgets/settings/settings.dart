import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
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
                )
            ),
            SettingsTile.switchTile(
                leading: const Icon(Icons.policy),
                title: const Text('Treat timeout as success'),
                description: const Text('enabling this setting is dangerous!'),
                initialValue: false,
                trailing: const Icon(Icons.warning),
                onToggle: (bool value) {  },
            ),
          ],
        ),
        SettingsSection(
          title: const Text('Rest API Server'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.numbers),
              title: const Text('Port'),
              value: const Text('7654'),
            ),
          ],
        ),
      ],
    );
  }
}
