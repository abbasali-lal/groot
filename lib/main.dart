import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:groot/pages/mainpage.dart';

void main() {
  runApp(AudioRecorderApp());
}
// hello this is testing site
class AudioRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: MainPage(),
    );
  }
}
