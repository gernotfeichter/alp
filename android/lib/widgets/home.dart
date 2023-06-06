import 'package:android/widgets/logs/logs.dart';
import 'package:android/widgets/settings/settings.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return MaterialApp(
      initialRoute: "/home",
      routes: {
        "/home": (context) => const Settings(),
        "/settings": (context) => const Settings(),
        "/logs": (context) => const Logs(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text(Navigator.of(context).toStringShort()),
        ),
        drawer: Drawer(
          child: Material(
            child: ListView(
              children: [
                ListTile(
                  title: const Text("Settings"),
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                ListTile(
                  title: const Text("Logs"),
                  onTap: () {
                    Navigator.pushNamed(context, '/logs');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}