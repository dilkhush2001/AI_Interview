import 'package:flutter/material.dart';
import 'package:projectspace/Mpage1.dart';
import 'package:projectspace/Mpage3.dart';

import 'Checking_Pro.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:App(),
    );
  }
}