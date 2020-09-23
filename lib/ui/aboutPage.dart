import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:thetkmshow/helper/utils.dart';
import 'package:thetkmshow/style/appColors.dart';
import 'package:thetkmshow/ui/sign_in.dart';
import 'package:thetkmshow/ui/login_page.dart';

String version = "1.2.0";

class AboutPage extends StatelessWidget {
  AboutPage({this.name, this.email, this.image});

  final name;
  final email;
  final image;
  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          brightness: Brightness.dark,
          centerTitle: true,
          title: GradientText(
            "Stay In Touch",
            shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
            gradient: LinearGradient(colors: [
              Color(0xff4db6ac),
              Color(0xff61e88a),
            ]),
            style: TextStyle(
              color: accent,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: accent,
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: AboutCards(name: name, email: email, image: image)),
      ),
    );
  }
}

class AboutCards extends StatelessWidget {
  AboutCards({this.name, this.email, this.image});

  final name;
  final email;
  final image;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 6),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Image.network(
                    "https://thetkmshow.in/static/media/tkmshow_white.daed602d.png",
                    height: 120,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Center(
                        child: Text(
                      "thetkmshow  | " + version,
                      style: TextStyle(
                          color: accentLight,
                          fontSize: 24,
                          fontWeight: FontWeight.w600),
                    )),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 10, right: 10),
            child: Divider(
              color: Colors.white24,
              thickness: 0.8,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
            child: Card(
              color: Color(0xff263238),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 2.3,
              child: ListTile(
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                          "https://d3t3ozftmdmh3i.cloudfront.net/production/podcast_uploaded/6042015/6042015-1591172558348-8d8b77870bd83.jpg"),
                    ),
                  ),
                ),
                title: Text(
                  'Listen',
                  style: TextStyle(color: accentLight),
                ),
                subtitle: Text(
                  'Also at',
                  style: TextStyle(color: accentLight),
                ),
                trailing: Wrap(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        MdiIcons.spotify,
                        color: accentLight,
                      ),
                      tooltip: 'Spotify',
                      onPressed: () {
                        launchURL(
                            "https://open.spotify.com/show/7tmPClseHqoHF5bFYT0F2o");
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        MdiIcons.googlePodcast,
                        color: accentLight,
                      ),
                      tooltip: 'Google Podcasts',
                      onPressed: () {
                        launchURL(
                            "https://podcasts.google.com/?feed=aHR0cHM6Ly9hbmNob3IuZm0vcy8yNDliZjg5Yy9wb2RjYXN0L3Jzcw%3D%3D");
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        MdiIcons.podcast,
                        color: accentLight,
                      ),
                      tooltip: 'Apple Podcasts',
                      onPressed: () {
                        launchURL(
                            "https://podcasts.apple.com/in/podcast/the-tkm-show/id1517209911");
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
            child: Card(
              color: Color(0xff263238),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 2.3,
              child: ListTile(
                leading: Container(
                  width: 50.0,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                          "https://bmnidhin.github.io/t4lk-static/s1/pl1.jpg"),
                    ),
                  ),
                ),
                title: Text(
                  'Follow Us',
                  style: TextStyle(color: accentLight),
                ),
                subtitle: Text(
                  'Stay Updated',
                  style: TextStyle(color: accentLight),
                ),
                trailing: Wrap(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        MdiIcons.telegram,
                        color: accentLight,
                      ),
                      tooltip: 'Contact on Telegram',
                      onPressed: () {
                        launchURL("https://t.me/thetkmshow");
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        MdiIcons.instagram,
                        color: accentLight,
                      ),
                      tooltip: 'Instagram',
                      onPressed: () {
                        launchURL("https://www.instagram.com/_thetkmshow_/");
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
            child: Card(
              color: Color(0xff263238),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 2.3,
              child: ListTile(
                leading: Container(
                  width: 50.0,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(image),
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: TextStyle(color: accentLight),
                ),
                subtitle: Text(
                  email,
                  style: TextStyle(color: accentLight),
                ),
                trailing: Wrap(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        MdiIcons.logout,
                        color: accentLight,
                      ),
                      tooltip: 'Logout',
                      onPressed: () {
                        signOutGoogle();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) {
                          return LoginPage();
                        }), ModalRoute.withName('/'));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
