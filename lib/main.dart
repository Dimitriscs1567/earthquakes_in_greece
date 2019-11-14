import 'package:eartquakes_in_greece/ui/MainPage.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Earthquakes in Greece',
      home: MainPage(),
    );
  }
}