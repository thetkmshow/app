import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:thetkmshow/ui/login_page.dart';
import 'package:thetkmshow/style/appColors.dart';

import 'package:thetkmshow/ui/sign_in.dart';
import 'package:thetkmshow/ui/success.dart';

// import 'package:thetkmshow/test.dart';
// D:\Nidhin_Projects\Android\thetkmshow\build\flutter_media_notification\intermediates\packaged_res\debug\drawable-xhdpi-v4
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "DMSans",
        accentColor: accent,
        primaryColor: accent,
        canvasColor: Colors.transparent,
      ),
      home: RoutePage(),
      // home: LoginPage(
      //   title: 'TKM Show App',
      //   analytics: analytics,
      //   observer: observer,
      // ),
      // home: Show(
      //   title: 'TKM Show App',
      //   analytics: analytics,
      //   observer: observer,
      // ),
    );
  }
}

class RoutePage extends StatefulWidget {
  @override
  RoutePageState createState() => RoutePageState();
}

class RoutePageState extends State<RoutePage> {
  bool isLoggedin = false;
  String fname = "";
  String femail = "";
  String fimage = "";
  @override
  void initState() {
    super.initState();
    print("Init state");
    autoLogin().then((value) {
      if (value == 'null') {
        print(isLoggedin);
        setState(() {
          isLoggedin = false;
        });
      } else if (value != null) {
        setState(() {
          isLoggedin = true;
        });
      } else {
        setState(() {
          isLoggedin = false;
        });
      }
    });
    getDetails().then((value) {
      setState(() {
        fname = value[0];
        femail = value[1];
        fimage = value[2];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedin == true
        ? FirstScreen(name: fname, email: femail, image: fimage)
        : LoginPage();
  }
}
