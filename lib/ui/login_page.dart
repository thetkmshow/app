import 'package:flutter/material.dart';
import 'package:thetkmshow/ui/homePage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:thetkmshow/ui/sign_in.dart';
// import 'package:thetkmshow/ui/success.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:thetkmshow/style/appColors.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title, this.analytics, this.observer})
      : super(key: key);
  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _LoginPageState createState() => _LoginPageState(analytics, observer);
}

class _LoginPageState extends State<LoginPage> {
  String fname = "";
  String femail = "";
  String fimage = "";
  _LoginPageState(this.analytics, this.observer);
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff384850),
              Color(0xff263238),
              Color(0xff263238),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(
                "https://thetkmshow.in/static/media/tkmshow_white.daed602d.png",
                height: 120,
              ),
              SizedBox(height: 50),
              _signInButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        signInWithGoogle().then((result) {
          if (result != null) {
            getDetails().then((value) {
              setState(() {
                fname = value[0];
                femail = value[1];
                fimage = value[2];
              });
            });
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return
                      // FirstScreen();
                      Show(
                          title: 'TKM Show App',
                          analytics: analytics,
                          observer: observer,
                          name: fname,
                          email: femail,
                          image: fimage);
                },
              ),
            );
          }
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              MdiIcons.google,
              color: accentLight,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
