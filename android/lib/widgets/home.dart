import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
          home: Drawer(
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
          )
      );
  }

}