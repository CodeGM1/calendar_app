import 'package:calendar_app/pages/homepage.dart';
import 'package:calendar_app/api_manager/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:timezone/data/latest.dart' as tz;

const color1 = Color(0xFFF2EFE9);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  print("Handling a background message: ${message.data}");

}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  tz.initializeTimeZones();
  location.enableBackgroundMode(enable: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar',
      theme: ThemeData(
        textTheme: TextTheme(bodyText1: TextStyle(fontSize: 22)),
        fontFamily: 'ProximaNova',
        canvasColor: Colors.white,
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(color: Colors.black),
        inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(fontSize: 22)

        )
      ),
      home: HomePage(title:'Calendar'),
    );
  }
}
