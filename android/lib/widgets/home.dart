import 'package:android/widgets/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            body: const Settings(),
            drawer: Drawer(
              child: Material(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text("Settings"),
                      onTap: () {
                      },
                    ),
                    ListTile(
                      title: const Text("Logs"),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}