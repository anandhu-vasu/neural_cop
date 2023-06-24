import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:neural_cop/utils/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    Timer(Duration(seconds: 5), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('login') == true) {
        navigatorKey.currentState?.popAndPushNamed('/home');
      } else {
        navigatorKey.currentState?.popAndPushNamed('/login');
      }
      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/img/neuralcop.jpeg"),
          SizedBox(
            height: 20,
          ),
          Text(
            'NeuralCop',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white70),
          )
        ],
      )),
    );
  }
}
