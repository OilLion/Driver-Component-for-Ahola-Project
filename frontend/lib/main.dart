import 'package:flutter/material.dart';
import 'loginScreen.dart';

void main() {
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