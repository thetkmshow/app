import 'dart:convert';

import 'package:audiotagger/generated/i18n.dart';
import 'package:des_plugin/des_plugin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

List searchedList = [];
List topSongsList = [];
String kUrl = "",
    checker,
    image = "",
    title = "",
    album = "",
    artist = "",
    lyrics,
    info = "",
    has_320,
    rawkUrl;
String key = "38346591";
String decrypt = "";
String api = "https://api.thetkmshow.in/";
Future<List> fetchSongsList(searchQuery) async {
  String searchUrl = api + "alltracks";
  var res = await http.get(searchUrl, headers: {"Accept": "application/json"});
  var resEdited = (res.body);
  var getMain = json.decode(resEdited);

  searchedList = getMain;
  for (int i = 0; i < searchedList.length; i++) {
    searchedList[i]['title'] = searchedList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");

    // searchedList[i]['more_info']['singers'] = searchedList[i]['more_info']
    //         ['singers']
    //     .toString()
    //     .replaceAll("&amp;", "&")
    //     .replaceAll("&#039;", "'")
    //     .replaceAll("&quot;", "\"");
  }
  return searchedList;
}

String topSongsUrl = api + "alltracks";

Future<List> latestSongs() async {
  String topSongsUrl = api + "alltracks";
  var songsListJSON =
      await http.get(topSongsUrl, headers: {"Accept": "application/json"});
  var songsList = json.decode(songsListJSON.body);
  topSongsList = songsList;
  for (int i = 0; i < topSongsList.length; i++) {
    topSongsList[i]['title'] = topSongsList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");
    // topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"] =
    //     topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"]
    //         .toString()
    //         .replaceAll("&amp;", "&")
    //         .replaceAll("&#039;", "'")
    //         .replaceAll("&quot;", "\"");
    topSongsList[i]['cover'] =
        topSongsList[i]['cover'].toString().replaceAll("150x150", "500x500");
  }
  return topSongsList;
}

Future<List> featuredSongs() async {
  String topSongsUrl = api + "featured";
  var songsListJSON =
      await http.get(topSongsUrl, headers: {"Accept": "application/json"});
  var songsList = json.decode(songsListJSON.body);
  topSongsList = songsList;
  for (int i = 0; i < topSongsList.length; i++) {
    topSongsList[i]['title'] = topSongsList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");
    // topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"] =
    //     topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"]
    //         .toString()
    //         .replaceAll("&amp;", "&")
    //         .replaceAll("&#039;", "'")
    //         .replaceAll("&quot;", "\"");
    topSongsList[i]['cover'] =
        topSongsList[i]['cover'].toString().replaceAll("150x150", "500x500");
  }
  return topSongsList;
}

Future<List> topSongs() async {
  String topSongsUrl =
      "https://www.jiosaavn.com/api.php?__call=webapi.get&token=8MT-LQlP35c_&type=playlist&p=1&n=20&includeMetaTags=0&ctx=web6dot0&api_version=4&_format=json&_marker=0";
  var songsListJSON =
      await http.get(topSongsUrl, headers: {"Accept": "application/json"});
  var songsList = json.decode(songsListJSON.body);
  topSongsList = songsList["list"];
  for (int i = 0; i < topSongsList.length; i++) {
    topSongsList[i]['title'] = topSongsList[i]['title']
        .toString()
        .replaceAll("&amp;", "&")
        .replaceAll("&#039;", "'")
        .replaceAll("&quot;", "\"");
    topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"] =
        topSongsList[i]["more_info"]["artistMap"]["primary_artists"][0]["name"]
            .toString()
            .replaceAll("&amp;", "&")
            .replaceAll("&#039;", "'")
            .replaceAll("&quot;", "\"");
    topSongsList[i]['image'] =
        topSongsList[i]['image'].toString().replaceAll("150x150", "500x500");
  }
  return topSongsList;
}

Future fetchSongDetails(songId) async {
  String songUrl = api + "alltracks/" + songId;
  var res = await http.get(songUrl, headers: {"Accept": "application/json"});
  var resEdited = (res.body);
  var getMain = json.decode(resEdited);

  title = (getMain["title"])
      .toString()
      .split("(")[0]
      .replaceAll("&amp;", "&")
      .replaceAll("&#039;", "'")
      .replaceAll("&quot;", "\"");
  image = (getMain["cover"]).replaceAll("150x150", "500x500");
  album = (getMain["artist"])
      .toString()
      .replaceAll("&quot;", "\"")
      .replaceAll("&#039;", "'")
      .replaceAll("&amp;", "&");

  try {
    artist = "My Artist";
  } catch (e) {
    artist = "-";
  }
  // print(getMain[songId]["more_info"]["has_lyrics"]);
  // if (true) {
  //   String lyricsUrl =
  //       "https://www.jiosaavn.com/api.php?__call=lyrics.getLyrics&lyrics_id=" +
  //           songId +
  //           "&ctx=web6dot0&api_version=4&_format=json";
  //   var lyricsRes =
  //       await http.get(lyricsUrl, headers: {"Accept": "application/json"});
  //   var lyricsEdited = (lyricsRes.body).split("-->");
  //   var fetchedLyrics = json.decode(lyricsEdited[1]);
  //   lyrics = fetchedLyrics["lyrics"].toString().replaceAll("<br>", "\n");
  // } else {
  //   lyrics = "null";
  //   String lyricsApiUrl =
  //       "https://sumanjay.vercel.app/lyrics/" + artist + "/" + title;
  //   var lyricsApiRes =
  //       await http.get(lyricsApiUrl, headers: {"Accept": "application/json"});
  //   var lyricsResponse = json.decode(lyricsApiRes.body);
  //   if (lyricsResponse['status'] == true && lyricsResponse['lyrics'] != null) {
  //     lyrics = lyricsResponse['lyrics'];
  //   }
  // }
  info = (getMain["content"])
      .toString()
      .split("(")[0]
      .replaceAll("&amp;", "&")
      .replaceAll("&#039;", "'")
      .replaceAll("&quot;", "\"");
  // has_320 = getMain[songId]["more_info"]["320kbps"];
  kUrl = (getMain["URL"])
      .toString()
      .split("(")[0]
      .replaceAll("&amp;", "&")
      .replaceAll("&#039;", "'")
      .replaceAll("&quot;", "\"");

  rawkUrl = kUrl;

  // final client = http.Client();
  // final request = http.Request('HEAD', Uri.parse(kUrl))
  //   ..followRedirects = false;
  // final response = await client.send(request);
  // print(response);
  // kUrl = (response.headers['location']);
  artist = (getMain["duration"])
      .toString()
      .split("(")[0]
      .replaceAll("&amp;", "&")
      .replaceAll("&#039;", "'")
      .replaceAll("&quot;", "\"");
  ;
  debugPrint(kUrl);
}

Future getLive() async {
  title = ("Live Radio")
      .toString()
      .split("(")[0]
      .replaceAll("&amp;", "&")
      .replaceAll("&#039;", "'")
      .replaceAll("&quot;", "\"");
  image =
      ("https://d3t3ozftmdmh3i.cloudfront.net/production/podcast_uploaded/6042015/6042015-1591172558348-8d8b77870bd83.jpg");
  album = ("Live")
      .toString()
      .replaceAll("&quot;", "\"")
      .replaceAll("&#039;", "'")
      .replaceAll("&amp;", "&");

  try {
    artist = "My Artist";
  } catch (e) {
    artist = "-";
  }
  // print(getMain[songId]["more_info"]["has_lyrics"]);
  // if (true) {
  //   String lyricsUrl =
  //       "https://www.jiosaavn.com/api.php?__call=lyrics.getLyrics&lyrics_id=" +
  //           songId +
  //           "&ctx=web6dot0&api_version=4&_format=json";
  //   var lyricsRes =
  //       await http.get(lyricsUrl, headers: {"Accept": "application/json"});
  //   var lyricsEdited = (lyricsRes.body).split("-->");
  //   var fetchedLyrics = json.decode(lyricsEdited[1]);
  //   lyrics = fetchedLyrics["lyrics"].toString().replaceAll("<br>", "\n");
  // } else {
  //   lyrics = "null";
  //   String lyricsApiUrl =
  //       "https://sumanjay.vercel.app/lyrics/" + artist + "/" + title;
  //   var lyricsApiRes =
  //       await http.get(lyricsApiUrl, headers: {"Accept": "application/json"});
  //   var lyricsResponse = json.decode(lyricsApiRes.body);
  //   if (lyricsResponse['status'] == true && lyricsResponse['lyrics'] != null) {
  //     lyrics = lyricsResponse['lyrics'];
  //   }
  // }
  info =
      "Home of TKM's very own podcast. Here we bring you everything from alumni interviews, interactive sessions and a platform for voices of TKM to reign free."
          .toString()
          .split("(")[0]
          .replaceAll("&amp;", "&")
          .replaceAll("&#039;", "'")
          .replaceAll("&quot;", "\"");
  // has_320 = getMain[songId]["more_info"]["320kbps"];
  kUrl = ("https://stream.zenolive.com/qds1zvhxk2zuv.aac")
      .toString()
      .split("(")[0]
      .replaceAll("&amp;", "&")
      .replaceAll("&#039;", "'")
      .replaceAll("&quot;", "\"");

  rawkUrl = kUrl;

  // final client = http.Client();
  // final request = http.Request('HEAD', Uri.parse(kUrl))
  //   ..followRedirects = false;
  // final response = await client.send(request);
  // print(response);
  // kUrl = (response.headers['location']);
  artist = "Endless";
  debugPrint(kUrl);
}
