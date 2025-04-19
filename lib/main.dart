import 'package:atom/responsive/responsive.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Code Tool',
      theme: ThemeData.dark(),
      home: Responsive(), // Set SplashScreen as the initial page
    );
  }
}
