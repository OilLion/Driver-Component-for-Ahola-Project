import 'package:flutter/material.dart';
import 'package:frontend/client.dart';
import 'loginScreen.dart';

void main() {
      WidgetsFlutterBinding.ensureInitialized();
      UserManagerService().init();
      RouteManagerService().init();
      StatusUpdaterService().init();
      runApp(
        const MaterialApp(home: MyApp()),
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver App"),
      ),
      body: const LoginScreen(),
    );
  }
}