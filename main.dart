// @dart=2.9
import 'package:flutter/material.dart';
import 'package:notes_app/screens/home.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

