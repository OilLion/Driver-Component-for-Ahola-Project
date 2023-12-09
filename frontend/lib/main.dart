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
                seedColor: Color.fromARGB(255, 203, 4, 62),
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                color: Color.fromARGB(255, 51, 1, 40),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 203, 4, 62),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  fixedSize: const Size(200, 30),
                )
              )
            ),
            home: MyApp()),
      );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: const Color.fromARGB(255, 51, 1, 40),
        title: const Text("DRIVER APP"),
      ),
      body: const LoginScreen(),
    );
  }
}