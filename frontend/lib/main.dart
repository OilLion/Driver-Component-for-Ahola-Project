import 'package:flutter/material.dart';
import 'package:frontend/client.dart';
import 'loginScreen.dart';

void main() {
      WidgetsFlutterBinding.ensureInitialized();
      UserManagerService().init();
      RouteManagerService().init();
      StatusUpdaterService().init();
      runApp(
        MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 203, 4, 62),
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                color: Color.fromARGB(255, 51, 1, 40),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  fixedSize: const Size(200, 30),
                )
              )
            ),
            home: const DriverApp()),
      );
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DRIVER APP"),
      ),
      body: const LoginScreen(),
    );
  }
}