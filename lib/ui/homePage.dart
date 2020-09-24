import 'dart:io';
import 'dart:ui';

import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:thetkmshow/API/saavn.dart';
import 'package:thetkmshow/music.dart';

import 'package:thetkmshow/style/appColors.dart';
import 'package:thetkmshow/ui/aboutPage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

const APP_STORE_URL = 'https://thetkmshow.in/app';
const PLAY_STORE_URL = 'https://thetkmshow.in/app';

class Person {
  final String name;
  final String age;

  Person(this.name, this.age);
}

// hold appstate
class Show extends StatefulWidget {
  Show(
      {Key key,
      this.title,
      this.analytics,
      this.observer,
      this.name,
      this.email,
      this.image})
      : super(key: key);
  final String title;
  final name;
  final email;
  final image;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  State<StatefulWidget> createState() {
    return AppState(analytics, observer, name, email, image);
  }
}

// functions, main page, carosal template
class AppState extends State<Show> {
  AppState(this.analytics, this.observer, this.name, this.email, this.uimage);
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  final name;
  final email;
  final uimage;
  String _message = '';
  @override
  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<void> _testSetCurrentScreen() async {
    await analytics.setCurrentScreen(
      screenName: "TKM Show Home",
      screenClassOverride: 'TheTkmShow',
    );
    debugPrint('Set Current Screen');
  }

  TextEditingController searchBar = TextEditingController();
  bool fetchingSongs = false;

  void initState() {
    try {
      versionCheck(context);
    } catch (e) {
      print(e);
    }
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xff1c252a),
      statusBarColor: Colors.transparent,
    ));

    MediaNotification.setListener('play', () {
      setState(() {
        playerState = PlayerState.playing;
        status = 'play';
        audioPlayer.play(kUrl);
      });
    });

    MediaNotification.setListener('pause', () {
      setState(() {
        status = 'pause';
        audioPlayer.pause();
      });
    });

    MediaNotification.setListener("close", () {
      audioPlayer.stop();
      dispose();
      checker = "Nahi";
      MediaNotification.hideNotification();
    });
  }

  search() async {
    String searchQuery = searchBar.text;
    if (searchQuery.isEmpty) return;
    fetchingSongs = true;
    setState(() {});
    await fetchSongsList(searchQuery);
    fetchingSongs = false;
    setState(() {});
    // await analytics.logEvent(
    //   name: 'search_intiated',
    //   parameters: <String, dynamic>{
    //     'string': 'string',
    //     'int': 42,
    //     'long': 12345678910,
    //     'double': 42.0,
    //     'bool': true,
    //   },
    // );
    debugPrint('Searched');
  }

  getSongDetails(String id, var context) async {
    try {
      await fetchSongDetails(id);
      print(kUrl);
    } catch (e) {
      artist = "Unknown";
      print(e);
    }
    setState(() {
      checker = "Haa";
    });
    // await analytics.logEvent(
    //   name: 'card_click',
    //   parameters: <String, dynamic>{
    //     'string': 'string',
    //     'int': 42,
    //     'long': 12345678910,
    //     'double': 42.0,
    //     'bool': true,
    //   },
    // );
    debugPrint('Card Clicked');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioApp(observer, analytics),
      ),
    );
  }

  downloadSong(id) async {
    String filepath;
    String filepath2;
    var status = await Permission.storage.status;
    if (status.isUndetermined || status.isDenied) {
      // code of read or write file in external storage (SD card)
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      debugPrint(statuses[Permission.storage].toString());
    }
    status = await Permission.storage.status;
    await fetchSongDetails(id);
    if (status.isGranted) {
      ProgressDialog pr = ProgressDialog(context);
      pr = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: false,
        showLogs: false,
      );

      pr.style(
        backgroundColor: Color(0xff263238),
        elevation: 4,
        textAlign: TextAlign.left,
        progressTextStyle: TextStyle(color: Colors.white),
        message: "Downloading " + title,
        messageTextStyle: TextStyle(color: accent),
        progressWidget: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      );
      await pr.show();

      final filename = title + ".m4a";
      final artname = title + "_artwork.jpg";
      //Directory appDocDir = await getExternalStorageDirectory();
      String dlPath = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_MUSIC);
      await File(dlPath + "/" + filename)
          .create(recursive: true)
          .then((value) => filepath = value.path);
      await File(dlPath + "/" + artname)
          .create(recursive: true)
          .then((value) => filepath2 = value.path);
      debugPrint('Audio path $filepath');
      debugPrint('Image path $filepath2');
      if (has_320 == "true") {
        kUrl = rawkUrl.replaceAll("_96.mp4", "_320.mp4");
        final client = http.Client();
        final request = http.Request('HEAD', Uri.parse(kUrl))
          ..followRedirects = false;
        final response = await client.send(request);
        debugPrint(response.statusCode.toString());
        kUrl = (response.headers['location']);
        debugPrint(rawkUrl);
        debugPrint(kUrl);
        final request2 = http.Request('HEAD', Uri.parse(kUrl))
          ..followRedirects = false;
        final response2 = await client.send(request2);
        if (response2.statusCode != 200) {
          kUrl = kUrl.replaceAll(".mp4", ".mp3");
        }
      }
      var request = await HttpClient().getUrl(Uri.parse(kUrl));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      File file = File(filepath);

      var request2 = await HttpClient().getUrl(Uri.parse(image));
      var response2 = await request2.close();
      var bytes2 = await consolidateHttpClientResponseBytes(response2);
      File file2 = File(filepath2);

      await file.writeAsBytes(bytes);
      await file2.writeAsBytes(bytes2);
      debugPrint("Started tag editing");

      final tag = Tag(
        title: title,
        artist: artist,
        artwork: filepath2,
        album: album,
        lyrics: lyrics,
        genre: null,
      );

      debugPrint("Setting up Tags");
      final tagger = Audiotagger();
      await tagger.writeTags(
        path: filepath,
        tag: tag,
      );
      await Future.delayed(const Duration(seconds: 1), () {});
      await pr.hide();

      if (await file2.exists()) {
        await file2.delete();
      }
      debugPrint("Done");
      Fluttertoast.showToast(
          msg: "Download Complete!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Color(0xff61e88a),
          fontSize: 14.0);
    } else if (status.isDenied || status.isPermanentlyDenied) {
      Fluttertoast.showToast(
          msg: "Storage Permission Denied!\nCan't Download Songs",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Color(0xff61e88a),
          fontSize: 14.0);
    } else {
      Fluttertoast.showToast(
          msg: "Permission Error!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.values[50],
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Color(0xff61e88a),
          fontSize: 14.0);
    }
  }

  getLiveDetails() async {
    try {
      await getLive();
      print(kUrl);
    } catch (e) {
      artist = "Unknown";
      print(e);
    }
    setState(() {
      checker = "Haa";
    });
    // await analytics.logEvent(
    //   name: 'live_card_click',
    //   parameters: <String, dynamic>{
    //     'string': 'string',
    //     'int': 42,
    //     'long': 12345678910,
    //     'double': 42.0,
    //     'bool': true,
    //   },
    // );
    debugPrint('Live Clicked');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioApp(observer, analytics),
      ),
    );
  }

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
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.transparent,
        //backgroundColor: Color(0xff384850),
        bottomNavigationBar: kUrl != ""
            ? Container(
                height: 75,
                //color: Color(0xff1c252a),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18)),
                    color: Color(0xff1c252a)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 2),
                  child: GestureDetector(
                    onTap: () {
                      checker = "Nahi";
                      if (kUrl != "") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AudioApp(observer, analytics)),
                        );
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: IconButton(
                            icon: Icon(
                              MdiIcons.appleKeyboardControl,
                              size: 22,
                            ),
                            onPressed: null,
                            disabledColor: accent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, top: 7, bottom: 7, right: 15),
                          //child: Image.network("https://sgdccdnems06.cdnsrv.jio.com/c.saavncdn.com/830/Music-To-Be-Murdered-By-English-2020-20200117040807-500x500.jpg"),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                title,
                                style: TextStyle(
                                    color: accent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                artist,
                                style:
                                    TextStyle(color: accentLight, fontSize: 10),
                              )
                            ],
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: playerState == PlayerState.playing
                              ? Icon(MdiIcons.pause)
                              : Icon(MdiIcons.playOutline),
                          color: accent,
                          splashColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              if (playerState == PlayerState.playing) {
                                audioPlayer.pause();
                                playerState = PlayerState.paused;
                                MediaNotification.showNotification(
                                    title: title,
                                    author: artist,
                                    artUri: image,
                                    isPlaying: false);
                              } else if (playerState == PlayerState.paused) {
                                audioPlayer.play(kUrl);
                                playerState = PlayerState.playing;
                                MediaNotification.showNotification(
                                    title: title,
                                    author: artist,
                                    artUri: image,
                                    isPlaying: true);
                              }
                            });
                          },
                          iconSize: 38,
                        )
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox.shrink(),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 30, bottom: 20.0)),
              Center(
                child: Row(children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 42.0),
                      child: Center(
                        child: GradientText(
                          "Listen",
                          shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
                          gradient: LinearGradient(colors: [
                            Color(0xff4db6ac),
                            Color(0xff61e88a),
                          ]),
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: IconButton(
                      iconSize: 26,
                      alignment: Alignment.center,
                      icon: Icon(MdiIcons.dotsVertical),
                      color: accent,
                      onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutPage(
                                name: name, email: email, image: uimage),
                          ),
                        ),
                      },
                    ),
                  )
                ]),
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              TextField(
                onSubmitted: (String value) {
                  search();
                },
                controller: searchBar,
                style: TextStyle(
                  fontSize: 16,
                  color: accent,
                ),
                cursorColor: Colors.green[50],
                decoration: InputDecoration(
                  fillColor: Color(0xff263238),
                  filled: true,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                    borderSide: BorderSide(
                      color: Color(0xff263238),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                    borderSide: BorderSide(color: accent),
                  ),
                  suffixIcon: IconButton(
                    icon: fetchingSongs
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(accent),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.search,
                            color: accent,
                          ),
                    color: accent,
                    onPressed: () {
                      search();
                    },
                  ),
                  border: InputBorder.none,
                  hintText: "Search...",
                  hintStyle: TextStyle(
                    color: accent,
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 18,
                    right: 20,
                    top: 14,
                    bottom: 14,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  getLiveDetails();
                },
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.network(
                    'https://bmnidhin.github.io/t4lk-static/s1/live2.jpg',
                    fit: BoxFit.fill,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                ),
              ),

              searchedList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: searchedList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Card(
                            color: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.0),
                              onTap: () {
                                getSongDetails(
                                    searchedList[index]["slug"], context);
                              },
                              onLongPress: () {
                                topSongs();
                              },
                              splashColor: accent,
                              hoverColor: accent,
                              focusColor: accent,
                              highlightColor: accent,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        MdiIcons.musicNoteOutline,
                                        size: 30,
                                        color: accent,
                                      ),
                                    ),
                                    title: Text(
                                      (searchedList[index]['title'])
                                          .toString()
                                          .split("(")[0]
                                          .replaceAll("&quot;", "\"")
                                          .replaceAll("&amp;", "&"),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      "",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: IconButton(
                                      color: accent,
                                      icon: Icon(MdiIcons.playCircleOutline),
                                      onPressed: () => getSongDetails(
                                          searchedList[index]["slug"], context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : FutureBuilder(
                      future: latestSongs(),
                      builder: (context, data) {
                        if (data.hasData)
                          return Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30.0, bottom: 10, left: 8),
                                  child: Text(
                                    "For " + name + "!",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  //padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                                  height:
                                      MediaQuery.of(context).size.height * 0.27,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 4,
                                    itemBuilder: (context, index) {
                                      return getTopSong(
                                          data.data[index]["cover"],
                                          data.data[index]["title"],
                                          " ",
                                          data.data[index]["slug"]);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.all(35.0),
                          child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ));
                      },
                    ),
              //custom list
              FutureBuilder(
                future: featuredSongs(),
                builder: (context, data) {
                  if (data.hasData)
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 30.0, bottom: 10, left: 8),
                            child: Text(
                              "Featured",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            //padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            height: MediaQuery.of(context).size.height * 0.27,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return getTopSong(
                                    data.data[index]["cover"],
                                    data.data[index]["title"],
                                    " ",
                                    data.data[index]["slug"]);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ));
                },
              ),
              FutureBuilder(
                future: latestSongs(),
                builder: (context, data) {
                  if (data.hasData)
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 30.0, bottom: 10, left: 8),
                            child: Text(
                              "Listen Again",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            //padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            height: MediaQuery.of(context).size.height * 0.27,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 6,
                              itemBuilder: (context, index) {
                                return getTopSong(
                                    data.data[index]["cover"],
                                    data.data[index]["title"],
                                    " ",
                                    data.data[index]["slug"]);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTopSong(String image, String title, String subtitle, String id) {
    return InkWell(
      onTap: () {
        getSongDetails(id, context);
      },
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.width * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: CachedNetworkImageProvider(image),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            title
                .split("(")[0]
                .replaceAll("&amp;", "&")
                .replaceAll("&#039;", "'")
                .replaceAll("&quot;", "\""),
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 9.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

versionCheck(context) async {
  //Get Current installed version of app
  final PackageInfo info = await PackageInfo.fromPlatform();
  double currentVersion = double.parse(info.version.trim().replaceAll(".", ""));

  //Get Latest version info from firebase config
  final RemoteConfig remoteConfig = await RemoteConfig.instance;

  try {
    // Using default duration to force fetching from remote server.
    await remoteConfig.fetch(expiration: const Duration(seconds: 0));
    await remoteConfig.activateFetched();
    remoteConfig.getString('force_update_current_version');
    double newVersion = double.parse(remoteConfig
        .getString('force_update_current_version')
        .trim()
        .replaceAll(".", ""));
    if (newVersion > currentVersion) {
      _showVersionDialog(context);
    }
  } on FetchThrottledException catch (exception) {
    // Fetch throttled.
    print(exception);
  } catch (exception) {
    print('Unable to fetch remote config. Cached or default values will be '
        'used');
  }
}

_showVersionDialog(context) async {
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      String title = "New Update Available";
      String message =
          "There is a newer version of app available please update it now.";
      String btnLabel = "Update Now";
      String btnLabelCancel = "Later";
      return new AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text(btnLabel),
            onPressed: () => _launchURL(PLAY_STORE_URL),
          ),
          FlatButton(
            child: Text(btnLabelCancel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
