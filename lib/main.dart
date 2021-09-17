import 'package:desafio/features/authentication/presentation/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('error');
          }

          if (snapshot.connectionState == ConnectionState.done) {
            print('connected');
            return _buildMaterialApp();
          }

          return Container();
        });
  }

  Widget _buildMaterialApp() {
    return MaterialApp(
      title: 'ByCoders',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
