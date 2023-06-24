import 'package:flutter/material.dart';
import 'package:neural_cop/utils/globals.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:map_launcher/map_launcher.dart';

void showSnackBar(String text, {MaterialColor? color, IconData? icon}) =>
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      // behavior: SnackBarBehavior.floating,
      // margin: EdgeInsets.all(5.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      elevation: 50,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color?[50] ?? Colors.white70,
            ),
            const SizedBox(
              width: 10,
            )
          ],
          Text(
            text,
            style: TextStyle(fontSize: 18, color: color?[50] ?? Colors.white70),
          )
        ],
      ),
      backgroundColor: color?[400] ?? Colors.black87,
    ));

Future<String?> promptHostname() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? hostname = prefs.getString("hostname");
  var value = await prompt(
    navigatorKey.currentContext!,
    title: const Text("API HOST URL"),
    initialValue: hostname,
    hintText: "http://192.168.0.1:8000",
    validator: (String? value) {
      if (value == null || value.isEmpty) {
        return 'Enter a url.';
      }
      return null;
    },
    autoFocus: true,
  );
  if (value != null) {
    prefs.setString("hostname", value);
  }
  return value;
}

Future<void> openMap(String latitude, String longitude) async {
  final availableMaps = await MapLauncher.installedMaps;

  await availableMaps.first.showMarker(
    coords: Coords(double.parse(latitude), double.parse(longitude)),
    title: "Threat!",
  );
}
