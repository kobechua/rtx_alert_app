// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rtx_alert_app/firebase_options.dart';

import 'package:firebase_database/firebase_database.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:rtx_alert_app/services/auth.dart';
import 'package:rtx_alert_app/services/location.dart';
// import 'package:rtx_alert_app/services/session_listener.dart';
import 'package:workmanager/workmanager.dart';
import 'package:rtx_alert_app/pages/greeting_page/greeting_page.dart';

import 'package:provider/provider.dart';
import 'package:rtx_alert_app/pages/menu/app_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rtx_alert_app/services/notifications.dart';


void pingUser() async {
  DateTime datetime = DateTime.now();
  debugPrint("Pinged User: $datetime");
  FirebaseDatabase database = FirebaseDatabase.instance;
  
  await FirebaseMessaging.instance.requestPermission();
  final position = LocationHandler();
  position.getCurrentLocation();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  database.ref().child('Locations/$fcmToken').set({'last_location' : {'latitude': position.latitude, 'longitude': position.longitude}, 'timestamp': datetime.toString()});
}

void callbackDispatcher() {
 Workmanager().executeTask((task, inputData) {
 switch (task) {
  case pingUser:
    pingUser();
    break;
 }
 return Future.value(true);
 });
}

void schedulePeriodicTask() {
 Workmanager().registerPeriodicTask(
 'myPeriodicTask',
 'pingUser',
 frequency: const Duration(minutes: 15),
 inputData: <String, dynamic>{'key': 'value'},
 );
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  
  FirebaseAuthService auth = FirebaseAuthService();
  
  await FirebaseMessagingAPI().initNotifications();
  if (auth.user != null){
    auth.signOut();
  }
  pingUser();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    pingUser();
    // schedulePeriodicTask();
    // return SessionTimeOutListener(
    //   duration: const Duration(minutes : 10), onTimeOut: pingUser, onWarning: pingUser,
    //     child:
    //     ChangeNotifierProvider(
    //       create: (context) => AppSettings()..loadSettings(),
    //       child: const MaterialApp(
    //         home: GreetingPage(),
    //       ),
    //     ), 
    // );
    Timer(const Duration(minutes: 2), () {pingUser();});
    return ChangeNotifierProvider(
          create: (context) => AppSettings()..loadSettings(),
          child: const MaterialApp(
            home: GreetingPage(),
          ),
    );
  }
}


