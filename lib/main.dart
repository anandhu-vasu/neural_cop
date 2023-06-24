import 'package:flutter/material.dart';
import 'package:neural_cop/utils/globals.dart';
import 'package:neural_cop/views/home_view.dart';
import 'package:neural_cop/views/splash_view.dart';
import './views/login_view.dart';
import 'controllers/notification_controller.dart';

Future<void> main() async {
  await NotificationController.initializeLocalNotifications();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    NotificationController.startListeningNotificationEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashView(),
        '/login': (context) => LoginView(),
        '/home': (context) => HomeView()
      },
      darkTheme: ThemeData(
        colorScheme: ColorScheme(
            brightness: Brightness.dark,
            primary: Color.fromARGB(255, 170, 2, 58),
            onPrimary: Colors.white70,
            secondary: Colors.grey.shade800,
            onSecondary: Colors.grey.shade100,
            error: Colors.red.shade400,
            onError: Colors.red.shade100,
            background: const Color.fromRGBO(21, 21, 21, 1),
            onBackground: Colors.white60,
            surface: const Color.fromRGBO(21, 21, 21, 1),
            onSurface: Colors.white60),
        scaffoldBackgroundColor: const Color.fromRGBO(21, 21, 21, 1),
        cardColor: Colors.grey.shade900,
      ),
      themeMode: ThemeMode.dark,
    );
  }
}
