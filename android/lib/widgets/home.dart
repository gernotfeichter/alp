import 'package:alp/widgets/logs/logs.dart';
import 'package:alp/widgets/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return MaterialApp(
      initialRoute: "/home",
      routes: {
        "/home": (context) => const MyScaffold(Settings()),
        "/settings": (context) => const MyScaffold(Settings()),
        "/logs": (context) => const MyScaffold(Logs()),
      },
    );
  }
}

class MyScaffold extends StatelessWidget {
  final Widget page;

  const MyScaffold(this.page, { super.key });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(page.toStringShort()),
      ),
      body: page,
      drawer: Drawer(
        child: Material(
          child: ListView(
            children: [
              Container(padding: const EdgeInsets.only(top: 20),),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet_outlined),
                title: const Text("Logs"),
                onTap: () {
                  Navigator.pushNamed(context, '/logs');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}