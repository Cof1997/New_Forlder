import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:test_sound/edit_audio.dart';
import 'home.dart';

void main() {
  // var _routes = <String, WidgetBuilder>{
  //   "/edit": (BuildContext context) =>
  //   new EditAudio(),
  // };
  // runApp(new MaterialApp(home: new Scaffold(body: new AudioApp())));
  runApp(new MaterialApp(home: ExampleApp(),debugShowCheckedModeBanner: false,));
}

Future<Null> _configure() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: "",
    options: FirebaseOptions(
        googleAppID: "1:808867989205:android:68c6a64dc663e010",
        apiKey: "AIzaSyAHf1SekrX9Tym4ZcVav8xXF3_UtgbY7xg",
        databaseURL: "https://audioonline-3fe06.firebaseio.com"),
  );
  assert(app != null);
  print('Configured $app');
}