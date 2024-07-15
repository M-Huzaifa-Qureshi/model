import 'package:flutter/material.dart';
import 'package:model_test/home_screen.dart';
import 'package:model_test/new_widget.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScrlBar(),
    );
  }
}
