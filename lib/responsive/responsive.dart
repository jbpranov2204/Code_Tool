import 'package:code_tool/Login/mobile_loginpage.dart';
import 'package:code_tool/Login/web_loginpage.dart';
import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  const Responsive({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        if (constrains.maxWidth < 600) {
          return MobileLoginPage();
        } else {
          return WebLoginPage();
        }
      },
    );
  }
}
