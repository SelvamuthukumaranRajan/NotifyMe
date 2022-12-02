import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'helper_notification.dart';

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  //To handle background notification
}

final FlutterLocalNotificationsPlugin flutterNotificationPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
  List colors = [Colors.redAccent, Colors.greenAccent, Colors.orangeAccent];

  //Please add YOUR SERVER KEY
  final String SERVER_KEY = "";

  void getNotification() async {
    setState(() {
      index = 2;
    });
    String? token = await FirebaseMessaging.instance.getToken();
    var url = "https://fcm.googleapis.com/fcm/send";
    Uri uri = Uri.parse(url);
    Map data = {
      "to": token ?? "",
      "notification": {"title": "Hi selva", "body": "How are you?"}
    };
    var body = json.encode(data);
    //Provide your server key here to get notified.
    var response = await http.post(uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $SERVER_KEY",
        },
        body: body);
    if (response.statusCode == 200) {
      setState(() {
        index = 1;
      });
    } else {
      setState(() {
        index = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initiateNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors[index],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SERVER_KEY.isEmpty
              ? const Text("UPDATE YOUR FIREBASE SERVER KEY TO GET NOTIFIED !!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    height: 1.5,
                    color: Colors.white,
                  ))
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: getNotification,
        tooltip: 'Notification',
        child: const Icon(Icons.notifications),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void initiateNotification() async {
    await Firebase.initializeApp();
    //To get notification while opening the app
    await FirebaseMessaging.instance.getInitialMessage();
    await HelperNotification.initialize(flutterNotificationPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }
}
