import 'package:android/widgets/logs/logs.dart';
import 'package:android/widgets/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget currentWidgetOuter = const Settings();
final navigationProvider = Provider<Widget>((ref) => currentWidgetOuter);

GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentWidget = ref.watch(navigationProvider);
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(currentWidget.toStringShort()),
        ),
        body: currentWidget,
        drawer: Drawer(
          child: Material(
            child: ListView(
              children: [
                ListTile(
                  title: const Text("Settings"),
                  onTap: () {
                    currentWidgetOuter = const Settings();
                    ref.invalidate(navigationProvider);
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                ),
                ListTile(
                  title: const Text("Logs"),
                  onTap: () {
                    currentWidgetOuter = const Logs();
                    ref.invalidate(navigationProvider);
                    _scaffoldKey.currentState?.openEndDrawer();
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