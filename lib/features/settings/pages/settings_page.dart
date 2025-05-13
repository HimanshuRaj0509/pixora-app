/* Settings page
- Dark Mode
- Blocked Users
- Account settings
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixora/responsive/constrained_scaffold.dart';
import 'package:pixora/themes/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    //theme cubit
    final themeCubit = context.watch<ThemeCubit>();

    // is dark mode
    bool isDarkMode = themeCubit.isDarkMode;

    //Scaffold

    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          //dark mode
          ListTile(
            title: Text("Dark Mode"),
            trailing: CupertinoSwitch(
              value: isDarkMode,
              onChanged: (value) {
                themeCubit.toggleTheme();
              },
            ),
          )
        ],
      ),
    );
  }
}
